import 'package:flutter/material.dart';

import '../../services/content_service.dart';
import '../../services/lesson_repository.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import 'lesson_screen.dart';

/// `/#/student/demo`: Altın Senaryo için `index.json`'daki demo dersini doğrudan açar (K50).
class DemoLessonLauncher extends StatefulWidget {
  const DemoLessonLauncher({super.key, required this.uid, required this.classId});

  final String uid;
  final String classId;

  @override
  State<DemoLessonLauncher> createState() => _DemoLessonLauncherState();
}

class _DemoLessonLauncherState extends State<DemoLessonLauncher> {
  late final Future<LessonScreen> _screen = _build();

  Future<LessonScreen> _build() async {
    final catalog = await ContentService.loadCatalog();
    final lesson = await LessonRepository.load(catalog.demoLesson, widget.classId);
    return LessonScreen(
      uid: widget.uid,
      classId: widget.classId,
      lesson: lesson,
      socraticMessages: catalog.socraticMessages,
      fallbackChain: catalog.defaultSocratic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _screen,
      builder: (context, snapshot) {
        if (snapshot.hasData) return snapshot.data!;
        final text = snapshot.hasError ? AppStrings.lessonOpenFailed(snapshot.error!) : AppStrings.lessonLoading;
        return Scaffold(
          backgroundColor: AppColors.creamBase,
          body: Center(child: Text(text, style: AppTextStyles.bodyLg)),
        );
      },
    );
  }
}
