import '../../models/models.dart';

/// The agent's progress through one calling list, worked out only from the
/// list's records and the outcomes logged on this phone. Nothing is invented:
/// the test server stores no outcomes, so "this session" is all there is.

class Level {
  const Level(this.name, this.from);

  final String name;

  /// Share of the list reached (0–1) at which this level starts.
  final double from;
}

const List<Level> kLevels = [
  Level('Rookie', 0),
  Level('Dialer', 0.25),
  Level('Closer', 0.5),
  Level('Pro', 0.75),
  Level('Champion', 1),
];

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.hint,
    required this.earned,
  });

  final String id;
  final String title;

  /// What earns it, shown whether or not it is earned yet.
  final String hint;
  final bool earned;
}

class ProgressStats {
  const ProgressStats({
    required this.total,
    required this.reached,
    required this.logged,
    required this.open,
    required this.byOutcome,
    required this.level,
    required this.nextLevel,
    required this.toNextLevel,
    required this.badges,
  });

  /// Contacts in the list.
  final int total;

  /// Contacts already dealt with: called or rescheduled on the server, or
  /// given an outcome here.
  final int reached;

  /// Outcomes logged on this phone for this list.
  final int logged;

  /// Contacts with a number still waiting for a first call.
  final int open;

  /// Outcome label → how many were logged with it.
  final Map<String, int> byOutcome;

  final Level level;

  /// Null at the top level.
  final Level? nextLevel;

  /// Contacts still to reach to get to [nextLevel] (0 at the top level).
  final int toNextLevel;

  final List<Achievement> badges;

  double get fraction => total == 0 ? 0 : reached / total;

  int get earnedBadges => badges.where((b) => b.earned).length;

  /// How far through the current level toward the next one (0–1).
  double get levelFraction {
    final next = nextLevel;
    if (next == null) return 1;
    final span = next.from - level.from;
    return span <= 0 ? 1 : ((fraction - level.from) / span).clamp(0, 1);
  }
}

/// [loggedOutcome] returns the outcome logged for a record on this phone, or
/// null. Pass the same lookup the queue uses.
ProgressStats computeProgress(
  ListDetails details,
  String? Function(CallRecord) loggedOutcome,
) {
  final calls = details.calls;
  final total = calls.length;

  var reached = 0;
  var open = 0;
  var logged = 0;
  final byOutcome = <String, int>{};
  for (final r in calls) {
    final outcome = loggedOutcome(r);
    if (outcome != null) {
      logged++;
      byOutcome[outcome] = (byOutcome[outcome] ?? 0) + 1;
    }
    final handled = r.status != CallStatus.pending || r.isRescheduled;
    if (handled || outcome != null) {
      reached++;
    } else if (r.phone != null) {
      open++;
    }
  }

  final fraction = total == 0 ? 0.0 : reached / total;
  var levelIndex = 0;
  for (var i = 0; i < kLevels.length; i++) {
    if (fraction >= kLevels[i].from) levelIndex = i;
  }
  final level = kLevels[levelIndex];
  final next = levelIndex + 1 < kLevels.length ? kLevels[levelIndex + 1] : null;
  final toNext = next == null
      ? 0
      : ((next.from * total).ceil() - reached).clamp(0, total);

  final positive =
      (byOutcome['Very positive'] ?? 0) + (byOutcome['Satisfied'] ?? 0);

  return ProgressStats(
    total: total,
    reached: reached,
    logged: logged,
    open: open,
    byOutcome: byOutcome,
    level: level,
    nextLevel: next,
    toNextLevel: toNext,
    badges: [
      Achievement(
        id: 'first',
        title: 'First outcome',
        hint: 'Log the outcome of one call',
        earned: logged >= 1,
      ),
      Achievement(
        id: 'five',
        title: 'Five logged',
        hint: 'Log five outcomes',
        earned: logged >= 5,
      ),
      Achievement(
        id: 'half',
        title: 'Halfway there',
        hint: 'Reach half of the list',
        earned: total > 0 && reached * 2 >= total,
      ),
      Achievement(
        id: 'positive',
        title: 'Positive vibes',
        hint: 'Three calls that went well',
        earned: positive >= 3,
      ),
      Achievement(
        id: 'sweep',
        title: 'Clean sweep',
        hint: 'Nobody left to call',
        earned: total > 0 && open == 0,
      ),
    ],
  );
}
