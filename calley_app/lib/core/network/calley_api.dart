import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../models/models.dart';
import 'api_client.dart';

/// The six endpoints of the Calley mock API.
abstract class CalleyApi {
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  });
  Future<User> login({required String email, required String password});
  Future<String?> sendOtp({required String email});
  Future<String?> verifyOtp({required String email, required String otp});
  Future<List<CallingList>> getLists(String userId);
  Future<ListDetails> getListDetails(String listId);
}

class RemoteCalleyApi implements CalleyApi {
  RemoteCalleyApi(this._dio);

  final Dio _dio;

  Future<Object?> _post(String path, Map<String, dynamic> body) async {
    try {
      return unwrap(await _dio.post<dynamic>(path, data: body));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Object?> _get(String path, [Map<String, dynamic>? query]) async {
    try {
      return unwrap(await _dio.get<dynamic>(path, queryParameters: query));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  static String? _msg(Object? data) =>
      data is Map ? data['message']?.toString() : null;

  @override
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async => _msg(
    await _post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  @override
  Future<User> login({required String email, required String password}) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (data is Map<String, dynamic>) {
      final user = User.fromJson(data);
      if (user.id.isNotEmpty || user.email.isNotEmpty) return user;
    }
    throw const ApiException(
      'The server did not return a user.',
      kind: ApiErrorKind.server,
    );
  }

  @override
  Future<String?> sendOtp({required String email}) async =>
      _msg(await _post('/auth/send-otp', {'email': email}));

  @override
  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async =>
      _msg(await _post('/auth/verify-otp', {'email': email, 'otp': otp}));

  @override
  Future<List<CallingList>> getLists(String userId) async {
    final data = await _get('/list', {'userId': userId});
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CallingList.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final inner = data['lists'] ?? data['data'];
      if (inner is List) {
        return inner
            .whereType<Map<String, dynamic>>()
            .map(CallingList.fromJson)
            .toList();
      }
      if (data.containsKey('_id') || data.containsKey('name')) {
        return [CallingList.fromJson(data)];
      }
    }
    return const [];
  }

  @override
  Future<ListDetails> getListDetails(String listId) async {
    final data = await _get('/list/$listId');
    if (data is Map<String, dynamic>) return ListDetails.fromJson(data);
    throw const ApiException('Unexpected list details from the server.');
  }
}

/// Serves the JSON files in assets/mock/. Used ONLY when the user chooses
/// "sample data" after the server could not be reached, or with
/// `--dart-define=USE_MOCK=true`. The UI shows a banner whenever this is active.
typedef JsonTextLoader = Future<String> Function(String assetName);

Future<String> _loadFromBundle(String name) =>
    rootBundle.loadString('assets/mock/$name.json');

class SampleCalleyApi implements CalleyApi {
  const SampleCalleyApi({
    this.latency = const Duration(milliseconds: 450),
    this.loadText = _loadFromBundle,
  });

  final Duration latency;

  /// Where the JSON comes from. The app reads the asset bundle; tests read
  /// the same files from disk.
  final JsonTextLoader loadText;

  Future<Map<String, dynamic>> _json(String name) async {
    await Future<void>.delayed(latency);
    final text = await loadText(name);
    return jsonDecode(text) as Map<String, dynamic>;
  }

  @override
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    return 'Sample mode: registered locally';
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final j = await _json('user');
    final base = User.fromJson(j);
    // Use the typed email so the sample feels like the person who signed in.
    return User(
      id: base.id,
      username: base.username,
      email: email.isEmpty ? base.email : email,
      phone: base.phone,
      subscription: base.subscription,
    );
  }

  @override
  Future<String?> sendOtp({required String email}) async {
    await Future<void>.delayed(latency);
    return 'Sample mode: any 6 digits verify';
  }

  @override
  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future<void>.delayed(latency);
    if (otp.length != 6) {
      throw const ApiException(
        'Enter the 6-digit code.',
        kind: ApiErrorKind.badRequest,
      );
    }
    return 'Sample mode: verified';
  }

  @override
  Future<List<CallingList>> getLists(String userId) async {
    final j = await _json('lists');
    return (j['lists'] as List)
        .whereType<Map<String, dynamic>>()
        .map(CallingList.fromJson)
        .toList();
  }

  @override
  Future<ListDetails> getListDetails(String listId) async =>
      ListDetails.fromJson(await _json('list_details'));
}
