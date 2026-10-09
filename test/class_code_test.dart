import 'dart:math';

import 'package:eduswarm/demo_accounts.dart';
import 'package:eduswarm/models/class_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Üretilen kodlar 6 haneli ve 0/O, 1/I içermez', () {
    final random = Random(42);
    for (var i = 0; i < 500; i++) {
      final code = ClassCode.generate(random);
      expect(code, hasLength(6));
      expect(code, isNot(matches(RegExp('[0O1I]'))));
      expect(ClassCode.isValid(code), isTrue);
    }
  });

  test('Öğrencinin yazdığı kod boşluksuz ve büyük harfe çevrilir; demo kodu geçerli', () {
    expect(ClassCode.normalize(' ptr 234 '), DemoAccounts.classCode);
    expect(ClassCode.isValid(DemoAccounts.classCode), isTrue);
    expect(ClassCode.isValid('PTR23'), isFalse);
    expect(ClassCode.isValid('PTR2O4'), isFalse);
  });

  test('Davet linki hash rotasını kullanır', () {
    final link = ClassCode.inviteLink('ABC234', base: Uri.parse('https://eduswarm-985b9.web.app/'));
    expect(link, 'https://eduswarm-985b9.web.app/#/join?code=ABC234');
  });
}
