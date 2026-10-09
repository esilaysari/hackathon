import 'package:flutter/material.dart';

import '../../models/alert.dart';
import '../../models/student_summary.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/teacher/critical_list.dart';
import '../../widgets/teacher/emergency_alert_card.dart';
import '../../widgets/teacher/panel_card.dart';
import '../../widgets/teacher/student_detail.dart';
import '../../widgets/teacher/summary_strip.dart';

/// Öğretmen Paneli (DESIGN.md §8.7–8.8, ROADMAP Faz 3). Firestore'u canlı dinler,
/// mock öğrencileri bir kez okur ve ikisini tek listede birleştirir (K32).
class TeacherPanelScreen extends StatefulWidget {
  const TeacherPanelScreen({super.key, required this.classId});

  final String classId;

  @override
  State<TeacherPanelScreen> createState() => _TeacherPanelScreenState();
}

class _TeacherPanelScreenState extends State<TeacherPanelScreen> {
  late final Future<List<StudentSummary>> _mocks = MockDataService.loadStudents()
      .then((list) => list.map(StudentSummary.fromMock).toList());
  late final _classStream = FirestoreService.watchClass(widget.classId);
  late final _membersStream = FirestoreService.watchMembers(widget.classId);
  late final _alertsStream = FirestoreService.watchOpenAlerts(widget.classId);

  String? _selectedId;

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
                final now = DateTime.now();
                final overview = ClassOverview.build(
                  real: [
                    for (final doc in membersSnap.data!.docs) StudentSummary.fromMember(doc.id, doc.data(), now),
                  ],
                  mocks: mocks.data!,
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
}
