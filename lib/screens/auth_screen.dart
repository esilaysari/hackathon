import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../demo_accounts.dart';
import '../services/session.dart';
import '../strings.dart';
import '../theme/tokens.dart';
import '../widgets/app_buttons.dart';

/// Giriş / Kayıt: tek kart, iki sekme, altta demo girişleri (DESIGN.md §8.1, K14).
/// Başarılı girişte [Session] güncellenir; yönlendirmeyi `HomeGate` yapar.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _registerTab = false;
  UserRole? _role;
  bool _kvkk = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function(Session session) action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action(context.read<Session>());
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_registerTab && (_role == null || !_kvkk)) {
      setState(() => _error = _role == null ? AppStrings.chooseRole : AppStrings.kvkkRequired);
      return;
    }
    final email = _email.text.trim();
    _run((session) => _registerTab
        ? session.register(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            email: email,
            password: _password.text,
            role: _role!,
          )
        : session.signIn(email, _password.text));
  }

  static String _message(Object e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => AppStrings.errorWrongCredentials,
        'email-already-in-use' => AppStrings.errorEmailInUse,
        'weak-password' => AppStrings.errorWeakPassword,
        'invalid-email' => AppStrings.errorInvalidEmail,
        _ => AppStrings.errorGeneric(e.message ?? e.code),
      };
    }
    return AppStrings.errorGeneric(e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.studentMaxWidth),
            child: Theme(
              data: Theme.of(context).copyWith(inputDecorationTheme: _inputTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(AppStrings.appTitle, style: AppTextStyles.taskTitle, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  _card(),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run((s) => s.signIn(DemoAccounts.teacherEmail, DemoAccounts.password)),
                    child: Text(AppStrings.demoTeacher, style: _linkStyle),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run((s) => s.signIn(DemoAccounts.studentEmail, DemoAccounts.password)),
                    child: Text(AppStrings.demoStudent, style: _linkStyle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final _linkStyle = AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500, color: AppColors.lilac700);

  Widget _card() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _tab(AppStrings.tabSignIn, selected: !_registerTab, onTap: () => _switchTab(false)),
                  const SizedBox(width: AppSpacing.sm),
                  _tab(AppStrings.tabRegister, selected: _registerTab, onTap: () => _switchTab(true)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_registerTab) ...[
                _field(_firstName, AppStrings.firstName, autofill: AutofillHints.givenName),
                const SizedBox(height: AppSpacing.sm),
                _field(_lastName, AppStrings.lastName, autofill: AutofillHints.familyName),
                const SizedBox(height: AppSpacing.sm),
              ],
              _field(_email, AppStrings.email, autofill: AutofillHints.email, validator: _validateEmail),
              const SizedBox(height: AppSpacing.sm),
              _field(
                _password,
                AppStrings.password,
                obscure: true,
                autofill: AutofillHints.password,
                validator: _registerTab ? _validatePassword : null,
              ),
              if (_registerTab) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _roleCard(UserRole.teacher, AppStrings.roleTeacherOption, Icons.school_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    _roleCard(UserRole.student, AppStrings.roleStudentOption, Icons.backpack_rounded),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _kvkkRow(),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(_error!, style: AppTextStyles.bodyLg),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: _busy
                    ? AppStrings.signingIn
                    : (_registerTab ? AppStrings.registerButton : AppStrings.signInButton),
                onPressed: _busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _switchTab(bool register) => setState(() {
        _registerTab = register;
        _error = null;
      });

  Widget _tab(String label, {required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.lilac100 : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(color: selected ? AppColors.lilac700 : AppColors.grey600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    String? autofill,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofillHints: autofill == null ? null : [autofill],
      style: AppTextStyles.bodyLg,
      decoration: InputDecoration(labelText: label),
      validator: validator ?? _validateRequired,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _roleCard(UserRole role, String label, IconData icon) {
    final selected = _role == role;
    return Expanded(
      child: Material(
        color: selected ? AppColors.lilac100 : AppColors.creamSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: selected ? AppColors.lilac700 : AppColors.grey400),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => setState(() {
            _role = role;
            _error = null;
          }),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Icon(icon, color: AppColors.lilac700, size: AppSpacing.xl),
                const SizedBox(height: AppSpacing.sm),
                Text(label, style: AppTextStyles.button.copyWith(color: AppColors.grey900)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kvkkRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _kvkk,
          activeColor: AppColors.lilac700,
          onChanged: (v) => setState(() {
            _kvkk = v ?? false;
            _error = null;
          }),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _kvkk = !_kvkk),
                child: const Text(AppStrings.kvkkConsent, style: AppTextStyles.caption),
              ),
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: _showKvkkDetails,
                child: Text(AppStrings.kvkkDetails, style: _linkStyle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showKvkkDetails() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        content: const Text(AppStrings.kvkkDetailsText, style: AppTextStyles.bodyLg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.close, style: _linkStyle),
          ),
        ],
      ),
    );
  }

  static String? _validateRequired(String? v) => (v == null || v.trim().isEmpty) ? AppStrings.requiredField : null;

  static String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return AppStrings.requiredField;
    return value.contains('@') && value.contains('.') ? null : AppStrings.invalidEmail;
  }

  static String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return AppStrings.requiredField;
    return v.length < 6 ? AppStrings.shortPassword : null;
  }

  /// Input'lar radius-md; hata rengi sert kırmızı yerine Warning kenarlık + Grey-900 metin (§4.2).
  static final _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.creamSurface,
    labelStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
    floatingLabelStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.lilac700),
    errorStyle: AppTextStyles.caption.copyWith(color: AppColors.grey900),
    border: _border(AppColors.grey400),
    enabledBorder: _border(AppColors.grey400),
    focusedBorder: _border(AppColors.lilac700),
    errorBorder: _border(AppColors.warning),
    focusedErrorBorder: _border(AppColors.warning),
  );

  static OutlineInputBorder _border(Color color) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: color));
}
