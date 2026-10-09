import 'lesson.dart' show parseOptionsAreCode;

/// Sokratik Rehber'in kontrol sorusu (MEMORY K20).
class CheckQuestion {
  const CheckQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.code,
    this.optionsAreCode = const [],
  });

  factory CheckQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    return CheckQuestion(
      text: json['text'] as String,
      code: json['code'] as String?,
      options: options,
      optionsAreCode: parseOptionsAreCode(json['optionsAreCode'], options.length),
      correctIndex: json['correctIndex'] as int,
    );
  }

  final String text;
  final String? code;
  final List<String> options;
  final List<bool> optionsAreCode;
  final int correctIndex;
}

/// Bir soru (ya da okuma ekranı) için 2-3 adımlı ipucu zinciri (TRD §3.2).
class SocraticChain {
  const SocraticChain({required this.hints, required this.check});

  factory SocraticChain.fromJson(Map<String, dynamic> json) => SocraticChain(
        hints: (json['hints'] as List).cast<String>(),
        check: json['check'] == null ? null : CheckQuestion.fromJson(json['check'] as Map<String, dynamic>),
      );

  final List<String> hints;
  final CheckQuestion? check;
}

/// `lessons/index.json` → `socraticMessages`: baloncuğun sabit cümleleri.
class SocraticMessages {
  const SocraticMessages({
    required this.solved,
    required this.solvedNext,
    required this.wrongCheck,
    required this.hintsExhausted,
  });

  factory SocraticMessages.fromJson(Map<String, dynamic> json) => SocraticMessages(
        solved: json['solved'] as String,
        solvedNext: json['solvedNext'] as String,
        wrongCheck: json['wrongCheck'] as String,
        hintsExhausted: json['hintsExhausted'] as String,
      );

  final String solved;
  final String solvedNext;
  final String wrongCheck;
  final String hintsExhausted;
}
