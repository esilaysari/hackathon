import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../strings.dart';
import '../theme/profile_style.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';
import 'lesson_text.dart';

/// Story modu (DESIGN.md §8.5): ilerleme çubuğu, gradient kart, dokunarak ilerleme.
class StoryView extends StatelessWidget {
  const StoryView({
    super.key,
    required this.cards,
    required this.index,
    required this.style,
    required this.onAdvance,
    required this.onBack,
  });

  final List<String> cards;
  final int index;
  final LearningStyle style;
  final VoidCallback onAdvance;
  final VoidCallback onBack;

  bool get _isLast => index == cards.length - 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: _isLast ? null : onAdvance,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.storyGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.colored,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: AppDurations.storyCardSwitch,
                    child: LessonText(
                      cards[index],
                      key: ValueKey(index),
                      style: ProfileStyle.withFont(AppTextStyles.storyDisplay, style),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_isLast)
          PrimaryButton(label: AppStrings.storyBackToTask, onPressed: onBack)
        else
          Text(
            AppStrings.storyTapHint,
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
