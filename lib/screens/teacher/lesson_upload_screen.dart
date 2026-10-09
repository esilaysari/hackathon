import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/lesson.dart';
import '../../models/lesson_draft.dart';
import '../../services/firestore_service.dart';
import '../../services/import/lesson_importer.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/form_widgets.dart';

/// Öğretmenin ders + soru yüklemesi (DESIGN.md §8.3, K16, K33): başlık, dosya ya da
/// yapıştırılan metin, soru tipi varsayılanı, sorular, önizleme ve "Dersi Gönder".
class LessonUploadScreen extends StatefulWidget {
  const LessonUploadScreen({super.key, required this.classId});

  final String classId;

  @override
  State<LessonUploadScreen> createState() => _LessonUploadScreenState();
}

class _LessonUploadScreenState extends State<LessonUploadScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final List<DraftQuestion> _questions = [];
  QuestionType _defaultType = QuestionType.verbalVisual;

  String? _fileName;
  List<StoryCard>? _slides;
  List<String> _notes = const [];
  bool _reading = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Önizlemedeki kart sayısı metinle birlikte güncellensin.
    _content.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  LessonDraft get _draft => LessonDraft(
        title: _title.text,
        content: _content.text,
        storyCards: _slides,
        questions: _questions,
      );

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: LessonImporter.extensions);
    if (file == null) return;
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final imported = LessonImporter.import(file.name, await file.readAsBytes(), defaultType: _defaultType);
      setState(() {
        _fileName = file.name;
        _slides = imported.storyCards;
        _notes = imported.notes;
        _content.text = imported.content;
        _questions
          ..removeWhere((q) => q.text.trim().isEmpty)
          ..addAll(imported.questions);
        if (_title.text.trim().isEmpty) _title.text = imported.suggestedTitle ?? _baseName(file.name);
      });
    } on ImportException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = AppStrings.fileReadFailed(e));
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  static String _baseName(String name) => name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name;

  void _removeFile() => setState(() {
        _fileName = null;
        _slides = null;
        _notes = const [];
        _content.clear();
      });

  Future<void> _send() async {
    final draft = _draft;
    final error = draft.title.trim().isEmpty
        ? AppStrings.lessonTitleRequired
        : (draft.content.trim().isEmpty && (draft.storyCards?.isEmpty ?? true))
            ? AppStrings.lessonContentRequired
            : draft.questions.any((q) => !q.isComplete)
                ? AppStrings.questionsIncomplete
                : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FirestoreService.publishLesson(widget.classId, draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.mint300,
          content: Text(AppStrings.lessonSent, style: AppTextStyles.bodyLg),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = AppStrings.errorGeneric(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        backgroundColor: AppColors.creamBase,
        foregroundColor: AppColors.grey900,
        title: const Text(AppStrings.uploadTitle, style: AppTextStyles.appBarTitle),
      ),
      body: CenteredColumn(
        maxWidth: AppLayout.desktopBreakpoint * 0.75,
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _title,
                  style: AppTextStyles.bodyLg,
                  decoration: const InputDecoration(labelText: AppStrings.lessonTitleField),
                ),
                const SizedBox(height: AppSpacing.md),
                _UploadZone(
                  fileName: _fileName,
                  reading: _reading,
                  onPick: _reading ? null : _pickFile,
                  onRemove: _removeFile,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_slides != null)
                  _SlideList(slides: _slides!)
                else
                  TextField(
                    controller: _content,
                    style: AppTextStyles.bodyLg,
                    minLines: 6,
                    maxLines: 16,
                    decoration: const InputDecoration(labelText: AppStrings.pasteTextField, alignLabelWithHint: true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(AppStrings.defaultTypeTitle, style: AppTextStyles.subheading),
                const SizedBox(height: AppSpacing.sm),
                _TypeChips(type: _defaultType, onChanged: (t) => setState(() => _defaultType = t)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionEditor(
              key: ObjectKey(_questions[i]),
              number: i + 1,
              question: _questions[i],
              onChanged: () => setState(() {}),
              onDelete: () => setState(() => _questions.removeAt(i)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SecondaryButton(
            label: AppStrings.addQuestion,
            onPressed: () => setState(() => _questions.add(DraftQuestion(type: _defaultType))),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Önizleme özeti: "8 kart, 4 soru bulundu" + içe aktarma notları.
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.mint300, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.previewSummary(draft.cardCount, draft.questions.length),
                    style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700),
                  ),
                  for (final note in _notes) Text(note, style: AppTextStyles.bodyLg),
                ],
              ),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: AppSpacing.md), WarningNote(_error!)],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: _sending ? AppStrings.sending : AppStrings.sendLesson,
            onPressed: _sending || _reading ? null : _send,
          ),
        ],
      ),
    );
  }
}

/// Kesikli Lilac-300 kenarlıklı yükleme alanı (radius-lg); seçilen dosya kart olarak görünür.
class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.fileName, required this.reading, required this.onPick, required this.onRemove});

  final String? fileName;
  final bool reading;
  final VoidCallback? onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = fileName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          painter: _DashedBorderPainter(),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: onPick,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(Icons.upload_file_rounded, color: AppColors.lilac700, size: AppSpacing.xl),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      reading ? AppStrings.readingFile : AppStrings.uploadDropText,
                      style: AppTextStyles.bodyLg,
                      textAlign: TextAlign.center,
                    ),
                    const Text(AppStrings.uploadDropHint, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (name != null) ...[
          const SizedBox(height: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.lilac100, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm / 2),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: AppColors.lilac700),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(name, style: AppTextStyles.bodyLg)),
                  TextButton(onPressed: onRemove, child: Text(AppStrings.removeFile, style: appLinkStyle)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const _dash = AppSpacing.sm;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lilac300
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppLayout.storyProgressHeight / 2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppRadius.lg)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash * 2) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

/// Slayttan gelen kartların kısa listesi (başlık + ilk satır).
class _SlideList extends StatelessWidget {
  const _SlideList({required this.slides});

  final List<StoryCard> slides;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.slidesTitle, style: AppTextStyles.subheading),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < slides.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              '${i + 1}. ${slides[i].text}${slides[i].subtitle == null ? '' : ' — ${slides[i].subtitle!.split('\n').first}'}',
              style: AppTextStyles.bodyLg,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.type, required this.onChanged});

  final QuestionType type;
  final ValueChanged<QuestionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        SelectChip(
          label: AppStrings.typeVerbalVisual,
          selected: type == QuestionType.verbalVisual,
          onTap: () => onChanged(QuestionType.verbalVisual),
        ),
        SelectChip(
          label: AppStrings.typeComputational,
          selected: type == QuestionType.computational,
          onTap: () => onChanged(QuestionType.computational),
        ),
      ],
    );
  }
}

/// Tek soru kartı: metin, 3-4 şık, doğru cevap (daire), tip çipi.
class _QuestionEditor extends StatelessWidget {
  const _QuestionEditor({
    super.key,
    required this.number,
    required this.question,
    required this.onChanged,
    required this.onDelete,
  });

  final int number;
  final DraftQuestion question;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  static const _letters = 'ABCDE';

  @override
  Widget build(BuildContext context) {
    final q = question;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(AppStrings.questionLabel(number), style: AppTextStyles.subheading)),
              TextButton(onPressed: onDelete, child: Text(AppStrings.deleteQuestion, style: appLinkStyle)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: q.text,
            style: AppTextStyles.bodyLg,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(labelText: AppStrings.questionTextField),
            onChanged: (v) {
              q.text = v;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          RadioGroup<int>(
            groupValue: q.correctIndex,
            onChanged: (i) {
              q.correctIndex = i;
              onChanged();
            },
            child: Column(
              children: [
                for (var i = 0; i < q.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        Radio<int>(value: i, activeColor: AppColors.lilac700),
                        Expanded(
                          child: TextFormField(
                            // Şık silinince alanlar kaymasın diye anahtar içerikten değil sıradan.
                            key: ValueKey('${identityHashCode(q)}_${i}_${q.options.length}'),
                            initialValue: q.options[i],
                            style: AppTextStyles.bodyLg,
                            decoration: InputDecoration(labelText: AppStrings.optionField(_letters[i])),
                            onChanged: (v) {
                              q.options[i] = v;
                              onChanged();
                            },
                          ),
                        ),
                        if (q.options.length > DraftQuestion.minOptions)
                          IconButton(
                            tooltip: AppStrings.removeOption,
                            icon: const Icon(Icons.close_rounded, color: AppColors.grey600),
                            onPressed: () {
                              q.options.removeAt(i);
                              if (q.correctIndex == i) {
                                q.correctIndex = null;
                              } else if (q.correctIndex != null && q.correctIndex! > i) {
                                q.correctIndex = q.correctIndex! - 1;
                              }
                              onChanged();
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (q.options.length < DraftQuestion.maxOptions)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  q.options.add('');
                  onChanged();
                },
                child: Text(AppStrings.addOption, style: appLinkStyle),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            q.correctIndex == null ? '${AppStrings.correctMissing}. ${AppStrings.markCorrectHint}' : AppStrings.markCorrectHint,
            style: q.correctIndex == null
                ? AppTextStyles.caption.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700)
                : AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          _TypeChips(
            type: q.type,
            onChanged: (t) {
              q.type = t;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
