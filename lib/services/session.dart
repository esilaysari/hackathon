import 'package:flutter/foundation.dart';

import '../demo_accounts.dart';
import '../models/learning_style_test.dart';
import '../models/lesson.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

enum UserRole { teacher, student }

/// Giriş yapan kullanıcının `users/{uid}` profili.
class AppUser {
  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.learningStyle,
    this.classIds = const [],
  });

  factory AppUser.fromJson(String uid, Map<String, dynamic> data) {
    final style = data['learningStyle'] as String?;
    return AppUser(
      uid: uid,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      role: data['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
      learningStyle: style == null ? null : LearningStyle.fromJson(style),
      classIds: parseClassIds(data),
    );
  }

  /// `users/{uid}.classIds`. Eski belgelerde tek `activeClassId` vardı. Demo öğrencisi her
  /// zaman demo sınıfındadır (Altın Senaryo, K52).
  static List<String> parseClassIds(Map<String, dynamic> data) {
    final legacy = data['activeClassId'] as String?;
    final ids = (data['classIds'] as List?)?.cast<String>() ?? [?legacy];
    final isDemoStudent = data['email'] == DemoAccounts.studentEmail;
    return isDemoStudent && !ids.contains(DemoAccounts.classId) ? [DemoAccounts.classId, ...ids] : ids;
  }

  final String uid;
  final String firstName;
  final String lastName;
  final UserRole role;

  /// null → öğrenci testi henüz çözmedi.
  final LearningStyle? learningStyle;

  /// Öğrencinin katıldığı sınıflar; boşsa katılma ekranı. Öğretmenin sınıfları
  /// `classes` içinde `teacherId` ile sorgulanır.
  final List<String> classIds;

  String get fullName => '$firstName $lastName'.trim();

  AppUser copyWith({LearningStyle? learningStyle, List<String>? classIds}) => AppUser(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        role: role,
        learningStyle: learningStyle ?? this.learningStyle,
        classIds: classIds ?? this.classIds,
      );
}

/// Giriş yapan kullanıcı ve katıldığı sınıflar (K34, K52, TRD T7). Firestore verisi StreamBuilder'da kalır.
class Session extends ChangeNotifier {
  AppUser? _user;
  bool _restoring = true;

  AppUser? get user => _user;

  /// Sayfa açılışında Firebase Auth oturumu geri yükleniyor mu.
  bool get restoring => _restoring;

  /// Davet linkiyle (`#/join?code=…`) gelinen kod; katılınca temizlenir.
  String? pendingJoinCode;

  /// Sekmede açık kalan oturum varsa profili yükler (TRD §4.4: rolüne göre yönlendirme).
  Future<void> restore() async {
    try {
      final uid = await AuthService.restoredUid();
      if (uid != null) _user = AppUser.fromJson(uid, await FirestoreService.loadUser(uid));
    } catch (e) {
      debugPrint('Oturum geri yüklenemedi: $e');
    }
    _restoring = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final uid = await AuthService.signIn(email, password);
    _user = AppUser.fromJson(uid, await FirestoreService.loadUser(uid));
    _restoring = false;
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final uid = await AuthService.register(email, password);
    await FirestoreService.createUser(uid, firstName: firstName, lastName: lastName, email: email, role: role.name);
    _user = AppUser(uid: uid, firstName: firstName, lastName: lastName, role: role);
    _restoring = false;
    notifyListeners();
  }

  /// Test sonucu Firestore'a yazıldıktan sonra "Derslerime Git" ile çağrılır.
  void applyTestResult(TestResult result) {
    final user = _user;
    if (user == null) return;
    _user = user.copyWith(learningStyle: result.profile);
    notifyListeners();
  }

  /// Öğrenci sınıfa katıldı (`users/{uid}.classIds` yazıldıktan sonra).
  void addClass(String classId) {
    final user = _user;
    pendingJoinCode = null;
    if (user != null && !user.classIds.contains(classId)) {
      _user = user.copyWith(classIds: [...user.classIds, classId]);
    }
    notifyListeners();
  }
}
