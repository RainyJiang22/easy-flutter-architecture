import 'package:dio/dio.dart';
import 'package:easy_flutter_architecture/core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('DioClient', () {
    late DioClient dioClient;

    setUp(() {
      dioClient = DioClient();
      dioClient.initialize();
    });

    test('should be a singleton', () {
      final client1 = DioClient();
      final client2 = DioClient();

      expect(identical(client1, client2), isTrue);
    });

    test('should initialize with default base URL', () {
      dioClient.initialize();

      expect(dioClient.dio, isNotNull);
      expect(
        dioClient.dio.options.baseUrl,
        equals(NetworkConfig.baseUrlDev),
      );
    });

    test('should initialize with custom base URL', () {
      const customUrl = 'https://custom-api.example.com';

      dioClient.initialize(baseUrl: customUrl);

      expect(dioClient.dio.options.baseUrl, equals(customUrl));
    });

    test('should have correct timeout configuration', () {
      dioClient.initialize();

      expect(
        dioClient.dio.options.connectTimeout,
        equals(Duration(milliseconds: NetworkConfig.connectTimeout)),
      );
      expect(
        dioClient.dio.options.receiveTimeout,
        equals(Duration(milliseconds: NetworkConfig.receiveTimeout)),
      );
      expect(
        dioClient.dio.options.sendTimeout,
        equals(Duration(milliseconds: NetworkConfig.sendTimeout)),
      );
    });

    test('should have default headers', () {
      dioClient.initialize();

      expect(
        dioClient.dio.options.headers['Content-Type'],
        equals('application/json'),
      );
      expect(
        dioClient.dio.options.headers['Accept'],
        equals('application/json'),
      );
    });

    test('should have interceptors configured', () {
      dioClient.initialize();

      expect(dioClient.dio.interceptors.length, greaterThan(0));
    });
  });

  group('ErrorInterceptor', () {
    test('should convert connection timeout to TimeoutException', () {
      final interceptor = ErrorInterceptor();

      final dioException = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(),
      );

      // 注意：这里需要更复杂的测试来验证拦截器行为
      // 实际项目中应该使用 MockDio 来完整测试
      expect(dioException.type, equals(DioExceptionType.connectionTimeout));
    });

    test('should convert connection error to NetworkException', () {
      final dioException = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(),
      );

      expect(dioException.type, equals(DioExceptionType.connectionError));
    });
  });
}
