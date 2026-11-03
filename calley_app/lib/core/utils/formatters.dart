/// Text helpers. Each returns a string and never invents a value:
/// something missing is an em dash.
const String noData = '—';

String fmtPhone(String? raw) {
  if (raw == null || raw.isEmpty) return noData;
  final d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.length == 10) return '${d.substring(0, 5)} ${d.substring(5)}';
  if (d.length == 12 && d.startsWith('91')) {
    return '+91 ${d.substring(2, 7)} ${d.substring(7)}';
  }
  return raw;
}

String fmtDate(DateTime? d) {
  if (d == null) return noData;
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${m[d.month - 1]} ${d.year}, $hh:$mm';
}

String fmtDuration(int? seconds) {
  if (seconds == null) return noData;
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s == 0 ? '${m}m' : '${m}m ${s}s';
}

/// "Good morning" / "Good afternoon" / "Good evening" for the hero card.
String greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Two-digit count as the Figma stat cards show it ("09").
String fmtCount2(int n) => n < 10 && n >= 0 ? '0$n' : '$n';

/// Share of a part in a whole as a whole-number percent; "<1%" rather than
/// "0%" for a nonzero sliver.
String fmtShare(int part, int whole) {
  if (whole <= 0 || part <= 0) return '0%';
  final p = part * 100 / whole;
  if (p < 1) return '<1%';
  return '${p.round()}%';
}
