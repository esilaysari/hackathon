import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/main.dart';
import 'package:eduswarm/services/session.dart';
import 'package:eduswarm/strings.dart';

/// Firebase'e dokunmayan oturum: geri yükleme bitmiş, giriş yok.
class _SignedOutSession extends Session {
  @override
  bool get restoring => false;
}

void main() {
  testWidgets('Giriş yoksa Giriş/Kayıt kartı ve demo butonları görünür', (WidgetTester tester) async {
    await tester.pumpWidget(EduSwarmApp(session: _SignedOutSession()));

    expect(find.text(AppStrings.appTitle), findsOneWidget);
    expect(find.text(AppStrings.tabRegister), findsOneWidget);
    expect(find.text(AppStrings.demoTeacher), findsOneWidget);
    expect(find.text(AppStrings.demoStudent), findsOneWidget);

    await tester.tap(find.text(AppStrings.tabRegister));
    await tester.pump();
    expect(find.text(AppStrings.kvkkConsent), findsOneWidget);
    expect(find.text(AppStrings.roleStudentOption), findsOneWidget);
  });
}
