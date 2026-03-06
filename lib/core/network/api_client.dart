import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../utils/result.dart';
import 'dio_client.dart';

/// API Client 抽象接口
///
/// 业务层通过此接口调用网络请求，不直接依赖 Dio
abstract class IApiClient {
  /// GET 请求
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  });

  /// POST 请求
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  });

  /// PUT 请求
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  });

  /// DELETE 请求
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  });

  /// 上传文件
  Future<Result<T>> upload<T>(
    String path, {
    required FormData formData,
    required T Function(dynamic data) fromJson,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  });

  /// 下载文件
  Future<Result<void>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  });
}

/// API Client 实现
class ApiClient implements IApiClient {
  final Dio _dio;

  ApiClient({Dio? dio}) : _dio = dio ?? DioClient().dio;

  @override
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final data = fromJson(response.data);
      return Success(data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = fromJson(response.data);
      return Success(result);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = fromJson(response.data);
      return Success(result);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = fromJson(response.data);
      return Success(result);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<Result<T>> upload<T>(
    String path, {
    required FormData formData,
    required T Function(dynamic data) fromJson,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      final result = fromJson(response.data);
      return Success(result);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  @override
  Future<Result<void>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return const Success(null);
    } catch (e) {
      return _handleError<void>(e);
    }
  }

  /// 统一错误处理
  Result<T> _handleError<T>(dynamic error) {
    if (error is DioException && error.error is ApiException) {
      final apiException = error.error as ApiException;
      return Failure(
        message: apiException.message,
        code: apiException.code,
      );
    }

    if (error is ApiException) {
      return Failure(message: error.message, code: error.code);
    }

    return Failure(message: error.toString());
  }
}
