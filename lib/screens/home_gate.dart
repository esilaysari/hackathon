import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session.dart';
import '../strings.dart';
import '../theme/tokens.dart';
import 'auth_screen.dart';
import 'student/learning_style_test_screen.dart';
import 'student/my_lessons_screen.dart';
import 'teacher/teacher_panel_screen.dart';

/// `/`: oturuma göre ekran seçer (TRD §4.4). Giriş yoksa Giriş/Kayıt; öğretmen → panel;
/// öğrenci testi çözmediyse → test, çözdüyse → "Derslerim".
class HomeGate extends StatelessWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final user = session.user;
    if (session.restoring) {
      return const Scaffold(
        backgroundColor: AppColors.creamBase,
        body: Center(child: Text(AppStrings.signingIn, style: AppTextStyles.bodyLg)),
      );
    }
    if (user == null) return const AuthScreen();
    if (user.role == UserRole.teacher) return TeacherPanelScreen(classId: session.activeClassId);
    if (user.learningStyle == null) return LearningStyleTestScreen(user: user, classId: session.activeClassId);
    return MyLessonsScreen(uid: user.uid, classId: session.activeClassId);
  }
}
