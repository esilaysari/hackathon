import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/socratic.dart';
import '../services/story_splitter.dart';
import '../strings.dart';
import '../theme/profile_style.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';
import 'code_block.dart';
import 'lesson_image.dart';
import 'lesson_text.dart';
import 'option_tile.dart';
import 'socratic_bubble.dart';

/// Ağır Görev görünümü (DESIGN.md §8.4): okuma ekranı, sorular ve bitiş.
/// [stage] -1 → okuma, 0..n-1 → soru, n → tamamlandı.
/// Soru akışı: şık seç → "Kontrol Et" → geri bildirim → "İleri" (MEMORY K45).
class TaskView extends StatelessWidget {
  const TaskView({
    super.key,
    required this.lesson,
    required this.style,
    required this.stage,
    required this.selectedOption,
    required this.checkResult,
    required this.correctCount,
    required this.hintChain,
    required this.socraticMessages,
    required this.onSelectOption,
    required this.onCheck,
    required this.onNext,
    required this.onOpenHint,
    required this.onSimplify,
  });

  final Lesson lesson;
  final LearningStyle style;
  final int stage;
  final int? selectedOption;

  /// null → henüz kontrol edilmedi; true/false → son kontrolün sonucu.
  final bool? checkResult;

  /// İlk denemede doğru cevaplanan soru sayısı (bitiş özeti için).
  final int correctCount;

  /// Yanlış cevaptan sonra "İpucu al" ile açılan zincir; null → baloncuk kapalı.
  final SocraticChain? hintChain;
  final SocraticMessages socraticMessages;

  final ValueChanged<int> onSelectOption;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final VoidCallback onOpenHint;
  final VoidCallback onSimplify;

  bool get _isReading => stage < 0;
  bool get _isDone => stage >= lesson.questions.length;
  bool get _isLastQuestion => stage == lesson.questions.length - 1;

  @override
  Widget build(BuildContext context) {
    if (_isDone) return _buildDone();

    final String primaryLabel;
    final VoidCallback? primaryAction;
    if (_isReading) {
      primaryLabel = AppStrings.startQuestions;
      primaryAction = onNext;
    } else if (checkResult == null) {
      primaryLabel = AppStrings.checkAnswer;
      primaryAction = selectedOption == null ? null : onCheck;
    } else {
      primaryLabel = _isLastQuestion ? AppStrings.finishQuestions : AppStrings.nextQuestion;
      primaryAction = onNext;
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
        PrimaryButton(label: primaryLabel, onPressed: primaryAction),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: AppStrings.simplify, onPressed: onSimplify),
      ],
    );
  }

  Widget _buildDone() {
    final heading = ProfileStyle.withFont(AppTextStyles.subheading, style);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppStrings.lessonCompleted, style: heading, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.scoreSummary(correctCount, lesson.questions.length),
            style: ProfileStyle.body(style),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
          for (var i = 0; i < paragraphs.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              // Öğretmenin Markdown'ındaki `#` başlıkları kalın başlık olarak gösterilir.
              child: paragraphs[i].startsWith('#')
                  ? LessonText(
                      paragraphs[i].replaceFirst(RegExp(r'^#+\s*'), ''),
                      style: body.copyWith(fontWeight: FontWeight.w700),
                    )
                  : style == LearningStyle.visual
                      ? _VisualParagraph(text: paragraphs[i], style: body)
                      : LessonText(paragraphs[i], style: body),
            ),
            // Şemalar ilgili paragrafın hemen altında (K50).
            for (final figure in lesson.figures.where((f) => f.afterParagraph == i))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: LessonFigureView(figure: figure, style: style),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    final body = ProfileStyle.body(style);
    final total = lesson.questions.length;
    final chain = hintChain;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          style: style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.questionProgress(stage + 1, total), style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.sm),
              _ProgressBar(value: (stage + 1) / total),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.questionEncouragement(stage, total),
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: AppSpacing.md),
              LessonText(question.text, style: body),
              if (question.code != null) ...[
                const SizedBox(height: AppSpacing.sm),
                CodeBlock(question.code!),
              ],
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < question.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OptionTile(
                    text: question.options[i],
                    textStyle: body,
                    isCode: question.optionsAreCode[i],
                    selected: selectedOption == i,
                    // Doğru cevaptan sonra şık değiştirilmez.
                    onTap: checkResult == true ? null : () => onSelectOption(i),
                  ),
                ),
              if (checkResult != null) _buildFeedback(checkResult!, body),
            ],
          ),
        ),
        if (chain != null) ...[
          const SizedBox(height: AppSpacing.md),
          SocraticBubble(
            key: ValueKey('hint_${question.id}'),
            chain: chain,
            messages: socraticMessages,
            style: style,
          ),
        ],
      ],
    );
  }

  /// Doğru: Mint-300 "Doğru!". Yanlış: Warning-Soft "Tekrar düşünelim" + ipucu; doğru cevap gösterilmez.
  Widget _buildFeedback(bool correct, TextStyle body) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: correct ? AppColors.mint300 : AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              correct ? AppStrings.answerCorrect : AppStrings.answerWrong,
              style: body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (!correct && hintChain == null)
            TextButton(
              onPressed: onOpenHint,
              style: TextButton.styleFrom(foregroundColor: AppColors.grey900, textStyle: AppTextStyles.button),
              child: const Text(AppStrings.askHint),
            ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: LinearProgressIndicator(
        value: value,
        minHeight: AppLayout.storyProgressHeight,
        color: AppColors.lilac700,
        backgroundColor: AppColors.lilac100,
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
