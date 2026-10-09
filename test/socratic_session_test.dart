import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/models/socratic.dart';
import 'package:eduswarm/services/socratic_session.dart';

void main() {
  const chain = SocraticChain(
    hints: ['ipucu 1', 'ipucu 2'],
    check: CheckQuestion(text: 'soru', options: ['a', 'b', 'c'], correctIndex: 1),
  );

  test('"Anlamadım" ipuçlarında ilerler; zincir bitince akran önerisine geçer', () {
    final s = SocraticSession(chain);
    expect(s.step, SocraticStep.hint);
    expect(s.currentHint, 'ipucu 1');
    s.notUnderstood();
    expect(s.currentHint, 'ipucu 2');
    s.notUnderstood();
    expect(s.step, SocraticStep.peerSuggestion);
  });

  test('"Anladım" kontrol sorusunu açar; doğru cevap akışı bitirir', () {
    final s = SocraticSession(chain)..understood();
    expect(s.step, SocraticStep.check);
    expect(s.answerCheck(1), isTrue);
    expect(s.step, SocraticStep.solved);
  });

  test('Yanlış kontrol cevabı sıradaki ipucunu "çok yaklaştın" önekiyle verir', () {
    final s = SocraticSession(chain)..understood();
    expect(s.answerCheck(0), isFalse);
    expect(s.step, SocraticStep.hint);
    expect(s.currentHint, 'ipucu 2');
    expect(s.lastCheckWrong, isTrue);
    s.understood();
    expect(s.answerCheck(2), isFalse);
    expect(s.step, SocraticStep.peerSuggestion); // İpucu kalmadı.
  });

  test('Kontrol sorusu yoksa "Anladım" doğrudan çözülmüş sayılır', () {
    final s = SocraticSession(const SocraticChain(hints: ['h'], check: null))..understood();
    expect(s.step, SocraticStep.solved);
  });
}
