import 'package:flutter/material.dart';

import '../../models/alert.dart';
import '../../models/student_summary.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../app_buttons.dart';

/// "Acil Müdahale" kartı (DESIGN.md §8.8): 400ms kayarak girer, bir kez hafifçe
/// büyüyüp küçülür; sürekli yanıp sönmez. PeerSwarm önerisi ve "Eşleştir" içerir.
class EmergencyAlertCard extends StatefulWidget {
  const EmergencyAlertCard({
    super.key,
    required this.alert,
    required this.now,
    required this.peer,
    required this.onMatch,
    required this.onSeen,
  });

  final EmergencyAlert alert;

  /// Panelin saniyelik sayacı; süre canlı aksın (K48).
  final DateTime now;

  /// Önerilen akran; uygun kimse yoksa öneri bölümü gizlenir.
  final StudentSummary? peer;
  final VoidCallback onMatch;
  final VoidCallback onSeen;

  @override
  State<EmergencyAlertCard> createState() => _EmergencyAlertCardState();
}

class _EmergencyAlertCardState extends State<EmergencyAlertCard> with SingleTickerProviderStateMixin {
  // İlk yarı: kayarak giriş; ikinci yarı: tek nabız.
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppDurations.teacherAlertSlideIn * 2)..forward();

  late final Animation<Offset> _slide = Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(
    CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
  );
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5));
  late final Animation<double> _pulse = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: AppDurations.alertPulseScale), weight: 1),
    TweenSequenceItem(tween: Tween(begin: AppDurations.alertPulseScale, end: 1.0), weight: 1),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final peer = widget.peer;
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.warning,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.grey900),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.alertHeadline(alert.studentName),
                  style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [
              alert.lessonTitle,
              AppStrings.learningStyleName(alert.learningStyle),
              AppStrings.stuckFor(alert.stuckFor(widget.now)),
            ].join(' · '),
            style: AppTextStyles.bodyLg,
          ),
          const Text(AppStrings.alertSystemAction, style: AppTextStyles.bodyLg),
          if (peer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.mint300,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(AppStrings.peerSuggestion(peer.displayName), style: AppTextStyles.bodyLg),
                  PrimaryButton(label: AppStrings.matchPeer, onPressed: widget.onMatch),
                ],
              ),
            ),
          ],
          // "Gördüm" küçük metin linki; Lilac-700 şeftali zeminde 4.5:1'i sağlamadığı için Grey-900.
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onSeen,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.grey900,
                textStyle: AppTextStyles.button.copyWith(decoration: TextDecoration.underline),
              ),
              child: const Text(AppStrings.alertSeen),
            ),
          ),
        ],
      ),
    );

    if (MediaQuery.of(context).disableAnimations) return card;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _pulse, child: card)),
    );
  }
}
