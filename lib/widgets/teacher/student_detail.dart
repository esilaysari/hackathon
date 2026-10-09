import 'package:flutter/material.dart';

import '../../models/student_summary.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';

/// Seçili öğrencinin yalnızca özet bilgisi; ham telemetri gösterilmez (K23).
class StudentDetail extends StatelessWidget {
  const StudentDetail({super.key, required this.student, required this.suffix});

  final StudentSummary? student;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final s = student;
    if (s == null) return const Text(AppStrings.detailEmpty, style: AppTextStyles.bodyLg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          suffix == null ? s.displayName : '${s.displayName} · $suffix',
          style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          [
            AppStrings.learningStyleName(s.learningStyle),
            s.topicTitle,
            AppStrings.focusStateName(s.status),
            if (s.stuckFor != null) AppStrings.stuckFor(s.stuckFor!),
          ].join(' · '),
          style: AppTextStyles.bodyLg,
        ),
        if (s.interactionCount != null && s.idleSeconds != null)
          Text(
            AppStrings.interactionSummary(s.interactionCount!, s.idleSeconds!),
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
          ),
      ],
    );
  }
}

/// Öğrenme stili dağılımı (ör. Görsel 15 · Dislektik 15 · Metinsel 14).
class StyleDistribution extends StatelessWidget {
  const StyleDistribution({super.key, required this.overview});

  final ClassOverview overview;

  @override
  Widget build(BuildContext context) {
    return Text(
      [
        for (final entry in overview.styleCounts.entries)
          '${AppStrings.learningStyleName(entry.key)} ${entry.value}',
      ].join(' · '),
      style: AppTextStyles.bodyLg,
    );
  }
}
