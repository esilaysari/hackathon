import 'package:flutter/material.dart';

import '../../models/student_summary.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';

/// Yalnızca Kritik öğrencilerin listesi; satırlar Warning-Soft zeminli (DESIGN.md §8.7).
class CriticalList extends StatelessWidget {
  const CriticalList({
    super.key,
    required this.overview,
    required this.selectedId,
    required this.onSelect,
  });

  final ClassOverview overview;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (overview.criticalStudents.isEmpty) {
      return const Text(AppStrings.noCriticalStudents, style: AppTextStyles.bodyLg);
    }
    return Column(
      children: [
        for (final student in overview.criticalStudents)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _Row(
              student: student,
              suffix: overview.nameSuffixes[student.id],
              selected: student.id == selectedId,
              onTap: () => onSelect(student.id),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.student, required this.suffix, required this.selected, required this.onTap});

  final StudentSummary student;
  final String? suffix;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      AppStrings.learningStyleName(student.learningStyle),
      student.topicTitle,
      if (student.stuckFor != null) AppStrings.stuckFor(student.stuckFor!),
    ].join(' · ');
    return Material(
      color: AppColors.warningSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? AppColors.lilac700 : AppColors.warningSoft),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(
                text: student.displayName,
                style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700),
                children: [
                  if (suffix != null) TextSpan(text: ' · $suffix', style: AppTextStyles.caption),
                ],
              )),
              Text(details, style: AppTextStyles.bodyLg),
            ],
          ),
        ),
      ),
    );
  }
}
