import 'dart:math';

/// 6 haneli sınıf kodu (TRD §3.1): karışmasın diye 0/O ve 1/I yok.
abstract final class ClassCode {
  static const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const length = 6;

  static String generate([Random? random]) {
    final r = random ?? Random.secure();
    return String.fromCharCodes(List.generate(length, (_) => alphabet.codeUnitAt(r.nextInt(alphabet.length))));
  }

  /// Öğrencinin yazdığı kod: boşluklar atılır, büyük harfe çevrilir.
  static String normalize(String input) => input.replaceAll(RegExp(r'\s'), '').toUpperCase();

  static bool isValid(String code) => RegExp('^[$alphabet]{$length}\$').hasMatch(code);

  /// Davet linki: uygulamanın bulunduğu adres + `#/join?code=…`.
  static String inviteLink(String code, {Uri? base}) {
    final b = base ?? Uri.base;
    return '${b.origin}${b.path}#/join?code=$code';
  }
}
