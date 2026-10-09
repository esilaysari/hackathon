import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_code.dart';
import '../../services/firestore_service.dart';
import '../../services/session.dart';
import '../../strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/class_code_view.dart';
import '../../widgets/form_widgets.dart';

/// Öğrenci: tek kod alanı + "Katıl"; davet linkiyle gelindiyse kod dolu gelir (DESIGN.md §8.3).
/// Yalnızca o koddaki sınıfa katılır (K52). Derslerim'den açıldıysa katılınca geri döner.
class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key, required this.uid, this.initialCode});

  final String uid;
  final String? initialCode;

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  late final _code = TextEditingController(text: widget.initialCode ?? '');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = ClassCode.normalize(_code.text);
    if (!ClassCode.isValid(code)) {
      setState(() => _error = AppStrings.invalidClassCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = context.read<Session>();
    final navigator = Navigator.of(context);
    try {
      final classId = await FirestoreService.joinClass(widget.uid, code);
      if (classId == null) {
        if (mounted) setState(() => _error = AppStrings.classNotFound);
      } else {
        session.addClass(classId);
        if (navigator.canPop()) navigator.pop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = AppStrings.errorGeneric(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: Navigator.canPop(context)
          ? AppBar(backgroundColor: AppColors.creamBase, foregroundColor: AppColors.grey900)
          : null,
      body: CenteredColumn(
        children: [
          const Text(AppStrings.joinClassTitle, style: AppTextStyles.taskTitle, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          const Text(AppStrings.joinClassHint, style: AppTextStyles.bodyLg, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          SurfaceCard(
            child: TextField(
              controller: _code,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: ClassCode.length,
              style: ClassCodeView.codeStyle,
              decoration: const InputDecoration(hintText: AppStrings.classCodeField, counterText: ''),
              onSubmitted: (_) => _join(),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: AppSpacing.md), WarningNote(_error!)],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: _busy ? AppStrings.working : AppStrings.joinButton, onPressed: _busy ? null : _join),
        ],
      ),
    );
  }
}
