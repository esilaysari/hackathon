import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/tokens.dart';
import '../widgets/app_buttons.dart';

/// Geçici giriş sayfası (Faz 5'te Giriş/Kayıt ile değişecek): iki demo rolüne bağlantı.
class RoleChooserScreen extends StatelessWidget {
  const RoleChooserScreen({super.key});

  static const teacherRoute = '/teacher';
  static const studentRoute = '/student'; // "Derslerim"
  static const studentDemoRoute = '/student/demo'; // Doğrudan demo dersi (Altın Senaryo)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.studentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(AppStrings.appTitle, style: AppTextStyles.taskTitle, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: AppStrings.roleTeacher,
                  onPressed: () => Navigator.pushNamed(context, teacherRoute),
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: AppStrings.roleStudent,
                  onPressed: () => Navigator.pushNamed(context, studentRoute),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
