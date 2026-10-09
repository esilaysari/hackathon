import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/demo_accounts.dart';
import 'package:eduswarm/services/session.dart';

void main() {
  test('classIds listesi olduğu gibi okunur', () {
    expect(AppUser.parseClassIds({'classIds': ['a', 'b']}), ['a', 'b']);
  });

  test('Eski tek activeClassId listeye çevrilir; hiçbiri yoksa boş (katılma ekranı)', () {
    expect(AppUser.parseClassIds({'activeClassId': 'eski'}), ['eski']);
    expect(AppUser.parseClassIds({'email': 'yeni@ornek.dev'}), isEmpty);
  });

  test('Yeni öğrenci demo sınıfına otomatik eklenmez', () {
    expect(AppUser.parseClassIds({'email': 'yeni@ornek.dev', 'classIds': ['x']}), ['x']);
  });

  test('Demo öğrencisi her zaman demo sınıfındadır (Altın Senaryo)', () {
    expect(AppUser.parseClassIds({'email': DemoAccounts.studentEmail}), [DemoAccounts.classId]);
    expect(
      AppUser.parseClassIds({'email': DemoAccounts.studentEmail, 'classIds': ['x']}),
      [DemoAccounts.classId, 'x'],
    );
  });
}
