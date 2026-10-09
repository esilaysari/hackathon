import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'demo_accounts.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'screens/demo_sign_in_gate.dart';
import 'screens/home_gate.dart';
import 'screens/student/demo_lesson_launcher.dart';
import 'screens/student/my_lessons_screen.dart';
import 'screens/teacher/teacher_panel_screen.dart';
import 'services/mock_data_service.dart';
import 'services/session.dart';
import 'strings.dart';
import 'theme/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Faz 0 kontrolü: mock veri okunabiliyor mu (beklenen: 42).
  if (kDebugMode) {
    final students = await MockDataService.loadStudents();
    debugPrint('Mock öğrenci sayısı: ${students.length}');
  }

  runApp(EduSwarmApp(session: Session()..restore()));
}

class EduSwarmApp extends StatelessWidget {
  const EduSwarmApp({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: AppFonts.roboto, scaffoldBackgroundColor: AppColors.creamBase),
        // Adres sorgu içerebildiği için (`/join?code=…`) rotalar elle çözülür; açılışta
        // yalnızca istenen ekran kurulur (altına `/` yığılmaz).
        onGenerateInitialRoutes: (name) => [_route(RouteSettings(name: name))],
        onGenerateRoute: _route,
      ),
    );
  }

  /// `/` Giriş/Kayıt ve rol yönlendirmesi; `/join?code=…` davet linki. /#/teacher,
  /// /#/student ("Derslerim") ve /#/student/demo (doğrudan demo dersi) demo hesaplarıyla
  /// otomatik giriş yapar (K42, K50).
  Route<void> _route(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? AppRoutes.home);
    final Widget page = switch (uri.path) {
      AppRoutes.teacher => DemoSignInGate(
          email: DemoAccounts.teacherEmail,
          builder: (uid) => TeacherPanelScreen(teacherId: uid, initialClassId: DemoAccounts.classId),
        ),
      AppRoutes.student => DemoSignInGate(
          email: DemoAccounts.studentEmail,
          builder: (uid) => MyLessonsScreen(uid: uid),
        ),
      AppRoutes.studentDemo => DemoSignInGate(
          email: DemoAccounts.studentEmail,
          builder: (uid) => DemoLessonLauncher(uid: uid, classId: DemoAccounts.classId),
        ),
      _ => const HomeGate(),
    };
    final code = uri.queryParameters['code'];
    if (uri.path == AppRoutes.join && code != null && code.isNotEmpty) session.pendingJoinCode = code;
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
