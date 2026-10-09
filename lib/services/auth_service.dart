import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../demo_accounts.dart';

abstract final class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Oturum sekmeye özeldir: iki pencerede iki rol aynı anda açık kalabilir (K42).
  static Future<void> _sessionPersistence() async {
    if (kIsWeb) await _auth.setPersistence(Persistence.SESSION);
  }

  /// Demo hesabıyla giriş yapar ve uid döner (TRD T5).
  static Future<String> signInDemo(String email) => signIn(email, DemoAccounts.password);

  static Future<String> signIn(String email, String password) async {
    await _sessionPersistence();
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user!.uid;
  }

  /// Şifre yalnızca Firebase Auth'ta kalır; profil `users/{uid}`'ye ayrıca yazılır (K37).
  static Future<String> register(String email, String password) async {
    await _sessionPersistence();
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return credential.user!.uid;
  }

  /// Sayfa yenilendiğinde açık kalan oturumun uid'si (yoksa null).
  static Future<String?> restoredUid() async => (await _auth.authStateChanges().first)?.uid;
}
