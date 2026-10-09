import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'lesson_text.dart';

/// Büyük, dokunulabilir şık kartı; seçili olan Lilac-100 zemin + Lilac-700 kenarlık
/// (DESIGN.md §8.2). Soru ekranında ve Sokratik kontrol sorusunda kullanılır.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.text,
    required this.textStyle,
    required this.selected,
    required this.onTap,
    this.isCode = false,
  });

  final String text;
  final TextStyle textStyle;
  final bool selected;
  final VoidCallback? onTap;

  /// true → şık metni monospace gösterilir (`optionsAreCode`).
  final bool isCode;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.lilac100 : AppColors.creamSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? AppColors.lilac700 : AppColors.grey400),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LessonText(text, style: isCode ? textStyle.copyWith(fontFamily: AppFonts.mono) : textStyle),
        ),
      ),
    );
  }
}
