import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/main.dart';

void main() {
  testWidgets('Uygulama EduSwarm başlığıyla açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const EduSwarmApp());

    expect(find.text('EduSwarm'), findsOneWidget);
  });
}
