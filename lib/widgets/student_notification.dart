import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/tokens.dart';

/// Öğrenci bildirim kartı (DESIGN.md §8.9): üstten kayarak gelir, akışı bölmez.
/// [text] null olduğunda yukarı kayarak gizlenir.
class StudentNotification extends StatelessWidget {
  const StudentNotification({super.key, required this.text, required this.onDismiss});

  final String? text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: text == null ? const Offset(0, -2) : Offset.zero,
      duration: AppDurations.studentNotification,
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.mint300,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.light,
        ),
        child: Row(
          children: [
            Expanded(child: Text(text ?? '', style: AppTextStyles.bodyLg)),
            TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(foregroundColor: AppColors.grey900, textStyle: AppTextStyles.button),
              child: const Text(AppStrings.notificationOk),
            ),
          ],
        ),
      ),
    );
  }
}
