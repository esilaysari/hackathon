import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../dev_config.dart';
import '../../models/lesson.dart';
import '../../models/socratic.dart';
import '../../services/content_service.dart';
import '../../services/firestore_service.dart';
import '../../services/story_splitter.dart';
import '../../services/telemetry.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/socratic_bubble.dart';
import '../../widgets/story_view.dart';
import '../../widgets/student_notification.dart';
import '../../widgets/task_view.dart';

/// Kritik'ten Sokratik kontrol sorusuyla toparlanınca konu skoruna eklenen puan (TRD §4.1).
const _recoveryScoreGain = 10;

/// Öğrenci ders ekranı: okuma → sorular; Kritik'te otomatik Morphing ile Story modu ve
/// Sokratik Rehber (DESIGN.md §8.4–8.6). Durum geçişleri, uyarılar ve bildirimler Firestore'da.
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.uid,
    required this.classId,
    required this.lesson,
    required this.socraticMessages,
    required this.fallbackChain,
  });

  final String uid;
  final String classId;

  /// "Derslerim"de seçilen ders; durum, uyarı ve PeerSwarm bu dersin topicKey'iyle çalışır (K50).
  final Lesson lesson;
  final SocraticMessages socraticMessages;

  /// Dersin konuya özel zinciri yoksa (öğretmenin yüklediği ders) genel üst-bilişsel zincir.
  final SocraticChain fallbackChain;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final FocusTracker _tracker = FocusTracker(
    onStateChanged: _onFocusChanged,
  );
  final _random = Random();
  StreamSubscription<Object?>? _classSubscription;
  StreamSubscription<Object?>? _notificationSubscription;
  Timer? _notificationTimer;

  Lesson? _lesson;
  Map<String, List<String>> _messages = const {};
  LearningStyle _style = LearningStyle.textual;
  String _fullName = '';
  List<StoryCard> _storyCards = const [];
  bool _presentationMode = false;

  int _stage = -1; // -1 okuma, 0..n-1 soru, n tamamlandı.
  final Map<int, int> _answers = {};
  final Map<int, bool> _firstAttemptCorrect =
      {}; // Skor ilk denemeye göre (K45).
  bool? _checkResult;
  bool _hintOpen = false;

  bool _storyMode = false;
  bool _storyFromCritical = false;
  int _storyIndex = 0;
  int _storyEntries =
      0; // Her Story girişinde Sokratik baloncuk sıfırdan başlasın.
  bool _storySolved =
      false; // Kontrol sorusu çözüldü → "Soruya Dön" hemen görünür.

  String? _notificationText;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lesson = widget.lesson;
    final messages = await ContentService.loadSupportMessages();
    final profile = await FirestoreService.loadProfile(widget.uid);
    if (!mounted) return;
    setState(() {
      _lesson = lesson;
      _messages = messages;
      _style =
          DevConfig.learningStyleOverride ??
          profile.learningStyle ??
          LearningStyle.textual;
      _fullName = profile.fullName;
      // Elle hazırlanmış kartlar varsa onlar; yoksa (öğretmenin yüklediği içerik) kurala göre bölme.
      _storyCards =
          lesson.storyCards ??
          [
            StoryCard(text: lesson.title),
            for (final text in splitIntoStoryCards(lesson.content))
              StoryCard(text: text),
          ];
    });
    await FirestoreService.startLesson(widget.classId, widget.uid, lesson);
    _classSubscription = FirestoreService.watchClass(widget.classId)
        .listen((snapshot) {
          final enabled = snapshot.data()?['presentationMode'] == true;
          if (enabled == _presentationMode) return;
          _presentationMode = enabled;
          debugPrint('Sunum Modu: $enabled');
          // Yeni eşik anında geçerli olsun (K29).
          if (_tracker.isRunning) _startTracking();
        });
    _listenNotifications();
    _startTracking();
  }

  /// Yalnızca sayfa açıldıktan sonra gelen bildirimler gösterilir (ilk anlık görüntü atlanır).
  void _listenNotifications() {
    var primed = false;
    _notificationSubscription =
        FirestoreService.watchNotifications(widget.classId, widget.uid).listen((
          snapshot,
        ) {
          if (!primed) {
            primed = true;
            return;
          }
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              _showNotification(change.doc.data()?['text'] as String? ?? '');
            }
          }
        });
  }

  @override
  void dispose() {
    _classSubscription?.cancel();
    _notificationSubscription?.cancel();
    _notificationTimer?.cancel();
    _tracker.dispose();
    super.dispose();
  }

  String _pick(String key) {
    final pool = _messages[key]!;
    return pool[_random.nextInt(pool.length)];
  }

  // --- Telemetri ---------------------------------------------------------

  Duration? get _currentThreshold {
    final lesson = _lesson!;
    // Ders bitti, sayaç yok.
    if (_stage >= lesson.questions.length) return null;
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
    final idleSeconds = _currentThreshold?.inSeconds ?? 0;
    FirestoreService.updateStatus(
      widget.classId,
      widget.uid,
      status: FocusState.critical,
      interactionCount: _tracker.interactionCount,
      idleSeconds: idleSeconds,
    );
    FirestoreService.raiseAlertIfNoneOpen(
      widget.classId,
      studentId: widget.uid,
      studentName: _fullName,
      learningStyle: _style,
      lesson: _lesson!,
      idleSeconds: idleSeconds,
    );
  }

  void _onInteraction() => _tracker.recordInteraction();

  // --- Story ve Sokratik Rehber -----------------------------------------

  /// Takılınan ekranın zinciri: okuma → `reading`, soru → soru id'si (K46). Sorunun
  /// zinciri yoksa (yüklenen derste eşleşme bulunamadı) okuma zinciri değil genel zincir.
  SocraticChain get _currentChain {
    final lesson = _lesson!;
    final onQuestion = _stage >= 0 && _stage < lesson.questions.length;
    final chain = onQuestion ? lesson.socratic[lesson.questions[_stage].id] : lesson.socratic['reading'];
    return chain ?? widget.fallbackChain;
  }

  /// "Basitleştir" ile gelinirse ([automatic] false) Firestore'a hiçbir şey yazılmaz.
  void _enterStory({required bool automatic}) {
    _tracker.stop();
    debugPrint(
      'Story moduna geçildi (${automatic ? 'otomatik — Kritik' : 'elle — Basitleştir'})',
    );
    setState(() {
      _storyMode = true;
      _storyFromCritical = automatic;
      _storyIndex = 0;
      _storyEntries++;
      _storySolved = false;
    });
    if (automatic) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(_pick('morph'), style: AppTextStyles.bodyLg),
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

  /// Story'deki kontrol sorusu doğru: tebriki baloncuk gösterir ("solved" + "solvedNext"),
  /// "Soruya Dön" hemen görünür; Kritik'ten gelindiyse Odakta + skor (K20, K22, K49).
  void _onStorySolved() {
    if (_storyFromCritical) {
      FirestoreService.markRecovered(
        widget.classId,
        widget.uid,
        _lesson!.topicKey,
        _recoveryScoreGain,
      );
      _storyFromCritical = false;
    }
    setState(() => _storySolved = true);
  }

  // --- Sorular -----------------------------------------------------------

  void _selectOption(int index) {
    setState(() {
      _answers[_stage] = index;
      // Yeni şık → yeniden kontrol.
      if (_checkResult == false) _checkResult = null;
    });
  }

  void _checkAnswer() {
    final correct = _answers[_stage] == _lesson!.questions[_stage].correctIndex;
    _firstAttemptCorrect.putIfAbsent(_stage, () => correct);
    debugPrint('Soru ${_stage + 1}: ${correct ? 'doğru' : 'yanlış'}');
    setState(() => _checkResult = correct);
  }

  void _next() {
    setState(() {
      _stage++;
      _checkResult = null;
      _hintOpen = false;
    });
    _startTracking();
  }

  // --- Bildirim ----------------------------------------------------------

  void _showNotification(String text) {
    _notificationTimer?.cancel();
    setState(() => _notificationText = text);
    _notificationTimer = Timer(
      AppDurations.notificationVisible,
      _hideNotification,
    );
  }

  void _hideNotification() {
    _notificationTimer?.cancel();
    if (mounted) setState(() => _notificationText = null);
  }

  // --- Görünüm -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _onLeave();
      },
      child: Scaffold(
        backgroundColor: AppColors.creamBase,
        appBar: AppBar(
          backgroundColor: AppColors.creamBase,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  tooltip: AppStrings.myLessonsTitle,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.grey900,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                )
              : null,
          title: const Text(
            AppStrings.appTitle,
            style: AppTextStyles.appBarTitle,
          ),
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
            onPointerSignal: (_) =>
                _tracker.recordInteraction(countable: false),
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.studentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: lesson == null
                          ? const Center(
                              child: Text(
                                AppStrings.lessonLoading,
                                style: AppTextStyles.bodyLg,
                              ),
                            )
                          : AnimatedSwitcher(
                              duration: AppDurations.morphing,
                              transitionBuilder: (child, animation) {
                                final faded = FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                                if (reduceMotion) return faded;
                                return ScaleTransition(
                                  scale: Tween(
                                    begin: AppDurations.morphScaleBegin,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: faded,
                                );
                              },
                              child: _storyMode
                                  ? _buildStory()
                                  : _buildTask(lesson),
                            ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.studentMaxWidth,
                    ),
                    child: StudentNotification(
                      text: _notificationText,
                      onDismiss: _hideNotification,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Derslerim"e dönüş: sayaç durur, durum Odakta yazılır (K50).
  void _onLeave() {
    _tracker.stop();
    FirestoreService.updateStatus(
      widget.classId,
      widget.uid,
      status: FocusState.focused,
      interactionCount: _tracker.interactionCount,
    );
  }

  Widget _buildStory() {
    return StoryView(
      key: const ValueKey('story'),
      cards: _storyCards,
      index: _storyIndex,
      style: _style,
      onAdvance: () => setState(() => _storyIndex++),
      onBack: _exitStory,
      showBackButton: _storySolved,
      socraticBubble: SocraticBubble(
        key: ValueKey('story_bubble_$_storyEntries'),
        chain: _currentChain,
        messages: widget.socraticMessages,
        style: _style,
        appearDelay: AppDurations.morphing,
        onSolved: _onStorySolved,
      ),
    );
  }

  Widget _buildTask(Lesson lesson) {
    return TaskView(
      key: const ValueKey('task'),
      lesson: lesson,
      style: _style,
      stage: _stage,
      selectedOption: _answers[_stage],
      checkResult: _checkResult,
      correctCount: _firstAttemptCorrect.values.where((c) => c).length,
      hintChain: _hintOpen ? _currentChain : null,
      socraticMessages: widget.socraticMessages,
      onSelectOption: _selectOption,
      onCheck: _checkAnswer,
      onNext: _next,
      onOpenHint: () =>
          setState(() => _hintOpen = true), // Öğretmene uyarı üretmez.
      onSimplify: () => _enterStory(automatic: false),
    );
  }
}
