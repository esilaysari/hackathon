import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Öğretmen paneli kartı: Cream-Surface, radius-lg, Shadow/Light (DESIGN.md §5, §6).
class PanelCard extends StatelessWidget {
  const PanelCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subheading),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
