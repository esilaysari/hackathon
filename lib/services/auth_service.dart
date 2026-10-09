import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../demo_accounts.dart';

abstract final class AuthService {
  /// Demo hesabıyla giriş yapar ve uid döner (TRD T5).
  /// Oturum sekmeye özeldir: iki pencerede iki rol aynı anda açık kalabilir.
  static Future<String> signInDemo(String email) async {
    final auth = FirebaseAuth.instance;
    if (kIsWeb) await auth.setPersistence(Persistence.SESSION);
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: DemoAccounts.password,
    );
    return credential.user!.uid;
  }
}
