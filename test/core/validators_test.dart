import 'package:flutter_test/flutter_test.dart';
import 'package:warder_do_mobile/core/constants/app_strings.dart';
import 'package:warder_do_mobile/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('bo’sh email rad etiladi', () {
      expect(Validators.email(''), AppStrings.errEmailRequired);
      expect(Validators.email(null), AppStrings.errEmailRequired);
    });

    test('format buzilgan email rad etiladi', () {
      expect(Validators.email('ali'), AppStrings.errEmailInvalid);
      expect(Validators.email('ali@'), AppStrings.errEmailInvalid);
      expect(Validators.email('ali@example'), AppStrings.errEmailInvalid);
      expect(Validators.email('@example.com'), AppStrings.errEmailInvalid);
    });

    test('to’g’ri email o’tadi', () {
      expect(Validators.email('ali@example.com'), isNull);
      expect(Validators.email('  Ali@Example.com  '), isNull);
      expect(Validators.email('a.b+c@sub.example.co.uk'), isNull);
    });
  });

  group('Validators.password', () {
    test('8 belgidan qisqa parol rad etiladi', () {
      expect(Validators.password('1234567'), AppStrings.errPasswordShort);
    });

    test('128 belgidan uzun parol rad etiladi', () {
      expect(Validators.password('a' * 129), AppStrings.errPasswordLong);
    });

    test('72 baytdan oshgan parol rad etiladi (bcrypt cheklovi)', () {
      // 30 ta kirill harfi = 60 bayt — o'tadi.
      expect(Validators.password('п' * 30), isNull);
      // 40 ta kirill harfi = 80 bayt — bcrypt kesib tashlardi.
      expect(Validators.password('п' * 40), AppStrings.errPasswordBytes);
    });

    test('normal parol o’tadi', () {
      expect(Validators.password('supersecret1'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('mos kelmasa xato', () {
      expect(
        Validators.confirmPassword('abc', 'abd'),
        AppStrings.errPasswordMismatch,
      );
    });

    test('mos kelsa null', () {
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
    });
  });

  group('Validators.fullName', () {
    test('bo’sh ism ruxsat etiladi (ixtiyoriy maydon)', () {
      expect(Validators.fullName(''), isNull);
      expect(Validators.fullName(null), isNull);
    });

    test('255 belgidan uzun ism rad etiladi', () {
      expect(Validators.fullName('a' * 256), AppStrings.errNameLong);
    });
  });
}
