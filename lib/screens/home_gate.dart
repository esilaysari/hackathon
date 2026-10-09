import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session.dart';
import '../strings.dart';
import '../theme/tokens.dart';
import 'auth_screen.dart';
import 'classroom/create_class_screen.dart';
import 'classroom/join_class_screen.dart';
import 'student/learning_style_test_screen.dart';
import 'student/my_lessons_screen.dart';
import 'teacher/teacher_panel_screen.dart';

/// `/` ve `/join`: oturuma göre ekran seçer (TRD §4.4). Giriş yoksa Giriş/Kayıt;
/// öğretmen → sınıfı yoksa sınıf oluşturma, varsa panel; öğrenci → test → sınıfa katılma
/// (davet linkiyle gelindiyse kod dolu) → "Derslerim".
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
    final classId = user.activeClassId;
    if (user.role == UserRole.teacher) {
      return classId == null ? const CreateClassScreen() : TeacherPanelScreen(classId: classId);
    }
    if (user.learningStyle == null) return LearningStyleTestScreen(user: user, classId: classId);
    if (classId == null || session.pendingJoinCode != null) {
      return JoinClassScreen(initialCode: session.pendingJoinCode);
    }
    return MyLessonsScreen(uid: user.uid, classId: classId);
  }
}
