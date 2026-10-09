import 'dart:async';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/socratic.dart';
import '../services/socratic_session.dart';
import '../strings.dart';
import '../theme/profile_style.dart';
import '../theme/tokens.dart';
import 'app_buttons.dart';
import 'code_block.dart';
import 'lesson_text.dart';
import 'option_tile.dart';

/// Sokratik Rehber baloncuğu (DESIGN.md §8.6). Asla doğrudan cevap vermez.
/// Kontrol sorusu doğru cevaplanınca `solved` + `solvedNext` mesajlarını kısa süre
/// gösterir, sonra kapanır. Yeni bir zincir için yeni bir `key` verilmelidir.
class SocraticBubble extends StatefulWidget {
  const SocraticBubble({
    super.key,
    required this.chain,
    required this.messages,
    required this.style,
    this.onSolved,
    this.appearDelay = Duration.zero,
  });

  final SocraticChain chain;
  final SocraticMessages messages;
  final LearningStyle style;
  final VoidCallback? onSolved;

  /// Story modunda Morphing bittikten sonra belirmesi için.
  final Duration appearDelay;

  @override
  State<SocraticBubble> createState() => _SocraticBubbleState();
}

class _SocraticBubbleState extends State<SocraticBubble> with SingleTickerProviderStateMixin {
  late final SocraticSession _session = SocraticSession(widget.chain);
  late final AnimationController _appear =
      AnimationController(vsync: this, duration: AppDurations.socraticBubble);
  Timer? _closeTimer;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.appearDelay, () {
      if (mounted) _appear.forward();
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _appear.dispose();
    super.dispose();
  }

  void _solved() {
    widget.onSolved?.call();
    _closeTimer = Timer(AppDurations.socraticSolvedVisible, () async {
      if (!mounted) return;
      await _appear.reverse();
      if (mounted) setState(() => _closed = true);
    });
  }

  void _answer(int index) {
    final correct = _session.answerCheck(index);
    setState(() {});
    if (correct) _solved();
  }

  @override
  Widget build(BuildContext context) {
    if (_closed) return const SizedBox.shrink();
    final body = ProfileStyle.body(widget.style);
    final bubble = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: ProfileStyle.cardColor(widget.style),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_alt_rounded, color: AppColors.lilac500),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _buildContent(body)),
        ],
      ),
    );
    return FadeTransition(
      opacity: _appear,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(_appear),
        child: bubble,
      ),
    );
  }

  Widget _buildContent(TextStyle body) {
    final messages = widget.messages;
    return switch (_session.step) {
      SocraticStep.hint => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_session.lastCheckWrong) Text(messages.wrongCheck, style: body),
            LessonText(_session.currentHint, style: body),
            const SizedBox(height: AppSpacing.sm),
            _buttons(showNotUnderstood: true),
          ],
        ),
      SocraticStep.peerSuggestion => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(messages.hintsExhausted, style: body),
            const SizedBox(height: AppSpacing.sm),
            _buttons(showNotUnderstood: false),
          ],
        ),
      SocraticStep.check => _buildCheck(_session.chain.check!, body),
      SocraticStep.solved => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(messages.solved, style: body.copyWith(fontWeight: FontWeight.w700)),
            Text(messages.solvedNext, style: body),
          ],
        ),
    };
  }

  Widget _buildCheck(CheckQuestion check, TextStyle body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonText(check.text, style: body),
        if (check.code != null) ...[
          const SizedBox(height: AppSpacing.sm),
          CodeBlock(check.code!),
        ],
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < check.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OptionTile(
              text: check.options[i],
              textStyle: body,
              isCode: check.optionsAreCode[i],
              selected: false,
              onTap: () => _answer(i),
            ),
          ),
      ],
    );
  }

  Widget _buttons({required bool showNotUnderstood}) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        if (showNotUnderstood)
          SecondaryButton(
            label: AppStrings.notUnderstood,
            onPressed: () => setState(_session.notUnderstood),
          ),
        PrimaryButton(
          label: AppStrings.understood,
          onPressed: () {
            setState(_session.understood);
            if (_session.step == SocraticStep.solved) _solved();
          },
        ),
      ],
    );
  }
}
