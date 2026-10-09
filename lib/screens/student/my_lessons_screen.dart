import 'package:flutter/material.dart';

import '../../demo_accounts.dart';
import '../../models/lesson_catalog.dart';
import '../../services/content_service.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_repository.dart';
import '../../services/session.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_buttons.dart';
import '../classroom/join_class_screen.dart';
import 'lesson_screen.dart';

/// "Derslerim" (K50, K52): yalnızca öğrencinin katıldığı sınıfların dersleri, sınıf adı
/// başlığı altında gruplanmış. Hazır dersler yalnızca demo sınıfında görünür.
/// `users/{uid}.classIds` canlı izlenir; "Sınıfa Katıl" sonrası liste kendiliğinden güncellenir.
class MyLessonsScreen extends StatefulWidget {
  const MyLessonsScreen({super.key, required this.uid});

  final String uid;

  @override
  State<MyLessonsScreen> createState() => _MyLessonsScreenState();
}

class _MyLessonsScreenState extends State<MyLessonsScreen> {
  late final Future<LessonCatalog> _catalog = ContentService.loadCatalog();
  late final _user = FirestoreService.watchUser(widget.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        backgroundColor: AppColors.creamBase,
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.myLessonsTitle, style: AppTextStyles.appBarTitle),
      ),
      body: FutureBuilder(
        future: _catalog,
        builder: (context, catalogSnap) => StreamBuilder(
          stream: _user,
          builder: (context, userSnap) {
            final catalog = catalogSnap.data;
            if (catalog == null || !userSnap.hasData) {
              return const Center(child: Text(AppStrings.myLessonsLoading, style: AppTextStyles.bodyLg));
            }
            final classIds = AppUser.parseClassIds(userSnap.data!.data() ?? const {});
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppLayout.studentMaxWidth),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SecondaryButton(label: AppStrings.joinAnotherClass, onPressed: _joinClass),
                    ),
                    if (classIds.isEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const Text(AppStrings.noClassesYet, style: AppTextStyles.bodyLg, textAlign: TextAlign.center),
                    ],
                    for (final classId in classIds)
                      _ClassSection(
                        key: ValueKey(classId),
                        classId: classId,
                        catalog: catalog,
                        onOpen: (entry) => _open(entry, classId, catalog),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _joinClass() => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => JoinClassScreen(uid: widget.uid)),
      );

  Future<void> _open(LessonEntry entry, String classId, LessonCatalog catalog) async {
    try {
      final lesson = await LessonRepository.load(entry, classId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => LessonScreen(
            uid: widget.uid,
            classId: classId,
            lesson: lesson,
            socraticMessages: catalog.socraticMessages,
            fallbackChain: catalog.defaultSocratic,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(AppStrings.lessonOpenFailed(e), style: AppTextStyles.bodyLg),
        ),
      );
    }
  }
}

/// Bir sınıfın başlığı (sınıf adı) ve dersleri: öğretmenin dersleri üstte; demo sınıfında
/// altında hazır dersler.
class _ClassSection extends StatefulWidget {
  const _ClassSection({super.key, required this.classId, required this.catalog, required this.onOpen});

  final String classId;
  final LessonCatalog catalog;
  final ValueChanged<LessonEntry> onOpen;

  @override
  State<_ClassSection> createState() => _ClassSectionState();
}

class _ClassSectionState extends State<_ClassSection> {
  late final _class = FirestoreService.watchClass(widget.classId);
  late final _lessons = FirestoreService.watchLessons(widget.classId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _class,
      builder: (context, classSnap) => StreamBuilder(
        stream: _lessons,
        builder: (context, lessonsSnap) {
          // Firestore henüz yanıt vermediyse ya da hata verdiyse demo sınıfının hazır dersleri yine görünür.
          final teacherLessons = [
            for (final doc in lessonsSnap.data?.docs ?? const []) LessonEntry.fromFirestore(doc.id, doc.data()),
          ];
          final entries = widget.catalog.forClass(widget.classId, teacherLessons);
          final name = classSnap.data?.data()?['name'] as String? ??
              (DemoAccounts.isDemoClass(widget.classId) ? DemoAccounts.className : '');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(name, style: AppTextStyles.appBarTitle),
              const SizedBox(height: AppSpacing.md),
              if (entries.isEmpty && lessonsSnap.hasData)
                const Text(AppStrings.noLessonsInClass, style: AppTextStyles.bodyLg),
              for (final entry in entries) ...[
                _LessonCard(entry: entry, onTap: () => widget.onOpen(entry)),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.entry, required this.onTap});

  final LessonEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final minutes = entry.estimatedMinutes;
    final meta = [
      if (minutes != null) AppStrings.estimatedMinutes(minutes),
      if (entry.isTeacherLesson) AppStrings.teacherLessonBadge,
    ].join(' · ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(lessonIcon(entry.iconName), color: AppColors.lilac500, size: AppSpacing.xl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title, style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm / 2),
                      Text(entry.summary, style: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600)),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(meta, style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `index.json`'daki ikon adı → Material ikonu. Bilinmeyen ad → kitap ikonu.
IconData lessonIcon(String? name) => switch (name) {
      'memory' => Icons.memory_rounded,
      'account_tree' => Icons.account_tree_rounded,
      'search' => Icons.search_rounded,
      _ => Icons.menu_book_rounded,
    };
