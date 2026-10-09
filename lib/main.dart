import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/student/lesson_screen.dart';
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
      // Faz 5'te giriş ekranının arkasına alınacak.
      home: const LessonScreen(),
    );
  }
}
