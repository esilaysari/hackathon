import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/class_code_view.dart';
import '../../widgets/form_widgets.dart';

/// Sınıf oluşturma: ad gir → kod ve davet linki (DESIGN.md §8.3). Hiç sınıfı olmayan
/// öğretmene panel yerine "İlk sınıfını oluştur" olarak, sonrakiler için "+ Yeni Sınıf"
/// ile açılır (K52). "Panele Git" [onDone]'u yeni sınıfın id'siyle çağırır.
class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key, required this.teacherId, required this.onDone, this.first = false});

  final String teacherId;
  final ValueChanged<String> onDone;
  final bool first;

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;
  ({String classId, String code})? _created;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AppStrings.requiredField);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final created = await FirestoreService.createClass(widget.teacherId, name);
      if (mounted) setState(() => _created = created);
    } catch (e) {
      if (mounted) setState(() => _error = AppStrings.errorGeneric(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: widget.first
          ? null
          : AppBar(backgroundColor: AppColors.creamBase, foregroundColor: AppColors.grey900),
      body: CenteredColumn(
        children: created == null
            ? [
                Text(
                  widget.first ? AppStrings.firstClassTitle : AppStrings.createClassTitle,
                  style: AppTextStyles.taskTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                SurfaceCard(
                  child: TextField(
                    controller: _name,
                    style: AppTextStyles.bodyLg,
                    decoration: const InputDecoration(labelText: AppStrings.className),
                    onSubmitted: (_) => _create(),
                  ),
                ),
                if (_error != null) ...[const SizedBox(height: AppSpacing.md), WarningNote(_error!)],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: _busy ? AppStrings.working : AppStrings.createClassButton,
                  onPressed: _busy ? null : _create,
                ),
              ]
            : [
                const Text(AppStrings.classCreatedTitle, style: AppTextStyles.taskTitle, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(_name.text.trim(), style: AppTextStyles.subheading, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(AppStrings.classCodeHint, style: AppTextStyles.bodyLg),
                      const SizedBox(height: AppSpacing.md),
                      ClassCodeView(code: created.code),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: AppStrings.goToPanel,
                  onPressed: () => widget.onDone(created.classId),
                ),
              ],
      ),
    );
  }
}
