import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'demo_accounts.dart';
import 'firebase_options.dart';
import 'screens/demo_sign_in_gate.dart';
import 'screens/role_chooser_screen.dart';
import 'screens/student/demo_lesson_launcher.dart';
import 'screens/student/my_lessons_screen.dart';
import 'screens/teacher/teacher_panel_screen.dart';
import 'services/mock_data_service.dart';
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

  runApp(const EduSwarmApp());
}

class EduSwarmApp extends StatelessWidget {
  const EduSwarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: AppFonts.roboto, scaffoldBackgroundColor: AppColors.creamBase),
      // /#/teacher, /#/student ("Derslerim") ve /#/student/demo (doğrudan demo dersi)
      // demo hesaplarıyla otomatik giriş yapar (Faz 5'e kadar; K42, K50).
      routes: {
        '/': (_) => const RoleChooserScreen(),
        RoleChooserScreen.teacherRoute: (_) => DemoSignInGate(
              email: DemoAccounts.teacherEmail,
              builder: (_) => const TeacherPanelScreen(classId: DemoAccounts.classId),
            ),
        RoleChooserScreen.studentRoute: (_) => DemoSignInGate(
              email: DemoAccounts.studentEmail,
              builder: (uid) => MyLessonsScreen(uid: uid, classId: DemoAccounts.classId),
            ),
        RoleChooserScreen.studentDemoRoute: (_) => DemoSignInGate(
              email: DemoAccounts.studentEmail,
              builder: (uid) => DemoLessonLauncher(uid: uid, classId: DemoAccounts.classId),
            ),
      },
    );
  }
}
