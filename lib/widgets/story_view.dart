import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../strings.dart';
import '../theme/profile_style.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';
import 'code_block.dart';
import 'lesson_image.dart';
import 'lesson_text.dart';

/// Story modu (DESIGN.md §8.5): ilerleme çubuğu, gradient kart, dokunarak ilerleme;
/// kartın altında Sokratik baloncuk (§8.6). Baloncuk uzayabildiği için görünüm kayar.
class StoryView extends StatelessWidget {
  const StoryView({
    super.key,
    required this.cards,
    this.images = const {},
    required this.index,
    required this.style,
    required this.onAdvance,
    required this.onBack,
    this.socraticBubble,
    this.showBackButton = false,
  });

  final List<StoryCard> cards;

  /// Yüklenen dersin slayt görselleri ([Lesson.images]).
  final Map<String, Uint8List> images;
  final int index;
  final LearningStyle style;
  final VoidCallback onAdvance;
  final VoidCallback onBack;
  final Widget? socraticBubble;

  /// Sokratik kontrol sorusu çözüldüyse son karta gelmeden de "Soruya Dön" görünür.
  final bool showBackButton;

  bool get _isLast => index == cards.length - 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgress(),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight * AppLayout.storyCardHeightFactor),
              child: _buildCard(),
            ),
            if (socraticBubble != null) ...[
              const SizedBox(height: AppSpacing.md),
              socraticBubble!,
            ],
            const SizedBox(height: AppSpacing.md),
            if (_isLast || showBackButton) PrimaryButton(label: AppStrings.storyBackToTask, onPressed: onBack),
            if (!_isLast)
              Padding(
                padding: EdgeInsets.only(top: showBackButton ? AppSpacing.sm : 0),
                child: Text(
                  AppStrings.storyTapHint,
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++)
          Expanded(
            child: Container(
              height: AppLayout.storyProgressHeight,
              margin: EdgeInsets.only(right: i == cards.length - 1 ? 0 : AppLayout.storyProgressGap),
              decoration: BoxDecoration(
                color: i <= index ? AppColors.lilac700 : AppColors.lilac100,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard() {
    final card = cards[index];
    final pictures = LessonPicture.ofCard(card, images);
    // Görsel profilde görsel metnin önünde ve öne çıkarılmış; diğerlerinde metnin altında (K54).
    final imagesFirst = style == LearningStyle.visual;
    final imageView = ProfileImages(pictures: pictures, style: style);
    return GestureDetector(
      onTap: _isLast ? null : onAdvance,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.storyGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.colored,
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.storyCardSwitch,
          child: Column(
            key: ValueKey(index),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagesFirst && pictures.isNotEmpty) ...[imageView, const SizedBox(height: AppSpacing.md)],
              if (card.text.isNotEmpty)
                LessonText(
                  card.text,
                  style: ProfileStyle.withFont(AppTextStyles.storyDisplay, style),
                  textAlign: TextAlign.center,
                ),
              if (card.subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  card.subtitle!,
                  style: ProfileStyle.withFont(AppTextStyles.storySubtitle, style),
                  textAlign: TextAlign.center,
                ),
              ],
              if (!imagesFirst && pictures.isNotEmpty) ...[const SizedBox(height: AppSpacing.md), imageView],
              if (card.code != null) ...[
                const SizedBox(height: AppSpacing.md),
                CodeBlock(card.code!, style: AppTextStyles.storyCode),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
