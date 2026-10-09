import 'dart:async';

import 'package:flutter/material.dart';

import '../../dev_config.dart';
import '../../models/lesson.dart';
import '../../services/content_service.dart';
import '../../services/firestore_service.dart';
import '../../services/story_splitter.dart';
import '../../services/telemetry.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/story_view.dart';
import '../../widgets/task_view.dart';

/// Öğrenci ders ekranı: okuma → sorular; Kritik'te otomatik Morphing ile Story modu
/// (DESIGN.md §8.4–8.5). Durum geçişleri ve uyarılar Firestore'a yazılır (ROADMAP Faz 3).
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.uid, required this.classId});

  final String uid;
  final String classId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final FocusTracker _tracker = FocusTracker(onStateChanged: _onFocusChanged);
  StreamSubscription<Object?>? _classSubscription;

  Lesson? _lesson;
  LearningStyle _style = LearningStyle.textual;
  String _fullName = '';
  List<String> _storyCards = const [];
  String _morphMessage = '';
  bool _presentationMode = false;

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
    final profile = await FirestoreService.loadProfile(widget.uid);
    if (!mounted) return;
    setState(() {
      _lesson = lesson;
      _style = DevConfig.learningStyleOverride ?? profile.learningStyle ?? LearningStyle.textual;
      _fullName = profile.fullName;
      _storyCards = [lesson.title, ...splitIntoStoryCards(lesson.content)];
      _morphMessage = messages['morph']!.first;
    });
    await FirestoreService.startLesson(widget.classId, widget.uid, lesson);
    _classSubscription = FirestoreService.watchClass(widget.classId).listen((snapshot) {
      final enabled = snapshot.data()?['presentationMode'] == true;
      if (enabled == _presentationMode) return;
      _presentationMode = enabled;
      debugPrint('Sunum Modu: $enabled');
      if (_tracker.isRunning) _startTracking(); // Yeni eşik anında geçerli olsun (K29).
    });
    _startTracking();
  }

  @override
  void dispose() {
    _classSubscription?.cancel();
    _tracker.dispose();
    super.dispose();
  }

  // --- Telemetri ---------------------------------------------------------

  Duration? get _currentThreshold {
    final lesson = _lesson!;
    if (_stage >= lesson.questions.length) return null; // Ders bitti, sayaç yok.
    if (_presentationMode) return AppThresholds.presentationMode;
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
      debugPrint('Sayaç başladı: eşik ${threshold.inSeconds} sn');
      _tracker.start(threshold);
    }
  }

  void _onFocusChanged(FocusState state) {
    if (state == FocusState.critical) {
      if (_storyMode) return;
      _reportCritical();
      _enterStory(automatic: true);
      return;
    }
    FirestoreService.updateStatus(
      widget.classId,
      widget.uid,
      status: state,
      interactionCount: _tracker.interactionCount,
    );
  }

  /// Yalnızca özet yazılır: etkileşim sayısı ve hareketsiz kalınan süre (K23).
  void _reportCritical() {
    final lesson = _lesson!;
    FirestoreService.updateStatus(
      widget.classId,
      widget.uid,
      status: FocusState.critical,
      interactionCount: _tracker.interactionCount,
      idleSeconds: _currentThreshold?.inSeconds,
    );
    FirestoreService.raiseAlertIfNoneOpen(
      widget.classId,
      studentId: widget.uid,
      studentName: _fullName,
      learningStyle: _style,
      lesson: lesson,
    );
  }

  void _onInteraction() => _tracker.recordInteraction();

  // --- Akış --------------------------------------------------------------

  /// "Basitleştir" ile gelinirse ([automatic] false) Firestore'a hiçbir şey yazılmaz.
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

  /// Sayaç yeniden başlar; Kritik'ten dönülüyorsa durum Odakta olarak yazılır.
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
        automaticallyImplyLeading: false,
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
