import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Birincil buton: Lilac-700 zemin, beyaz metin (DESIGN.md §2.3).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lilac700,
        foregroundColor: AppColors.onDark,
        disabledBackgroundColor: AppColors.grey400,
        disabledForegroundColor: AppColors.grey900,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      child: Text(label),
    );
  }
}

/// İkincil buton: beyaz zemin, Lilac-700 kenarlık ve metin (DESIGN.md §8.4).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.creamSurface,
        foregroundColor: AppColors.lilac700,
        side: const BorderSide(color: AppColors.lilac700),
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      child: Text(label),
    );
  }
}
