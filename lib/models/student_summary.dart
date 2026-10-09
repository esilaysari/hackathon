import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/telemetry.dart';
import 'lesson.dart';

/// Öğretmen panelinde gerçek (Firestore) ve mock (JSON) öğrencinin ortak görünümü (TRD T3).
class StudentSummary {
  const StudentSummary({
    required this.id,
    required this.displayName,
    required this.learningStyle,
    required this.status,
    required this.topicTitle,
    required this.isMock,
    this.stuckFor,
    this.interactionCount,
    this.idleSeconds,
  });

  factory StudentSummary.fromMock(Map<String, dynamic> json) {
    final stuckMinutes = json['stuckMinutes'] as int?;
    return StudentSummary(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      learningStyle: LearningStyle.fromJson(json['learningStyle'] as String),
      status: FocusState.values.byName(json['status'] as String),
      topicTitle: json['currentTopicTitle'] as String,
      isMock: true,
      stuckFor: stuckMinutes == null ? null : Duration(minutes: stuckMinutes),
    );
  }

  factory StudentSummary.fromMember(String id, Map<String, dynamic> data, DateTime now) {
    final status = FocusState.values.byName(data['status'] as String? ?? 'focused');
    final stuckSince = (data['stuckSince'] as Timestamp?)?.toDate();
    final style = data['learningStyle'] as String?;
    return StudentSummary(
      id: id,
      displayName: data['displayName'] as String,
      learningStyle: style == null ? LearningStyle.textual : LearningStyle.fromJson(style),
      status: status,
      topicTitle: data['currentTopicTitle'] as String? ?? '',
      isMock: false,
      stuckFor: status == FocusState.critical && stuckSince != null ? now.difference(stuckSince) : null,
      interactionCount: data['interactionCount'] as int?,
      idleSeconds: data['idleSeconds'] as int?,
    );
  }

  final String id;
  final String displayName;
  final LearningStyle learningStyle;
  final FocusState status;
  final String topicTitle;
  final bool isMock;
  final Duration? stuckFor;
  final int? interactionCount;
  final int? idleSeconds;
}

/// Panelin özet şeridi, kritik listesi ve stil dağılımı (DESIGN.md §8.7).
class ClassOverview {
  ClassOverview._({
    required this.all,
    required this.attentionCount,
    required this.criticalStudents,
    required this.styleCounts,
    required this.nameSuffixes,
  });

  /// Gerçek öğrenciler önce, mock öğrenciler sonra birleşir (K32).
  factory ClassOverview.build({
    required List<StudentSummary> real,
    required List<StudentSummary> mocks,
  }) {
    final all = [...real, ...mocks];
    final critical = all.where((s) => s.status == FocusState.critical).toList()
      ..sort((a, b) {
        if (a.isMock != b.isMock) return a.isMock ? 1 : -1;
        return (b.stuckFor ?? Duration.zero).compareTo(a.stuckFor ?? Duration.zero);
      });
    return ClassOverview._(
      all: all,
      attentionCount: all.where((s) => s.status == FocusState.attention).length,
      criticalStudents: critical,
      styleCounts: {
        for (final style in LearningStyle.values)
          style: all.where((s) => s.learningStyle == style).length,
      },
      nameSuffixes: _nameSuffixes(all),
    );
  }

  final List<StudentSummary> all;
  final int attentionCount;
  final List<StudentSummary> criticalStudents;
  final Map<LearningStyle, int> styleCounts;

  /// Aynı tam ada sahip öğrenciler için ayırt edici etiket (K35); tekil adlarda yok.
  final Map<String, String> nameSuffixes;

  int get total => all.length;
  int get criticalCount => criticalStudents.length;

  StudentSummary? byId(String? id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  static Map<String, String> _nameSuffixes(List<StudentSummary> all) {
    final counts = <String, int>{};
    for (final s in all) {
      counts[s.displayName] = (counts[s.displayName] ?? 0) + 1;
    }
    return {
      for (final s in all)
        if (counts[s.displayName]! > 1) s.id: s.isMock ? s.id : s.id.substring(0, 6),
    };
  }
}
