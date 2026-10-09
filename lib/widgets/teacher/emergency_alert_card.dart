import 'package:flutter/material.dart';

import '../../models/alert.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../app_buttons.dart';

/// "Acil Müdahale" kartı (DESIGN.md §8.8): 400ms kayarak girer, bir kez hafifçe
/// büyüyüp küçülür; sürekli yanıp sönmez. PeerSwarm önerisi Faz 4'te eklenecek.
class EmergencyAlertCard extends StatefulWidget {
  const EmergencyAlertCard({super.key, required this.alert, required this.onSeen});

  final EmergencyAlert alert;
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
              AppStrings.shortDuration(DateTime.now().difference(alert.createdAt)),
            ].join(' · '),
            style: AppTextStyles.bodyLg,
          ),
          const Text(AppStrings.alertSystemAction, style: AppTextStyles.bodyLg),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: SecondaryButton(label: AppStrings.alertSeen, onPressed: widget.onSeen),
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
