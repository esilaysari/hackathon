import 'package:flutter/material.dart';

import '../../models/lesson_catalog.dart';
import '../../services/content_service.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_repository.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import 'lesson_screen.dart';

/// "Derslerim" (K50): uygulamayla gelen hazır dersler + öğretmenin Firestore'a yüklediği
/// dersler tek listede. Ders sayısı sabit değildir; iki kaynaktan ne gelirse o gösterilir.
class MyLessonsScreen extends StatefulWidget {
  const MyLessonsScreen({super.key, required this.uid, required this.classId});

  final String uid;
  final String classId;

  @override
  State<MyLessonsScreen> createState() => _MyLessonsScreenState();
}

class _MyLessonsScreenState extends State<MyLessonsScreen> {
  late final Future<LessonCatalog> _catalog = ContentService.loadCatalog();
  late final _teacherLessons = FirestoreService.watchLessons(widget.classId);

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
          stream: _teacherLessons,
          builder: (context, lessonsSnap) {
            final catalog = catalogSnap.data;
            if (catalog == null) {
              return const Center(child: Text(AppStrings.myLessonsLoading, style: AppTextStyles.bodyLg));
            }
            // Firestore henüz yanıt vermediyse ya da hata verdiyse hazır dersler yine görünür.
            final entries = catalog.merge([
              for (final doc in lessonsSnap.data?.docs ?? const []) LessonEntry.fromFirestore(doc.id, doc.data()),
            ]);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppLayout.studentMaxWidth),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => _LessonCard(entry: entries[i], onTap: () => _open(entries[i], catalog)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _open(LessonEntry entry, LessonCatalog catalog) async {
    try {
      final lesson = await LessonRepository.load(entry, widget.classId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => LessonScreen(
            uid: widget.uid,
            classId: widget.classId,
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
