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
        // `/` Giriş/Kayıt ve rol yönlendirmesi. /#/teacher, /#/student ("Derslerim") ve
        // /#/student/demo (doğrudan demo dersi) demo hesaplarıyla otomatik giriş yapar (K42, K50).
        routes: {
          AppRoutes.home: (_) => const HomeGate(),
          AppRoutes.teacher: (_) => DemoSignInGate(
                email: DemoAccounts.teacherEmail,
                builder: (_) => const TeacherPanelScreen(classId: DemoAccounts.classId),
              ),
          AppRoutes.student: (_) => DemoSignInGate(
                email: DemoAccounts.studentEmail,
                builder: (uid) => MyLessonsScreen(uid: uid, classId: DemoAccounts.classId),
              ),
          AppRoutes.studentDemo: (_) => DemoSignInGate(
                email: DemoAccounts.studentEmail,
                builder: (uid) => DemoLessonLauncher(uid: uid, classId: DemoAccounts.classId),
              ),
        },
      ),
    );
  }
}
