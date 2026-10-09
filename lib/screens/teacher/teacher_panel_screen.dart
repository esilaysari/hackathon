import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../demo_accounts.dart';
import '../../models/alert.dart';
import '../../models/student_summary.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/class_code_view.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/teacher/critical_list.dart';
import '../../widgets/teacher/emergency_alert_card.dart';
import '../../widgets/teacher/panel_card.dart';
import '../../widgets/teacher/student_detail.dart';
import '../../widgets/teacher/summary_strip.dart';
import '../classroom/create_class_screen.dart';
import 'lesson_upload_screen.dart';

/// Öğretmen Paneli (DESIGN.md §8.7–8.8, K52): yalnızca bu öğretmenin sınıfları
/// (`classes.teacherId == uid`). Birden fazla sınıf varsa üstte sınıf seçici; panelin
/// tamamı seçili sınıfa göre çalışır. Hiç sınıf yoksa "İlk sınıfını oluştur".
class TeacherPanelScreen extends StatefulWidget {
  const TeacherPanelScreen({super.key, required this.teacherId, this.initialClassId});

  final String teacherId;

  /// Açılışta seçili sınıf; yoksa demo sınıfı (varsa), o da yoksa ilk oluşturulan.
  final String? initialClassId;

  @override
  State<TeacherPanelScreen> createState() => _TeacherPanelScreenState();
}

class _TeacherPanelScreenState extends State<TeacherPanelScreen> {
  late final _classes = FirestoreService.watchTeacherClasses(widget.teacherId);
  late String? _selectedClassId = widget.initialClassId;

  /// İlk sınıf oluşturulurken liste dolsa da kod ekranı "Panele Git"e kadar açık kalır.
  bool _creatingFirst = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _classes,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.creamBase,
            body: Center(child: Text(AppStrings.panelLoading, style: AppTextStyles.bodyLg)),
          );
        }
        final docs = [...snap.data!.docs]..sort((a, b) => _createdAt(a.data()).compareTo(_createdAt(b.data())));
        if (docs.isEmpty || _creatingFirst) {
          _creatingFirst = true;
          return CreateClassScreen(
            teacherId: widget.teacherId,
            first: true,
            onDone: (id) => setState(() {
              _creatingFirst = false;
              _selectedClassId = id;
            }),
          );
        }
        final ids = [for (final d in docs) d.id];
        final selected = ids.contains(_selectedClassId)
            ? _selectedClassId!
            : (ids.contains(DemoAccounts.classId) ? DemoAccounts.classId : ids.first);
        return _ClassPanel(
          key: ValueKey(selected),
          classId: selected,
          onNewClass: _newClass,
          classSelector: docs.length < 2
              ? null
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final d in docs)
                      SelectChip(
                        label: d.data()['name'] as String? ?? d.id,
                        selected: d.id == selected,
                        onTap: () => setState(() => _selectedClassId = d.id),
                      ),
                  ],
                ),
        );
      },
    );
  }

  static int _createdAt(Map<String, dynamic> data) =>
      (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;

  void _newClass() => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (routeContext) => CreateClassScreen(
            teacherId: widget.teacherId,
            onDone: (id) {
              Navigator.pop(routeContext);
              setState(() => _selectedClassId = id);
            },
          ),
        ),
      );
}

/// Seçili sınıfın paneli (ROADMAP Faz 3–4). Firestore'u canlı dinler; demo sınıfında mock
/// öğrencileri bir kez okur ve gerçek üyelerle tek listede birleştirir (K32), diğer
/// sınıflarda yalnızca gerçek üyeler (K52). Saniyede bir yeniden çizilir (K48).
class _ClassPanel extends StatefulWidget {
  const _ClassPanel({super.key, required this.classId, required this.classSelector, required this.onNewClass});

  final String classId;
  final Widget? classSelector;
  final VoidCallback onNewClass;

  @override
  State<_ClassPanel> createState() => _ClassPanelState();
}

class _ClassPanelState extends State<_ClassPanel> {
  late final Future<List<Map<String, dynamic>>> _mocks = DemoAccounts.isDemoClass(widget.classId)
      ? MockDataService.loadStudents()
      : Future.value(const <Map<String, dynamic>>[]);
  final DateTime _openedAt = DateTime.now();
  DateTime _now = DateTime.now();
  late final Timer _ticker;
  late final _classStream = FirestoreService.watchClass(widget.classId);
  late final _membersStream = FirestoreService.watchMembers(widget.classId);
  late final _alertsStream = FirestoreService.watchOpenAlerts(widget.classId);

  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        backgroundColor: AppColors.creamBase,
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.appTitle, style: AppTextStyles.appBarTitle),
      ),
      body: FutureBuilder(
        future: _mocks,
        builder: (context, mocks) => StreamBuilder(
          stream: _classStream,
          builder: (context, classSnap) => StreamBuilder(
            stream: _membersStream,
            builder: (context, membersSnap) => StreamBuilder(
              stream: _alertsStream,
              builder: (context, alertsSnap) {
                final classData = classSnap.data?.data();
                if (!mocks.hasData || classData == null || !membersSnap.hasData) {
                  return const Center(child: Text(AppStrings.panelLoading, style: AppTextStyles.bodyLg));
                }
                final elapsed = _now.difference(_openedAt);
                final overview = ClassOverview.build(
                  real: [
                    for (final doc in membersSnap.data!.docs) StudentSummary.fromMember(doc.id, doc.data(), _now),
                  ],
                  mocks: [for (final json in mocks.data!) StudentSummary.fromMock(json, elapsed: elapsed)],
                );
                final alerts = [
                  for (final doc in alertsSnap.data?.docs ?? const [])
                    EmergencyAlert.fromFirestore(doc.id, doc.data()),
                ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return _buildLayout(classData, overview, alerts);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(Map<String, dynamic> classData, ClassOverview overview, List<EmergencyAlert> alerts) {
    final presentationMode = classData['presentationMode'] == true;
    final summary = SummaryStrip(
      className: classData['name'] as String,
      classCode: classData['code'] as String,
      overview: overview,
      presentationMode: presentationMode,
      onPresentationModeChanged: (v) => FirestoreService.setPresentationMode(widget.classId, v),
    );
    final criticalCard = PanelCard(
      title: AppStrings.criticalListTitle,
      child: CriticalList(
        overview: overview,
        selectedId: _selectedId,
        onSelect: (id) => setState(() => _selectedId = id),
      ),
    );
    final sideCards = [
      for (final alert in alerts)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: EmergencyAlertCard(
            key: ValueKey(alert.id),
            alert: alert,
            now: _now,
            peer: overview.suggestPeer(alert.topicKey, excludeId: alert.studentId),
            onMatch: () => _match(alert, overview.suggestPeer(alert.topicKey, excludeId: alert.studentId)!),
            onSeen: () => FirestoreService.markAlertSeen(widget.classId, alert.id),
          ),
        ),
      PanelCard(
        title: AppStrings.detailTitle,
        child: StudentDetail(
          student: overview.byId(_selectedId),
          suffix: overview.nameSuffixes[_selectedId],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      PanelCard(title: AppStrings.styleDistributionTitle, child: StyleDistribution(overview: overview)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppLayout.desktopBreakpoint;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SecondaryButton(label: AppStrings.newClass, onPressed: widget.onNewClass),
                  SecondaryButton(
                    label: AppStrings.inviteTitle,
                    onPressed: () => _showInvite(classData['code'] as String),
                  ),
                  PrimaryButton(label: AppStrings.uploadLesson, onPressed: _openUpload),
                ],
              ),
              if (widget.classSelector != null) ...[
                const SizedBox(height: AppSpacing.md),
                widget.classSelector!,
              ],
              const SizedBox(height: AppSpacing.md),
              summary,
              const SizedBox(height: AppSpacing.lg),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: criticalCard),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: Column(children: sideCards)),
                  ],
                )
              else ...[
                // Dar ekranda uyarılar en üstte kalır.
                ...sideCards.take(alerts.length),
                criticalCard,
                const SizedBox(height: AppSpacing.md),
                ...sideCards.skip(alerts.length),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showInvite(String code) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text(AppStrings.inviteTitle, style: AppTextStyles.appBarTitle),
        content: SizedBox(width: AppLayout.studentMaxWidth, child: ClassCodeView(code: code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.close, style: appLinkStyle),
          ),
        ],
      ),
    );
  }

  void _openUpload() => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => LessonUploadScreen(classId: widget.classId)),
      );

  /// PeerSwarm "Eşleştir" (K22, K47). Mock akrana bildirim yalnızca simüle edilir.
  void _match(EmergencyAlert alert, StudentSummary peer) {
    FirestoreService.matchPeer(
      widget.classId,
      alertId: alert.id,
      studentId: alert.studentId,
      studentName: alert.studentName,
      peerId: peer.id,
      peerName: peer.displayName,
      peerIsMock: peer.isMock,
      studentText: AppStrings.peerWillHelp(peer.displayName),
      peerText: AppStrings.peerAskedToHelp(alert.studentName),
    );
    if (peer.isMock) {
      debugPrint('PeerSwarm simülasyonu: ${peer.displayName} (${peer.id}) bildirimi gönderildi');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            AppStrings.mockPeerNotified(peer.displayName),
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onDark),
          ),
        ),
      );
    }
  }
}
