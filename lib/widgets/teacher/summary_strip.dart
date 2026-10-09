import 'package:flutter/material.dart';

import '../../models/student_summary.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';

/// Üst özet şeridi: sınıf, kod, sayaçlar ve Sunum Modu anahtarı (DESIGN.md §8.7).
class SummaryStrip extends StatelessWidget {
  const SummaryStrip({
    super.key,
    required this.className,
    required this.classCode,
    required this.overview,
    required this.presentationMode,
    required this.onPresentationModeChanged,
  });

  final String className;
  final String classCode;
  final ClassOverview overview;
  final bool presentationMode;
  final ValueChanged<bool> onPresentationModeChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(className, style: AppTextStyles.subheading),
            Text(AppStrings.classCode(classCode), style: AppTextStyles.caption),
          ],
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(AppStrings.studentCount(overview.total), style: AppTextStyles.dashboardNumber),
            _Badge(text: AppStrings.attentionCount(overview.attentionCount), color: AppColors.lilac100),
            _Badge(text: AppStrings.criticalCount(overview.criticalCount), color: AppColors.warningSoft),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.presentationMode, style: AppTextStyles.bodyLg),
            const SizedBox(width: AppSpacing.sm),
            Switch(
              value: presentationMode,
              onChanged: onPresentationModeChanged,
              activeTrackColor: AppColors.lilac700,
              activeThumbColor: AppColors.onDark,
            ),
            if (presentationMode) ...[
              const SizedBox(width: AppSpacing.sm),
              const _Badge(text: AppStrings.presentationModeBadge, color: AppColors.lilac100),
            ],
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm / 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Text(text, style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
