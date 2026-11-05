import 'dart:io';

import 'package:calley_app/core/build_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec +N and kBuildNumber are the same number', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(
      r'^version:\s*[\d.]+\+(\d+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(m, isNotNull, reason: 'pubspec has no version: x.y.z+N');
    expect(
      int.parse(m!.group(1)!),
      kBuildNumber,
      reason: 'run scripts/changelog.mjs --pending to keep them in step',
    );
  });

  test('builds are numbered from 1000', () {
    expect(kBuildNumber, greaterThanOrEqualTo(1000));
  });
}
