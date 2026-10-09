import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/models/lesson.dart';
import 'package:eduswarm/models/student_summary.dart';
import 'package:eduswarm/services/telemetry.dart';

Map<String, dynamic> mock(
  String id,
  String name,
  String status, {
  int? stuck,
  String style = 'visual',
  int pointers = 50,
}) =>
    {
      'id': id,
      'displayName': name,
      'learningStyle': style,
      'status': status,
      'currentTopic': 'data_structures',
      'currentTopicTitle': 'Veri Yapıları',
      'stuckMinutes': stuck,
      'topicScores': {'pointers': pointers},
    };

void main() {
  final now = DateTime(2026, 10, 9, 23);
  final mocks = [
    mock('mock_01', 'Can Özkan', 'critical', stuck: 4, pointers: 99),
    mock('mock_02', 'Hakan Kılıç', 'critical', stuck: 6, style: 'dyslexic'),
    mock('mock_03', 'Ayşe Yılmaz', 'attention', pointers: 97),
    mock('mock_04', 'Elif Şen', 'focused', style: 'textual', pointers: 90),
    mock('mock_05', 'Pelin Turan', 'focused', pointers: 98),
  ].map(StudentSummary.fromMock).toList();
  final realCritical = StudentSummary.fromMember('abcdef123456', {
    'displayName': 'Ayşe Yılmaz',
    'learningStyle': 'dyslexic',
    'status': 'critical',
    'stuckSince': Timestamp.fromDate(now.subtract(const Duration(seconds: 45))),
    'currentTopic': 'pointers',
    'currentTopicTitle': "C: Pointer'lar",
    'interactionCount': 12,
    'idleSeconds': 30,
  }, now);

  test('Sayaçlar mock + gerçek toplamından hesaplanır', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    expect(o.total, 6);
    expect(o.attentionCount, 1);
    expect(o.criticalCount, 3);
    expect(o.styleCounts, {LearningStyle.visual: 3, LearningStyle.dyslexic: 2, LearningStyle.textual: 1});
  });

  test('Kritik listede gerçekler en üstte, sonra en uzun takılan mock', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    expect(o.criticalStudents.map((s) => s.id), ['abcdef123456', 'mock_02', 'mock_01']);
  });

  test('Takılma süresi hareketsiz geçen süreyi de içerir (ilk anda 0 sn olmaz)', () {
    expect(realCritical.stuckFor, const Duration(seconds: 75)); // 45 sn kritik + 30 sn hareketsiz
    final justNow = StudentSummary.fromMember('u2', {
      'displayName': 'X',
      'status': 'critical',
      'stuckSince': Timestamp.fromDate(now),
      'idleSeconds': 5,
    }, now);
    expect(justNow.stuckFor, const Duration(seconds: 5));
  });

  test('Mock takılma süresi panel açıldıktan sonra akar', () {
    final m = StudentSummary.fromMock(mock('m', 'M', 'critical', stuck: 2), elapsed: const Duration(seconds: 10));
    expect(m.stuckFor, const Duration(minutes: 2, seconds: 10));
  });

  test('Aynı tam ada sahip öğrencilere ayırt edici etiket verilir, tekil adlara verilmez', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    expect(o.nameSuffixes, {'abcdef123456': 'abcdef', 'mock_03': 'mock_03'});
  });

  test('PeerSwarm: Odakta ve skoru en yüksek akran seçilir; Kritik/Dikkat ve takılan öğrenci seçilmez', () {
    final o = ClassOverview.build(real: [realCritical], mocks: mocks);
    // mock_01 (99, kritik) ve mock_03 (97, dikkat) elenir; Pelin Turan (98) seçilir.
    expect(o.suggestPeer('pointers', excludeId: 'abcdef123456')?.displayName, 'Pelin Turan');
    expect(o.suggestPeer('pointers', excludeId: 'mock_05')?.id, 'mock_04');
    expect(o.suggestPeer('unknown_topic', excludeId: 'x'), isNull);
  });

  test('PeerSwarm: eşit skorda gerçek öğrenci önce gelir', () {
    final realPeer = StudentSummary.fromMember('real1', {
      'displayName': 'Gerçek Akran',
      'status': 'focused',
      'topicScores': {'pointers': 98},
    }, now);
    final o = ClassOverview.build(real: [realCritical, realPeer], mocks: mocks);
    expect(o.suggestPeer('pointers', excludeId: 'abcdef123456')?.id, 'real1');
  });

  test('Odakta olan gerçek öğrencinin takılma süresi yoktur', () {
    final focused = StudentSummary.fromMember('u1', {'displayName': 'X', 'status': 'focused'}, now);
    expect(focused.status, FocusState.focused);
    expect(focused.stuckFor, isNull);
  });
}
