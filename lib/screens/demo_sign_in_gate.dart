import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../strings.dart';
import '../theme/tokens.dart';

/// Faz 5'teki giriş ekranına kadar: demo hesabıyla otomatik giriş yapar, ardından
/// [builder]'a uid'yi verir.
class DemoSignInGate extends StatefulWidget {
  const DemoSignInGate({super.key, required this.email, required this.builder});

  final String email;
  final Widget Function(String uid) builder;

  @override
  State<DemoSignInGate> createState() => _DemoSignInGateState();
}

class _DemoSignInGateState extends State<DemoSignInGate> {
  late final Future<String> _signIn = AuthService.signInDemo(widget.email);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _signIn,
      builder: (context, snapshot) {
        if (snapshot.hasData) return widget.builder(snapshot.data!);
        final text = snapshot.hasError ? AppStrings.signInFailed(snapshot.error!) : AppStrings.signingIn;
        return Scaffold(
          backgroundColor: AppColors.creamBase,
          body: Center(child: Text(text, style: AppTextStyles.bodyLg)),
        );
      },
    );
  }
}
