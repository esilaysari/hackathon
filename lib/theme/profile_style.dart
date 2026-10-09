import 'package:flutter/material.dart';

import '../models/lesson.dart';
import 'tokens.dart';

/// Profil bazlı sunum kuralları (DESIGN.md §3.2, MEMORY K18, K27).
abstract final class ProfileStyle {
  static TextStyle body(LearningStyle style) => switch (style) {
        LearningStyle.dyslexic => AppTextStyles.bodyLg.copyWith(
            fontFamily: AppFonts.lexend,
            fontSize: ProfileTypography.dyslexicFontSize,
            height: ProfileTypography.dyslexicLineHeight,
            letterSpacing: ProfileTypography.dyslexicLetterSpacing,
          ),
        LearningStyle.visual ||
        LearningStyle.textual =>
          AppTextStyles.bodyLg.copyWith(height: ProfileTypography.textualLineHeight),
      };

  /// Başlık ve Story metni gibi diğer stiller için profilin yazı tipi.
  static TextStyle withFont(TextStyle base, LearningStyle style) =>
      style == LearningStyle.dyslexic ? base.copyWith(fontFamily: AppFonts.lexend) : base;

  /// Dislektik profilde saf beyaz kullanılmaz; kartlar da Cream-Base olur (K27).
  static Color cardColor(LearningStyle style) =>
      style == LearningStyle.dyslexic ? AppColors.creamBase : AppColors.creamSurface;
}
