import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../theme/tokens.dart';

/// Ders görseli: köşeleri yuvarlak, genişliğe sığar. [alt] yalnızca ekran okuyucuya
/// verilir; şemaların içinde açıklama zaten olduğu için ekranda yazılmaz (K50).
class LessonImage extends StatelessWidget {
  const LessonImage({super.key, required this.path, required this.alt, this.maxHeight});

  final String path;
  final String? alt;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.asset(path, fit: BoxFit.contain, excludeFromSemantics: true),
    );
    return Semantics(
      image: true,
      label: alt,
      child: maxHeight == null
          ? image
          : ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight!), child: image),
    );
  }
}

/// Okuma ekranındaki şema (DESIGN.md §8.4). Görsel profilde tam genişlikte, Lilac-100
/// zeminli ve gölgeli bir kutuda öne çıkarılır; diğer profillerde sade ve sınırlı yükseklikte.
class LessonFigureView extends StatelessWidget {
  const LessonFigureView({super.key, required this.figure, required this.style});

  final LessonFigure figure;
  final LearningStyle style;

  @override
  Widget build(BuildContext context) {
    if (style != LearningStyle.visual) {
      return Center(
        child: LessonImage(path: figure.image, alt: figure.alt, maxHeight: AppLayout.figureMaxHeight),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lilac100,
        border: Border.all(color: AppColors.lilac300),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.light,
      ),
      child: LessonImage(path: figure.image, alt: figure.alt),
    );
  }
}
