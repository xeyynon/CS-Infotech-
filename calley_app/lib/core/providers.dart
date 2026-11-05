import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/reminders/reminders.dart';
import '../models/models.dart';
import 'network/api_client.dart';
import 'network/calley_api.dart';
import 'storage/session_store.dart';

/// Overridden in main() with the real store once SharedPreferences has loaded.
final sessionStoreProvider = Provider<SessionStore>(
  (_) => throw UnimplementedError('override in main'),
);

/// The clock, so greetings are testable with a fixed time.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

// ---------------------------------------------------------------------------
// Preferences the user set on purpose. They live here, above every screen,
// so navigating never resets them.
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final s = ref.watch(sessionStoreProvider).readThemeMode();
    return ThemeMode.values.firstWhere(
      (m) => m.name == s,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> set(ThemeMode m) async {
    state = m;
    await ref.read(sessionStoreProvider).writeThemeMode(m.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class LanguageNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(sessionStoreProvider).readLanguage();

  Future<void> set(String code) async {
    state = code;
    await ref.read(sessionStoreProvider).writeLanguage(code);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String?>(
  LanguageNotifier.new,
);

/// Where data comes from. `remote` is the default; `sample` is chosen by the
/// user when the server cannot be reached, or forced by --dart-define.
enum DataSource { remote, sample }

const bool kForceMock = bool.fromEnvironment('USE_MOCK');

class DataSourceNotifier extends Notifier<DataSource> {
  @override
  DataSource build() {
    if (kForceMock) return DataSource.sample;
    final s = ref.watch(sessionStoreProvider).readDataSource();
    return s == DataSource.sample.name ? DataSource.sample : DataSource.remote;
  }

  Future<void> set(DataSource d) async {
    state = d;
    await ref.read(sessionStoreProvider).writeDataSource(d.name);
  }
}

final dataSourceProvider = NotifierProvider<DataSourceNotifier, DataSource>(
  DataSourceNotifier.new,
);

final apiProvider = Provider<CalleyApi>((ref) {
  return switch (ref.watch(dataSourceProvider)) {
    DataSource.remote => RemoteCalleyApi(createDio()),
    DataSource.sample => const SampleCalleyApi(),
  };
});

// ---------------------------------------------------------------------------
// Session
// ---------------------------------------------------------------------------

class SessionNotifier extends Notifier<User?> {
  @override
  User? build() => ref.watch(sessionStoreProvider).readUser();

  Future<void> signIn(User u) async {
    state = u;
    await ref.read(sessionStoreProvider).writeUser(u);
  }

  Future<void> signOut() async {
    state = null;
    await ref.read(sessionStoreProvider).clearSession();
    ref.invalidate(selectedListProvider);
    ref.invalidate(onboardedProvider);
    ref.invalidate(dispositionsProvider);
    // B-14: the next person to sign in must not inherit this one's email.
    ref.invalidate(pendingSignupProvider);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, User?>(
  SessionNotifier.new,
);

class OnboardedNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(sessionStoreProvider).readOnboarded();

  Future<void> set(bool v) async {
    state = v;
    await ref.read(sessionStoreProvider).writeOnboarded(v);
  }
}

final onboardedProvider = NotifierProvider<OnboardedNotifier, bool>(
  OnboardedNotifier.new,
);

/// What Register hands to the OTP screen. In memory only.
typedef PendingSignup = ({String email, String mobile, String? otpNotice});

class PendingSignupNotifier extends Notifier<PendingSignup?> {
  @override
  PendingSignup? build() => null;
  void set(PendingSignup? v) => state = v;
}

final pendingSignupProvider =
    NotifierProvider<PendingSignupNotifier, PendingSignup?>(
      PendingSignupNotifier.new,
    );

// ---------------------------------------------------------------------------
// Calling lists
// ---------------------------------------------------------------------------

typedef SelectedList = ({String id, String name});

class SelectedListNotifier extends Notifier<SelectedList?> {
  @override
  SelectedList? build() => ref.watch(sessionStoreProvider).readSelectedList();

  Future<void> set(SelectedList? v) async {
    state = v;
    await ref.read(sessionStoreProvider).writeSelectedList(v?.id, v?.name);
  }
}

final selectedListProvider =
    NotifierProvider<SelectedListNotifier, SelectedList?>(
      SelectedListNotifier.new,
    );

final listsProvider = FutureProvider<List<CallingList>>((ref) async {
  final user = ref.watch(sessionProvider);
  if (user == null) return const [];
  return ref.watch(apiProvider).getLists(user.id);
});

final listDetailsProvider = FutureProvider.family<ListDetails, String>((
  ref,
  listId,
) {
  return ref.watch(apiProvider).getListDetails(listId);
});

/// Dispositions the agent logs after a call, keyed by list AND record (B-28),
/// so a contact that appears in two lists keeps two separate outcomes.
/// The mock API has no write endpoint, so these stay in memory for the
/// session and the UI says so. Switching data source starts afresh (B-13):
/// outcomes logged against sample records do not belong to the server's.
class DispositionsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    ref.watch(dataSourceProvider);
    return const {};
  }

  static String keyFor(String listId, String recordKey) => '$listId/$recordKey';

  String? get(String listId, String recordKey) =>
      state[keyFor(listId, recordKey)];

  void set(String listId, String recordKey, String feedback) =>
      state = {...state, keyFor(listId, recordKey): feedback};

  void remove(String listId, String recordKey) =>
      state = {...state}..remove(keyFor(listId, recordKey));

  /// How many records of [listId] have an outcome logged.
  int countFor(String listId) =>
      state.keys.where((k) => k.startsWith('$listId/')).length;

  /// Outcome label → how many records of [listId] were logged with it.
  Map<String, int> outcomeCounts(String listId) {
    final out = <String, int>{};
    state.forEach((k, v) {
      if (k.startsWith('$listId/')) out[v] = (out[v] ?? 0) + 1;
    });
    return out;
  }
}

final dispositionsProvider =
    NotifierProvider<DispositionsNotifier, Map<String, String>>(
      DispositionsNotifier.new,
    );

/// Scheduled calls for the selected list that still need making, grouped and
/// ordered. Drives the Reminders screen and the bell's badge.
final remindersProvider = Provider<List<Reminder>>((ref) {
  final selected = ref.watch(selectedListProvider);
  if (selected == null) return const [];
  final details = ref.watch(listDetailsProvider(selected.id));
  final logged = ref.watch(dispositionsProvider);
  final now = ref.watch(clockProvider)();
  if (!details.hasValue) return const [];
  return buildReminders(
    details.value!.calls,
    now,
    isHandled: (r) =>
        logged.containsKey(DispositionsNotifier.keyFor(selected.id, r.key)),
  );
});
