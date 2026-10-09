import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../form_widgets.dart';

/// Seçili sınıfa öğretmenin yüklediği dersler ve "Sil" (onay penceresiyle). Hazır dersler
/// Firestore'da olmadığı için listede görünmez, silinemez (K53).
class LessonManager extends StatefulWidget {
  const LessonManager({super.key, required this.classId});

  final String classId;

  @override
  State<LessonManager> createState() => _LessonManagerState();
}

class _LessonManagerState extends State<LessonManager> {
  late final _lessons = FirestoreService.watchLessons(widget.classId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _lessons,
      builder: (context, snap) {
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Text(
            snap.hasData ? AppStrings.noUploadedLessons : AppStrings.myLessonsLoading,
            style: AppTextStyles.bodyLg,
          );
        }
        return Column(
          children: [
            for (final doc in docs)
              Row(
                children: [
                  Expanded(child: Text(doc.data()['title'] as String? ?? '', style: AppTextStyles.bodyLg)),
                  TextButton(
                    onPressed: () => _confirmDelete(doc.id),
                    child: Text(AppStrings.deleteLesson, style: appLinkStyle),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String lessonId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        content: const Text(AppStrings.deleteLessonConfirm, style: AppTextStyles.bodyLg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel, style: appLinkStyle),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.deleteLesson, style: appLinkStyle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirestoreService.deleteLesson(widget.classId, lessonId);
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.mint300,
          content: Text(AppStrings.lessonDeleted, style: AppTextStyles.bodyLg),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(AppStrings.errorGeneric(e), style: AppTextStyles.bodyLg),
        ),
      );
    }
  }
}
