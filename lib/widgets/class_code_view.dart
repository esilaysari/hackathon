import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/class_code.dart';
import '../strings.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';

/// Büyük, okunaklı sınıf kodu + "Kodu Kopyala" / "Linki Kopyala" (DESIGN.md §8.3).
class ClassCodeView extends StatelessWidget {
  const ClassCodeView({super.key, required this.code});

  final String code;

  /// Kod harfleri arası geniş boşluk: Task Title boyutunun üçte biri.
  static final codeStyle =
      AppTextStyles.taskTitle.copyWith(letterSpacing: AppTextStyles.taskTitle.fontSize! / 3);

  @override
  Widget build(BuildContext context) {
    final link = ClassCode.inviteLink(code);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: AppColors.lilac100, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SelectableText(code, textAlign: TextAlign.center, style: codeStyle),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(link, textAlign: TextAlign.center, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: SecondaryButton(label: AppStrings.copyCode, onPressed: () => _copy(context, code))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: SecondaryButton(label: AppStrings.copyLink, onPressed: () => _copy(context, link))),
          ],
        ),
      ],
    );
  }

  static Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.mint300,
        content: Text(AppStrings.copied, style: AppTextStyles.bodyLg),
      ),
    );
  }
}
