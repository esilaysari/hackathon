import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/services/telemetry.dart';

// testWidgets sahte zamanla çalışır; tester.pump ile saniyeler anında ilerletilir.
void main() {
  const threshold = Duration(seconds: 10);

  testWidgets('Eşiğin yarısında Dikkat, eşikte Kritik olur', (tester) async {
    final states = <FocusState>[];
    final tracker = FocusTracker(onStateChanged: states.add)..start(threshold);

    await tester.pump(const Duration(seconds: 4));
    expect(tracker.state, FocusState.focused);
    await tester.pump(const Duration(seconds: 1));
    expect(tracker.state, FocusState.attention);
    await tester.pump(const Duration(seconds: 5));
    expect(tracker.state, FocusState.critical);
    expect(states, [FocusState.attention, FocusState.critical]);
    tracker.dispose();
  });

  testWidgets('Etkileşim sayacı sıfırlar ve durumu Odakta yapar', (tester) async {
    final tracker = FocusTracker(onStateChanged: (_) {})..start(threshold);

    await tester.pump(const Duration(seconds: 6));
    expect(tracker.state, FocusState.attention);
    tracker.recordInteraction();
    expect(tracker.state, FocusState.focused);
    expect(tracker.interactionCount, 1);
    tracker.recordInteraction(countable: false); // Kaydırma: sıfırlar ama sayılmaz.
    expect(tracker.interactionCount, 1);
    await tester.pump(const Duration(seconds: 9));
    expect(tracker.state, FocusState.attention); // Kritik'e 10 sn daha var.
    await tester.pump(const Duration(seconds: 1));
    expect(tracker.state, FocusState.critical);
    tracker.dispose();
  });

  testWidgets('Durdurulan sayaç durum üretmez, etkileşimleri saymaz', (tester) async {
    final tracker = FocusTracker(onStateChanged: (_) {})..start(threshold);
    tracker.stop();
    tracker.recordInteraction();

    await tester.pump(const Duration(seconds: 20));
    expect(tracker.state, FocusState.focused);
    expect(tracker.interactionCount, 0);
    expect(tracker.isRunning, isFalse);
  });
}
