// Demo verisini Firestore'a yazan tek seferlik betik (ROADMAP Faz 0, MEMORY K26).
// Çalıştırma: flutter run -d chrome -t lib/seed.dart
// Tekrar çalıştırmak güvenlidir: belgeler sabit id'lerle üzerine yazılır.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'demo_accounts.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String result;
  try {
    await _seed();
    result = 'Seed tamamlandı: demo öğretmen, demo öğrenci ve demo sınıfı yazıldı.';
  } catch (e) {
    result = 'Seed hatası: $e';
  }
  debugPrint(result);
  runApp(MaterialApp(home: Scaffold(body: Center(child: Text(result)))));
}

Future<void> _seed() async {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final classRef = db.collection('classes').doc(DemoAccounts.classId);

  final teacher = await auth.signInWithEmailAndPassword(
    email: DemoAccounts.teacherEmail,
    password: DemoAccounts.password,
  );
  final teacherId = teacher.user!.uid;
  await db.collection('users').doc(teacherId).set({
    'firstName': DemoAccounts.teacherFirstName,
    'lastName': DemoAccounts.teacherLastName,
    'email': DemoAccounts.teacherEmail,
    'role': 'teacher',
    'learningStyle': null,
    'kvkkConsent': true,
    'createdAt': FieldValue.serverTimestamp(),
  });
  await classRef.set({
    'name': DemoAccounts.className,
    'code': DemoAccounts.classCode,
    'teacherId': teacherId,
    'presentationMode': false,
    'activeLessonId': null,
    'createdAt': FieldValue.serverTimestamp(),
  });
  await auth.signOut();

  final student = await auth.signInWithEmailAndPassword(
    email: DemoAccounts.studentEmail,
    password: DemoAccounts.password,
  );
  final studentId = student.user!.uid;
  await db.collection('users').doc(studentId).set({
    'firstName': DemoAccounts.studentFirstName,
    'lastName': DemoAccounts.studentLastName,
    'email': DemoAccounts.studentEmail,
    'role': 'student',
    'learningStyle': DemoAccounts.studentLearningStyle,
    'kvkkConsent': true,
    'createdAt': FieldValue.serverTimestamp(),
  });
  await classRef.collection('members').doc(studentId).set({
    'displayName': '${DemoAccounts.studentFirstName} ${DemoAccounts.studentLastName}',
    'learningStyle': DemoAccounts.studentLearningStyle,
    'status': 'focused',
    'stuckSince': null,
    'interactionCount': 0,
    'topicScores': <String, int>{},
    'joinedAt': FieldValue.serverTimestamp(),
  });
  await auth.signOut();
}
