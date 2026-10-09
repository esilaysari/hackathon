import '../models/socratic.dart';

enum SocraticStep { hint, peerSuggestion, check, solved }

/// Sokratik akışın durumu (MEMORY K20): "Anlamadım" → sıradaki ipucu, zincir biterse
/// akran önerisi; "Anladım" → kontrol sorusu; yanlışsa sıradaki ipucu. Cevap verilmez.
class SocraticSession {
  SocraticSession(this.chain);

  final SocraticChain chain;
  SocraticStep step = SocraticStep.hint;
  int _hintIndex = 0;

  /// Son kontrol sorusu yanlış cevaplandıysa true ("Çok yaklaştın" öneki için).
  bool lastCheckWrong = false;

  String get currentHint => chain.hints[_hintIndex];

  void notUnderstood() {
    lastCheckWrong = false;
    _advanceHint();
  }

  void understood() {
    lastCheckWrong = false;
    step = chain.check == null ? SocraticStep.solved : SocraticStep.check;
  }

  /// Doğruysa true döner ve akış biter; yanlışsa sıradaki ipucuna geçer.
  bool answerCheck(int optionIndex) {
    if (optionIndex == chain.check!.correctIndex) {
      step = SocraticStep.solved;
      return true;
    }
    lastCheckWrong = true;
    _advanceHint();
    return false;
  }

  void _advanceHint() {
    if (_hintIndex < chain.hints.length - 1) {
      _hintIndex++;
      step = SocraticStep.hint;
    } else {
      step = SocraticStep.peerSuggestion;
    }
  }
}
