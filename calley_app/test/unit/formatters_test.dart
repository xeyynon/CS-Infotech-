import 'package:calley_app/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fmtPhone groups Indian numbers and leaves others alone', () {
    expect(fmtPhone(null), noData);
    expect(fmtPhone(''), noData);
    expect(fmtPhone('1000000000'), '10000 00000');
    expect(fmtPhone('+91 9871125588'), '+91 98711 25588');
    expect(fmtPhone('12345'), '12345');
  });

  test('fmtDate is day month year, 24-hour', () {
    expect(fmtDate(null), noData);
    expect(fmtDate(DateTime(2025, 6, 22, 19, 41, 31)), '22 Jun 2025, 19:41');
    expect(fmtDate(DateTime(2025, 12, 1, 0, 5)), '1 Dec 2025, 00:05');
  });

  test('fmtDuration', () {
    expect(fmtDuration(null), noData);
    expect(fmtDuration(17), '17s');
    expect(fmtDuration(60), '1m');
    expect(fmtDuration(65), '1m 5s');
  });

  test('fmtCount2 pads single digits like the design ("09")', () {
    expect(fmtCount2(9), '09');
    expect(fmtCount2(27), '27');
    expect(fmtCount2(0), '00');
  });

  test('fmtShare never shows 0% for a nonzero part', () {
    expect(fmtShare(27, 61), '44%');
    expect(fmtShare(0, 61), '0%');
    expect(fmtShare(1, 500), '<1%');
    expect(fmtShare(5, 0), '0%');
  });

  test('greetingFor follows the hour', () {
    expect(greetingFor(DateTime(2026, 1, 1, 6)), 'Good morning');
    expect(greetingFor(DateTime(2026, 1, 1, 11, 59)), 'Good morning');
    expect(greetingFor(DateTime(2026, 1, 1, 12)), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 1, 1, 17)), 'Good evening');
    expect(greetingFor(DateTime(2026, 1, 1, 23)), 'Good evening');
  });
}
