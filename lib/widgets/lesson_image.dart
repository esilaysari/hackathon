import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../strings.dart';
import '../theme/tokens.dart';

/// Gösterilecek bir ders görseli: hazır derste asset, yüklenen derste slayttan gelen JPEG.
class LessonPicture {
  const LessonPicture(this.image, this.alt);

  final ImageProvider image;
  final String? alt;

  /// Kartın görselleri: hazır dersin asset'i ve/veya slayt görselleri (K54).
  static List<LessonPicture> ofCard(StoryCard card, Map<String, Uint8List> images) => [
        if (card.image != null) LessonPicture(AssetImage(card.image!), card.imageAlt),
        ..._ofIds(card.imageIds, images),
      ];

  static List<LessonPicture> ofQuestion(Question question, Map<String, Uint8List> images) =>
      _ofIds(question.imageIds, images);

  static List<LessonPicture> ofFigure(LessonFigure figure, Map<String, Uint8List> images) => [
        if (figure.image != null) LessonPicture(AssetImage(figure.image!), figure.alt),
        if (images[figure.imageId] case final bytes?) LessonPicture(MemoryImage(bytes), figure.alt),
      ];

  static List<LessonPicture> _ofIds(List<String> ids, Map<String, Uint8List> images) => [
        for (final id in ids)
          if (images[id] case final bytes?) LessonPicture(MemoryImage(bytes), AppStrings.slideImageAlt),
      ];
}

/// Ders görseli: köşeleri yuvarlak, genişliğe sığar. [alt] yalnızca ekran okuyucuya
/// verilir; şemaların içinde açıklama zaten olduğu için ekranda yazılmaz (K50).
class LessonImage extends StatelessWidget {
  const LessonImage({super.key, required this.picture, this.maxHeight});

  final LessonPicture picture;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image(image: picture.image, fit: BoxFit.contain, excludeFromSemantics: true),
    );
    return Semantics(
      image: true,
      label: picture.alt,
      child: maxHeight == null
          ? image
          : ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight!), child: image),
    );
  }
}

/// Görsellerin profile göre sunumu (K54) — Story kartı, soru ekranı ve okuma şemaları için:
/// - **Görsel:** tam genişlikte, Lilac-100 zeminli, Lilac-300 kenarlıklı ve gölgeli kutuda
///   öne çıkarılmış (çağıran tarafta metnin önüne konur).
/// - **Dislektik:** sade, ortalanmış, en fazla 220px (metnin altında).
/// - **Metinsel:** gizli; yerine küçük "Görseli göster" bağlantısı.
class ProfileImages extends StatefulWidget {
  const ProfileImages({super.key, required this.pictures, required this.style});

  final List<LessonPicture> pictures;
  final LearningStyle style;

  @override
  State<ProfileImages> createState() => _ProfileImagesState();
}

class _ProfileImagesState extends State<ProfileImages> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final pictures = widget.pictures;
    if (pictures.isEmpty) return const SizedBox.shrink();
    final hidden = widget.style == LearningStyle.textual && !_shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hidden)
          for (var i = 0; i < pictures.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.sm),
              child: widget.style == LearningStyle.visual
                  ? _Highlighted(picture: pictures[i])
                  : Center(child: LessonImage(picture: pictures[i], maxHeight: AppLayout.figureMaxHeight)),
            ),
        if (widget.style == LearningStyle.textual)
          Align(
            child: TextButton.icon(
              onPressed: () => setState(() => _shown = !_shown),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.grey900,
                textStyle: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
              icon: Icon(_shown ? Icons.hide_image_outlined : Icons.image_outlined),
              label: Text(_shown ? AppStrings.hideImage : AppStrings.showImage),
            ),
          ),
      ],
    );
  }
}

class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.picture});

  final LessonPicture picture;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lilac100,
        border: Border.all(color: AppColors.lilac300),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.light,
      ),
      child: LessonImage(picture: picture),
    );
  }
}
