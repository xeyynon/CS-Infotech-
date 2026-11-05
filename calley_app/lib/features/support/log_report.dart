/// The text behind "Send Logs". Built only from app state and counts: **no
/// contact names, phone numbers, emails or addresses** from the calling list.
/// The user sees this exact text before choosing to send or copy it.
String buildLogReport({
  required String appVersion,
  required String platform,
  required DateTime now,
  required String dataSource,
  required String? accountEmail,
  required String? listName,
  required String? listId,
  required int total,
  required int pending,
  required int done,
  required int scheduled,
  required Map<String, int> outcomes,
}) {
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
  final b = StringBuffer()
    ..writeln('Calley app log')
    ..writeln('Time: $stamp')
    ..writeln('App version: $appVersion')
    ..writeln('Platform: $platform')
    ..writeln('Data source: $dataSource')
    ..writeln('Account: ${accountEmail ?? 'not signed in'}');
  if (listId == null) {
    b.writeln('Calling list: none selected');
  } else {
    b
      ..writeln('Calling list: ${listName ?? '-'} ($listId)')
      ..writeln(
        'Contacts: $total (pending $pending, done $done, scheduled $scheduled)',
      );
  }
  final logged = outcomes.values.fold<int>(0, (a, n) => a + n);
  b.writeln('Outcomes logged on this phone: $logged');
  for (final e in outcomes.entries) {
    b.writeln('  ${e.key}: ${e.value}');
  }
  return b.toString().trimRight();
}
