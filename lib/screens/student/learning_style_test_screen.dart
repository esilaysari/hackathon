import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learning_style_test.dart';
import '../../services/content_service.dart';
import '../../services/firestore_service.dart';
import '../../services/session.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/option_tile.dart';

/// Öğrenme stili testi ve sonuç ekranı (DESIGN.md §8.2). Sorular, ölçek, aşama etiketleri
/// ve sonuç metinleri `learning_style_test.json`'dan aynen gelir.
class LearningStyleTestScreen extends StatefulWidget {
  const LearningStyleTestScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<LearningStyleTestScreen> createState() => _LearningStyleTestScreenState();
}

class _LearningStyleTestScreenState extends State<LearningStyleTestScreen> {
  late final Future<LearningStyleTest> _test = ContentService.loadLearningStyleTest();

  /// null → giriş notu; 0..n-1 → soru.
  int? _index;
  final Map<String, int> _answers = {};
  TestResult? _result;
  bool _saving = false;
  String? _error;

  Future<void> _finish(LearningStyleTest test) async {
    final result = test.score(_answers);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await FirestoreService.saveTestResult(widget.user.uid, widget.user.classIds, widget.user.fullName, result);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      debugPrint('Test sonucu kaydedilemedi: $e');
      if (mounted) setState(() => _error = AppStrings.testSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        backgroundColor: AppColors.creamBase,
        foregroundColor: AppColors.grey900,
        title: const Text(AppStrings.testTitle, style: AppTextStyles.appBarTitle),
      ),
      body: FutureBuilder(
        future: _test,
        builder: (context, snapshot) {
          final test = snapshot.data;
          if (test == null) {
            final text = snapshot.hasError ? AppStrings.testLoadFailed(snapshot.error!) : AppStrings.testLoading;
            return Center(child: Text(text, style: AppTextStyles.bodyLg));
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppLayout.studentMaxWidth),
                child: switch ((_result, _index)) {
                  (final TestResult result, _) => _ResultView(test: test, result: result),
                  (_, null) => _intro(test),
                  (_, final int i) => _question(test, i),
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _intro(LearningStyleTest test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(child: Text(test.intro, style: AppTextStyles.bodyLg)),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(label: AppStrings.testStart, onPressed: () => setState(() => _index = 0)),
      ],
    );
  }

  Widget _question(LearningStyleTest test, int i) {
    final question = test.questions[i];
    final total = test.questions.length;
    final isLast = i == total - 1;
    final selected = _answers[question.id];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressHeader(test: test, number: i + 1),
        const SizedBox(height: AppSpacing.md),
        SurfaceCard(child: Text(question.text, style: AppTextStyles.bodyLg)),
        const SizedBox(height: AppSpacing.md),
        for (final option in test.scale) ...[
          OptionTile(
            text: '${option.icon ?? question.fullIcon}  ${option.label}',
            textStyle: AppTextStyles.bodyLg,
            selected: selected == option.value,
            onTap: _saving ? null : () => setState(() => _answers[question.id] = option.value),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          WarningNote(_error!),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: isLast ? AppStrings.testFinish : AppStrings.testNext,
          onPressed: selected == null || _saving
              ? null
              : () => isLast ? _finish(test) : setState(() => _index = i + 1),
        ),
        if (i > 0)
          TextButton(
            onPressed: _saving ? null : () => setState(() => _index = i - 1),
            child: Text(AppStrings.testBack, style: AppTextStyles.button.copyWith(color: AppColors.lilac700)),
          ),
      ],
    );
  }
}

/// "Soru 5 / 12 · %42", aşama etiketi, ilerleme çubuğu ve "7 soru kaldı".
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.test, required this.number});

  final LearningStyleTest test;
  final int number;

  @override
  Widget build(BuildContext context) {
    final total = test.questions.length;
    final fraction = number / total;
    final remaining = total - number;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(AppStrings.questionProgress(number, total), style: AppTextStyles.button.copyWith(color: AppColors.grey900)),
            const Spacer(),
            Text(AppStrings.testPercent((fraction * 100).round()), style: AppTextStyles.button.copyWith(color: AppColors.grey900)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: fraction),
            duration: AppDurations.storyCardSwitch,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: AppLayout.storyProgressHeight,
              color: AppColors.lilac700,
              backgroundColor: AppColors.lilac100,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: AppColors.mint300, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm / 2),
                child: Text(test.stageLabel(number), style: AppTextStyles.caption.copyWith(color: AppColors.grey900)),
              ),
            ),
            const Spacer(),
            if (remaining > 0) Text(AppStrings.testRemaining(remaining), style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

/// Sonuç: öğrencinin stili, açıldıysa okuma desteği kartı, dipnot ve "Derslerime Git".
class _ResultView extends StatelessWidget {
  const _ResultView({required this.test, required this.result});

  final LearningStyleTest test;
  final TestResult result;

  @override
  Widget build(BuildContext context) {
    final style = test.results[result.studentStyle]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AppStrings.testResultTitle, style: AppTextStyles.subheading, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.md),
        _ResultCard(text: style, color: AppColors.creamSurface, titleStyle: AppTextStyles.taskTitle),
        if (result.readingSupport) ...[
          const SizedBox(height: AppSpacing.md),
          _ResultCard(
            text: test.readingSupport,
            color: AppColors.mint300,
            titleStyle: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(test.footnote, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: AppStrings.goToMyLessons,
          onPressed: () {
            context.read<Session>().applyTestResult(result);
            // Derslerim'den "yeniden belirle" ile açıldıysa geri dön.
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.text, required this.color, required this.titleStyle});

  final TestResultText text;
  final Color color;
  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.icon, style: AppTextStyles.storyDisplay),
          const SizedBox(height: AppSpacing.sm),
          Text(text.title, style: titleStyle),
          const SizedBox(height: AppSpacing.sm),
          Text(text.description, style: AppTextStyles.bodyLg),
        ],
      ),
    );
  }
}
