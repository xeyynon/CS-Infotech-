import 'package:calley_app/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> res(int code, [Object? data]) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/x'),
  statusCode: code,
  data: data,
);

void main() {
  group('unwrap', () {
    test('returns the body on 2xx', () {
      expect(unwrap(res(200, {'a': 1})), {'a': 1});
      expect(unwrap(res(201, [1, 2])), [1, 2]);
    });

    test('maps status codes to kinds and keeps the server message', () {
      expect(
        () => unwrap(res(404, {'message': 'No such list'})),
        throwsA(
          isA<ApiException>()
              .having((e) => e.kind, 'kind', ApiErrorKind.notFound)
              .having((e) => e.message, 'message', 'No such list')
              .having((e) => e.statusCode, 'status', 404),
        ),
      );
      expect(
        () => unwrap(res(401)),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.unauthorized,
          ),
        ),
      );
      expect(
        () => unwrap(res(422, {'error': 'bad email'})),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'bad email'),
        ),
      );
      expect(
        () => unwrap(res(500)),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.server,
          ),
        ),
      );
    });

    test('ignores an empty or non-string message', () {
      expect(
        () => unwrap(res(404, {'message': ''})),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Not found on the server.',
          ),
        ),
      );
      expect(
        () => unwrap(res(404, {'message': 42})),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('mapDioError', () {
    DioException dio(DioExceptionType t) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: t,
    );

    test('timeouts and connection problems get plain-language kinds', () {
      expect(
        mapDioError(dio(DioExceptionType.connectionTimeout)).kind,
        ApiErrorKind.timeout,
      );
      expect(
        mapDioError(dio(DioExceptionType.receiveTimeout)).kind,
        ApiErrorKind.timeout,
      );
      expect(
        mapDioError(dio(DioExceptionType.connectionError)).kind,
        ApiErrorKind.network,
      );
      expect(
        mapDioError(dio(DioExceptionType.badCertificate)).kind,
        ApiErrorKind.network,
      );
    });

    test('messages never contain a URL', () {
      for (final t in DioExceptionType.values) {
        expect(mapDioError(dio(t)).message, isNot(contains('http')));
      }
    });
  });

  test('the pinned fingerprint list holds upper-case hex SHA-256 digests', () {
    expect(kPinnedCertSha256, isNotEmpty);
    for (final f in kPinnedCertSha256) {
      expect(RegExp(r'^[0-9A-F]{64}$').hasMatch(f), isTrue, reason: f);
    }
  });
}
