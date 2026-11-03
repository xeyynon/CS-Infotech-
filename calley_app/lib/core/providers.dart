import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Email typed on Register, carried to the OTP screen. In memory only.
class PendingEmailNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? v) => state = v;
}

final pendingEmailProvider = NotifierProvider<PendingEmailNotifier, String?>(
  PendingEmailNotifier.new,
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

/// Dispositions the agent logs after a call. The mock API has no write
/// endpoint, so these stay in memory for the session and are labelled so.
class DispositionsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void set(String recordKey, String feedback) =>
      state = {...state, recordKey: feedback};
}

final dispositionsProvider =
    NotifierProvider<DispositionsNotifier, Map<String, String>>(
      DispositionsNotifier.new,
    );
