import 'package:flutter/material.dart';

import '../../dev_config.dart';
import '../../models/lesson.dart';
import '../../services/content_service.dart';
import '../../services/story_splitter.dart';
import '../../services/telemetry.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/story_view.dart';
import '../../widgets/task_view.dart';

/// Öğrenci ders ekranı: okuma → sorular; Kritik'te otomatik Morphing ile Story modu
/// (ROADMAP Faz 1–2, DESIGN.md §8.4–8.5). Firestore bağlantısı Faz 3'te eklenecek.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final LearningStyle _style = DevConfig.demoLearningStyle;
  late final FocusTracker _tracker = FocusTracker(onStateChanged: _onFocusChanged);

  Lesson? _lesson;
  List<String> _storyCards = const [];
  String _morphMessage = '';

  int _stage = -1; // -1 okuma, 0..n-1 soru, n tamamlandı.
  final Map<int, int> _answers = {};
  bool _storyMode = false;
  int _storyIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lesson = await ContentService.loadDemoLesson();
    final messages = await ContentService.loadSupportMessages();
    if (!mounted) return;
    setState(() {
      _lesson = lesson;
      _storyCards = [lesson.title, ...splitIntoStoryCards(lesson.content)];
      _morphMessage = messages['morph']!.first;
    });
    _startTracking();
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  // --- Telemetri ---------------------------------------------------------

  Duration? get _currentThreshold {
    final lesson = _lesson!;
    if (_stage >= lesson.questions.length) return null; // Ders bitti, sayaç yok.
    if (DevConfig.presentationMode) return AppThresholds.presentationMode;
    if (_stage < 0) return AppThresholds.reading;
    return switch (lesson.questions[_stage].type) {
      QuestionType.verbalVisual => AppThresholds.verbalVisual,
      QuestionType.computational => AppThresholds.computational,
    };
  }

  void _startTracking() {
    final threshold = _currentThreshold;
    if (threshold == null) {
      _tracker.stop();
    } else {
      _tracker.start(threshold);
    }
  }

  void _onFocusChanged(FocusState state) {
    if (state == FocusState.critical && !_storyMode) _enterStory(automatic: true);
  }

  void _onInteraction() => _tracker.recordInteraction();

  // --- Akış --------------------------------------------------------------

  void _enterStory({required bool automatic}) {
    _tracker.stop();
    debugPrint('Story moduna geçildi (${automatic ? 'otomatik — Kritik' : 'elle — Basitleştir'})');
    setState(() {
      _storyMode = true;
      _storyIndex = 0;
    });
    if (automatic) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(_morphMessage, style: AppTextStyles.bodyLg),
        ),
      );
    }
  }

  void _exitStory() {
    debugPrint('Story modundan çıkıldı, sayaç sıfırlandı');
    setState(() => _storyMode = false);
    _startTracking();
  }

  void _next() {
    setState(() => _stage++);
    _startTracking();
  }

  // --- Görünüm -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        backgroundColor: AppColors.creamBase,
        title: const Text(AppStrings.appTitle, style: AppTextStyles.appBarTitle),
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (_, _) {
          _onInteraction();
          return KeyEventResult.ignored;
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _onInteraction(),
          onPointerSignal: (_) => _tracker.recordInteraction(countable: false),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppLayout.studentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: lesson == null
                    ? const Center(child: Text(AppStrings.lessonLoading, style: AppTextStyles.bodyLg))
                    : AnimatedSwitcher(
                        duration: AppDurations.morphing,
                        transitionBuilder: (child, animation) {
                          final faded = FadeTransition(opacity: animation, child: child);
                          if (reduceMotion) return faded;
                          return ScaleTransition(
                            scale: Tween(begin: AppDurations.morphScaleBegin, end: 1.0).animate(animation),
                            child: faded,
                          );
                        },
                        child: _storyMode
                            ? StoryView(
                                key: const ValueKey('story'),
                                cards: _storyCards,
                                index: _storyIndex,
                                style: _style,
                                onAdvance: () => setState(() => _storyIndex++),
                                onBack: _exitStory,
                              )
                            : TaskView(
                                key: const ValueKey('task'),
                                lesson: lesson,
                                style: _style,
                                stage: _stage,
                                selectedOption: _answers[_stage],
                                onSelectOption: (i) => setState(() => _answers[_stage] = i),
                                onNext: _next,
                                onSimplify: () => _enterStory(automatic: false),
                              ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
