import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Base URL of the Calley mock API ("Mock API V2").
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://mock-api.calleyacd.com/api',
);

const String _apiHost = 'mock-api.calleyacd.com';

/// The mock host serves a certificate issued to its hosting provider's name
/// (`cool-meninsky.74-208-123-142.plesk.page`, Let's Encrypt), not to
/// `mock-api.calleyacd.com`, so normal hostname validation fails.
///
/// We do NOT disable TLS validation. We pin the exact certificate observed on
/// 2026-11-04: the connection is accepted only for this one host AND only if
/// the server presents a certificate with one of these SHA-256 fingerprints.
/// Any other host, or a different certificate, is rejected as usual.
/// When the host renews its certificate (Let's Encrypt, ~90 days) the new
/// fingerprint must be added here.
const List<String> kPinnedCertSha256 = [
  'D35CCFE33BDA9060091F59662242BD6F19B82D32CA6D52C694FDA072D7487FDF',
];

String certFingerprint(X509Certificate cert) =>
    crypto.sha256.convert(cert.der).toString().toUpperCase();

bool acceptPinnedCertificate(X509Certificate cert, String host, int port) =>
    host == _apiHost && kPinnedCertSha256.contains(certFingerprint(cert));

/// What a screen shows when a request fails. Message is plain language,
/// never a stack trace or a URL.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.kind = ApiErrorKind.server,
  });

  final String message;
  final int? statusCode;
  final ApiErrorKind kind;

  @override
  String toString() => 'ApiException($statusCode, $kind): $message';
}

enum ApiErrorKind {
  network,
  timeout,
  server,
  notFound,
  unauthorized,
  badRequest,
}

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      // Let us map status codes ourselves.
      validateStatus: (_) => true,
    ),
  );
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () =>
        HttpClient()..badCertificateCallback = acceptPinnedCertificate,
  );
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('$o'),
      ),
    );
  }
  return dio;
}

/// Turns a Dio result into either a JSON body or an [ApiException].
Object? unwrap(Response<dynamic> res) {
  final code = res.statusCode ?? 0;
  if (code >= 200 && code < 300) return res.data;
  final serverMessage = _messageFrom(res.data);
  return switch (code) {
    400 || 422 => throw ApiException(
      serverMessage ?? 'The server rejected the request.',
      statusCode: code,
      kind: ApiErrorKind.badRequest,
    ),
    401 || 403 => throw ApiException(
      serverMessage ?? 'Not authorised.',
      statusCode: code,
      kind: ApiErrorKind.unauthorized,
    ),
    404 => throw ApiException(
      serverMessage ?? 'Not found on the server.',
      statusCode: code,
      kind: ApiErrorKind.notFound,
    ),
    409 => throw ApiException(
      serverMessage ?? 'Already exists.',
      statusCode: code,
      kind: ApiErrorKind.badRequest,
    ),
    _ => throw ApiException(
      serverMessage ?? 'The server returned an error ($code).',
      statusCode: code,
    ),
  };
}

String? _messageFrom(Object? data) {
  if (data is Map) {
    for (final k in const ['message', 'error', 'msg', 'detail']) {
      final v = data[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
  }
  return null;
}

ApiException mapDioError(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout => const ApiException(
    'The server took too long to answer.',
    kind: ApiErrorKind.timeout,
  ),
  DioExceptionType.connectionError ||
  DioExceptionType.badCertificate => const ApiException(
    'Could not reach the Calley server. Check your connection and try again.',
    kind: ApiErrorKind.network,
  ),
  // B-12: a pinned-certificate mismatch arrives as an "unknown" error
  // wrapping a TLS handshake failure; say what it is.
  _ when e.error is HandshakeException || e.error is TlsException =>
    const ApiException(
      'The Calley server presented an unexpected security certificate, so '
      'the app did not connect. The certificate may have been renewed.',
      kind: ApiErrorKind.network,
    ),
  _ => ApiException(e.message ?? 'Something went wrong talking to the server.'),
};
