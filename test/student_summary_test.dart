import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/models/lesson.dart';
import 'package:eduswarm/models/student_summary.dart';
import 'package:eduswarm/services/telemetry.dart';

Map<String, dynamic> mock(String id, String name, String status, {int? stuck, String style = 'visual'}) => {
      'id': id,
      'displayName': name,
      'learningStyle': style,
      'status': status,
      'currentTopicTitle': 'Veri Yapıları',
      'stuckMinutes': stuck,
    };

void main() {
  final now = DateTime(2026, 10, 9, 23);
  final mocks = [
    mock('mock_01', 'Can Özkan', 'critical', stuck: 4),
    mock('mock_02', 'Hakan Kılıç', 'critical', stuck: 6, style: 'dyslexic'),
    mock('mock_03', 'Ayşe Yılmaz', 'attention'),
    mock('mock_04', 'Elif Şen', 'focused', style: 'textual'),
  ].map(StudentSummary.fromMock).toList();
  final realCritical = StudentSummary.fromMember('abcdef123456', {
    'displayName': 'Ayşe Yılmaz',
    'learningStyle': 'dyslexic',
    'status': 'critical',
    'stuckSince': Timestamp.fromDate(now.subtract(const Duration(seconds: 45))),
    'currentTopicTitle': "C: Pointer'lar",
    'interactionCount': 12,
    'idleSeconds': 30,
  }, now);

  test('Sayaçlar mock + gerçek toplamından hesaplanır', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    expect(o.total, 5);
    expect(o.attentionCount, 1);
    expect(o.criticalCount, 3);
    expect(o.styleCounts, {LearningStyle.visual: 2, LearningStyle.dyslexic: 2, LearningStyle.textual: 1});
  });

  test('Kritik listede gerçekler en üstte, sonra en uzun takılan mock', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    expect(o.criticalStudents.map((s) => s.id), ['abcdef123456', 'mock_02', 'mock_01']);
    expect(o.criticalStudents.first.stuckFor, const Duration(seconds: 45));
  });

  test('Aynı tam ada sahip öğrencilere ayırt edici etiket verilir, tekil adlara verilmez', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    expect(o.nameSuffixes, {'abcdef123456': 'abcdef', 'mock_03': 'mock_03'});
  });

  test('Odakta olan gerçek öğrencinin takılma süresi yoktur', () {
    final focused = StudentSummary.fromMember('u1', {'displayName': 'X', 'status': 'focused'}, now);
    expect(focused.status, FocusState.focused);
    expect(focused.stuckFor, isNull);
  });
}
