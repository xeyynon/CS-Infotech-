import 'package:calley_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name needs two characters', () {
    expect(Validators.name(null), isNotNull);
    expect(Validators.name('   '), isNotNull);
    expect(Validators.name('A'), isNotNull);
    expect(Validators.name('Al'), isNull);
  });

  test('email needs a user, a host and a TLD', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('swati'), isNotNull);
    expect(Validators.email('swati@cstech'), isNotNull);
    expect(Validators.email('swati@cstech.in'), isNull);
    expect(Validators.email('  swati@cstech.in  '), isNull);
  });

  test('password needs six characters', () {
    expect(Validators.password('12345'), isNotNull);
    expect(Validators.password('123456'), isNull);
  });

  test('mobile needs exactly ten digits, ignoring separators', () {
    expect(Validators.mobile('98711'), isNotNull);
    expect(Validators.mobile('9871125588'), isNull);
    expect(Validators.mobile('98711 25588'), isNull);
    expect(Validators.mobile('98711255889'), isNotNull);
  });

  test('otp is six digits', () {
    expect(Validators.otp('12345'), isNotNull);
    expect(Validators.otp('12345a'), isNotNull);
    expect(Validators.otp('123456'), isNull);
  });
}
