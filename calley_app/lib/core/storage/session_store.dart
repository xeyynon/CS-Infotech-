import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';

/// Everything the app remembers between launches. One place, typed keys.
class SessionStore {
  SessionStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kUser = 'session.user';
  static const _kLanguage = 'pref.language';
  static const _kListId = 'pref.selectedListId';
  static const _kListName = 'pref.selectedListName';
  static const _kTheme = 'pref.themeMode';
  static const _kDataSource = 'pref.dataSource';
  static const _kOnboarded = 'session.onboarded';

  User? readUser() {
    final s = _prefs.getString(_kUser);
    if (s == null) return null;
    try {
      return User.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUser(User? u) => u == null
      ? _prefs.remove(_kUser)
      : _prefs.setString(_kUser, jsonEncode(u.toJson()));

  String? readLanguage() => _prefs.getString(_kLanguage);
  Future<void> writeLanguage(String code) => _prefs.setString(_kLanguage, code);

  ({String id, String name})? readSelectedList() {
    final id = _prefs.getString(_kListId);
    if (id == null) return null;
    return (id: id, name: _prefs.getString(_kListName) ?? '');
  }

  Future<void> writeSelectedList(String? id, String? name) async {
    if (id == null) {
      await _prefs.remove(_kListId);
      await _prefs.remove(_kListName);
    } else {
      await _prefs.setString(_kListId, id);
      await _prefs.setString(_kListName, name ?? '');
    }
  }

  String? readThemeMode() => _prefs.getString(_kTheme);
  Future<void> writeThemeMode(String mode) => _prefs.setString(_kTheme, mode);

  String? readDataSource() => _prefs.getString(_kDataSource);
  Future<void> writeDataSource(String s) => _prefs.setString(_kDataSource, s);

  bool readOnboarded() => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> writeOnboarded(bool v) => _prefs.setBool(_kOnboarded, v);

  /// Logout: forget the person, keep their language and theme.
  Future<void> clearSession() async {
    await _prefs.remove(_kUser);
    await _prefs.remove(_kListId);
    await _prefs.remove(_kListName);
    await _prefs.remove(_kOnboarded);
  }
}
