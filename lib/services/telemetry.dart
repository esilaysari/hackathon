import 'dart:async';

import 'package:flutter/foundation.dart';

/// Odak durumu (MEMORY K17).
enum FocusState { focused, attention, critical }

/// Hareketsizlik sayacı (TRD §4.1). Eşiğin yarısında Dikkat, eşikte Kritik olur;
/// her etkileşim sayacı sıfırlar. Ham telemetri saklanmaz, yalnızca etkileşim sayısı (K23).
class FocusTracker {
  FocusTracker({required this.onStateChanged});

  final void Function(FocusState state) onStateChanged;

  FocusState _state = FocusState.focused;
  Duration? _threshold;
  Timer? _attentionTimer;
  Timer? _criticalTimer;
  int interactionCount = 0;

  FocusState get state => _state;
  bool get isRunning => _threshold != null;

  /// Sayacı verilen eşikle (yeniden) başlatır; durum Odakta olur.
  void start(Duration threshold) {
    _threshold = threshold;
    _setState(FocusState.focused);
    _schedule();
  }

  /// Sayacı durdurur (ör. Story modu açıkken). Durum olduğu gibi kalır.
  void stop() {
    _threshold = null;
    _cancelTimers();
  }

  /// Sayacı sıfırlar. Kaydırma gibi saniyede onlarca olay üreten hareketler
  /// [countable] false ile gelir: sayacı sıfırlar ama etkileşim sayısını şişirmez.
  void recordInteraction({bool countable = true}) {
    if (!isRunning) return;
    if (countable) interactionCount++;
    _setState(FocusState.focused);
    _schedule();
  }

  void dispose() => _cancelTimers();

  void _schedule() {
    _cancelTimers();
    final threshold = _threshold!;
    _attentionTimer = Timer(threshold ~/ 2, () => _setState(FocusState.attention));
    _criticalTimer = Timer(threshold, () => _setState(FocusState.critical));
  }

  void _cancelTimers() {
    _attentionTimer?.cancel();
    _criticalTimer?.cancel();
  }

  void _setState(FocusState next) {
    if (next == _state) return;
    _state = next;
    debugPrint('Odak durumu: ${next.name} (etkileşim: $interactionCount)');
    onStateChanged(next);
  }
}
