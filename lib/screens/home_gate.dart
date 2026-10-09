import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session.dart';
import '../strings.dart';
import '../theme/tokens.dart';
import 'auth_screen.dart';
import 'classroom/join_class_screen.dart';
import 'student/learning_style_test_screen.dart';
import 'student/my_lessons_screen.dart';
import 'teacher/teacher_panel_screen.dart';

/// `/` ve `/join`: oturuma göre ekran seçer (TRD §4.4). Giriş yoksa Giriş/Kayıt;
/// öğretmen → panel (sınıfı yoksa panel "İlk sınıfını oluştur"u gösterir); öğrenci → test →
/// hiç sınıfı yoksa ya da davet linkiyle gelindiyse sınıfa katılma → "Derslerim" (K52).
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
    if (user.role == UserRole.teacher) return TeacherPanelScreen(teacherId: user.uid);
    if (user.learningStyle == null) return LearningStyleTestScreen(user: user);
    if (user.classIds.isEmpty || session.pendingJoinCode != null) {
      return JoinClassScreen(uid: user.uid, initialCode: session.pendingJoinCode);
    }
    return MyLessonsScreen(uid: user.uid);
  }
}
