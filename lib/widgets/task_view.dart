import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/story_splitter.dart';
import '../strings.dart';
import '../theme/profile_style.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';
import 'lesson_text.dart';

/// Ağır Görev görünümü (DESIGN.md §8.4): okuma ekranı, sorular ve bitiş.
/// [stage] -1 → okuma, 0..n-1 → soru, n → tamamlandı.
class TaskView extends StatelessWidget {
  const TaskView({
    super.key,
    required this.lesson,
    required this.style,
    required this.stage,
    required this.selectedOption,
    required this.onSelectOption,
    required this.onNext,
    required this.onSimplify,
  });

  final Lesson lesson;
  final LearningStyle style;
  final int stage;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onNext;
  final VoidCallback onSimplify;

  bool get _isReading => stage < 0;
  bool get _isDone => stage >= lesson.questions.length;

  @override
  Widget build(BuildContext context) {
    if (_isDone) {
      return Center(
        child: Text(
          AppStrings.lessonCompleted,
          style: ProfileStyle.withFont(AppTextStyles.subheading, style),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _isReading ? _buildReading() : _buildQuestion(lesson.questions[stage]),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: _isReading
              ? AppStrings.startQuestions
              : stage == lesson.questions.length - 1
                  ? AppStrings.finishQuestions
                  : AppStrings.nextQuestion,
          onPressed: _isReading || selectedOption != null ? onNext : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: AppStrings.simplify, onPressed: onSimplify),
      ],
    );
  }

  Widget _buildReading() {
    final paragraphs = splitParagraphs(lesson.content);
    final body = ProfileStyle.body(style);
    return _Card(
      style: style,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.menu_book_rounded, color: AppColors.lilac500, size: AppSpacing.xl),
          const SizedBox(height: AppSpacing.sm),
          Text(lesson.title, style: ProfileStyle.withFont(AppTextStyles.taskTitle, style)),
          const SizedBox(height: AppSpacing.md),
          for (final p in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: style == LearningStyle.visual
                  ? _VisualParagraph(text: p, style: body)
                  : LessonText(p, style: body),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    final body = ProfileStyle.body(style);
    return _Card(
      style: style,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.questionProgress(stage + 1, lesson.questions.length),
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          LessonText(question.text, style: body),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionTile(
                text: question.options[i],
                textStyle: body,
                selected: selectedOption == i,
                onTap: () => onSelectOption(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.style, required this.child});

  final LearningStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: ProfileStyle.cardColor(style),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: child,
    );
  }
}

/// Görsel profil: her paragraf ikonlu ayrı bir kart (MEMORY K18).
class _VisualParagraph extends StatelessWidget {
  const _VisualParagraph({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        border: Border.all(color: AppColors.lilac300),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.lilac500),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: LessonText(text, style: style)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.textStyle,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final TextStyle textStyle;
  final bool selected;
  final VoidCallback onTap;

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
          child: LessonText(text, style: textStyle),
        ),
      ),
    );
  }
}
