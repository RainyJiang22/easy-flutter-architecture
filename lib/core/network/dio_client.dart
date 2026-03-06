import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import 'auth_token_provider.dart';
import 'network_config.dart';

/// Dio 单例客户端
///
/// 全局唯一的网络客户端实例，统一配置拦截器、超时、重试等策略
class DioClient {
  DioClient._internal();

  static final DioClient _instance = DioClient._internal();

  /// 获取单例实例
  factory DioClient() => _instance;

  Dio? _dio;

  /// 获取 Dio 实例
  Dio get dio => _dio ??= _createDio();

  /// 是否已初始化
  bool get isInitialized => _dio != null;

  /// 创建基础配置
  BaseOptions _createBaseOptions({String? baseUrl}) {
    return BaseOptions(
      baseUrl: baseUrl ?? NetworkConfig.baseUrlDev,
      connectTimeout: const Duration(
        milliseconds: NetworkConfig.connectTimeout,
      ),
      receiveTimeout: const Duration(
        milliseconds: NetworkConfig.receiveTimeout,
      ),
      sendTimeout: const Duration(milliseconds: NetworkConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// 创建 Dio 实例
  Dio _createDio() {
    return Dio(_createBaseOptions())
      ..interceptors.addAll(_getDefaultInterceptors());
  }

  /// 初始化 Dio 客户端
  ///
  /// 可自定义 baseUrl 和额外拦截器
  void initialize({
    String? baseUrl,
    List<Interceptor>? interceptors,
    AuthTokenProvider? tokenProvider,
  }) {
    // 如果已经初始化，直接返回
    if (isInitialized) {
      return;
    }

    _dio = Dio(_createBaseOptions(baseUrl: baseUrl));

    // 添加拦截器
    _dio!.interceptors.addAll([
      ...?interceptors,
      ..._getDefaultInterceptors(tokenProvider: tokenProvider),
    ]);
  }

  /// 重置（主要用于测试）
  void reset() {
    _dio = null;
  }

  /// 获取默认拦截器链
  List<Interceptor> _getDefaultInterceptors({AuthTokenProvider? tokenProvider}) {
    return [
      _LoggingInterceptor(),
      AuthInterceptor(tokenProvider: tokenProvider),
      ErrorInterceptor(),
      RetryInterceptor(),
    ];
  }
}

/// 日志拦截器
///
/// 根据环境控制日志输出，过滤敏感信息
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 开发环境打印请求日志
    if (!NetworkConfig.isProduction) {
      final sanitizedHeaders = _sanitizeHeaders(options.headers);
      // ignore: avoid_print
      print('[DIO] >>> ${options.method} ${options.uri}');
      // ignore: avoid_print
      print('[DIO] Headers: $sanitizedHeaders');
      if (options.data != null) {
        // ignore: avoid_print
        print('[DIO] Data: ${_sanitizeData(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!NetworkConfig.isProduction) {
      // ignore: avoid_print
      print('[DIO] <<< ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[DIO] ERROR: ${err.type} ${err.requestOptions.uri}');
    handler.next(err);
  }

  /// 过滤敏感 Header
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return {};
    final sanitized = Map<String, dynamic>.from(headers);
    const sensitiveKeys = ['authorization', 'token', 'password', 'secret'];
    for (final key in sanitized.keys) {
      if (sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
        sanitized[key] = '***';
      }
    }
    return sanitized;
  }

  /// 过滤敏感数据
  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = Map<String, dynamic>.from(data);
      const sensitiveKeys = ['password', 'token', 'secret', 'confirmPassword'];
      for (final key in sanitized.keys) {
        if (sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
          sanitized[key] = '***';
        }
      }
      return sanitized;
    }
    return data;
  }
}

/// 认证拦截器
///
/// 自动添加 Token 到请求头，处理 401 认证失败
class AuthInterceptor extends Interceptor {
  final AuthTokenProvider? tokenProvider;

  AuthInterceptor({this.tokenProvider});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 从 TokenProvider 获取 Token
    final token = await tokenProvider?.getToken() ?? '';

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理 401 未授权
    if (err.response?.statusCode == 401) {
      // 清除本地 Token
      await tokenProvider?.clearToken();

      // 通知认证状态变更（可用于跳转登录页）
      await tokenProvider?.onUnauthorized();
    }

    handler.next(err);
  }
}

/// 错误处理拦截器
///
/// 统一转换 DioException 为业务异常
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _convertError(err);

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  /// 转换 Dio 错误为业务异常
  ApiException _convertError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        return _handleResponseError(err);

      case DioExceptionType.cancel:
        return ApiException(message: '请求已取消');

      case DioExceptionType.badCertificate:
        return ApiException(message: '证书验证失败');

      case DioExceptionType.unknown:
        if (err.error?.toString().contains('SocketException') ?? false) {
          return NetworkException();
        }
        return ApiException(message: err.message ?? '未知网络错误');
    }
  }

  /// 处理响应错误
  ApiException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    String message;
    int? code;

    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? '请求失败';
      code = data['code'] as int?;
    } else {
      message = _getHttpStatusMessage(statusCode);
    }

    return BusinessException(
      code: code ?? statusCode,
      message: message,
      data: data,
    );
  }

  /// 获取 HTTP 状态码对应的消息
  String _getHttpStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败 ($statusCode)';
    }
  }
}

/// 重试拦截器
///
/// 对失败请求自动重试（仅幂等方法：GET/PUT/DELETE），使用指数退避策略
class RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 仅对幂等方法重试
    if (!_isIdempotent(err.requestOptions.method)) {
      handler.next(err);
      return;
    }

    // 判断是否需要重试
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    // 获取已重试次数
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // 达到最大重试次数
    if (retryCount >= NetworkConfig.maxRetryCount) {
      handler.next(err);
      return;
    }

    // 指数退避延迟：1s, 2s, 4s...
    final delaySeconds = 1 << retryCount; // 2^retryCount
    await Future.delayed(Duration(seconds: delaySeconds));

    try {
      // 增加重试计数
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // 重新发起请求
      final response = await DioClient().dio.fetch(err.requestOptions);

      handler.resolve(response);
    } catch (e) {
      // 重试失败，继续传递错误
      handler.next(err);
    }
  }

  /// 判断是否为幂等方法
  bool _isIdempotent(String method) {
    return ['GET', 'PUT', 'DELETE', 'HEAD'].contains(method.toUpperCase());
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    // 连接错误或超时重试
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // 5xx 服务器错误重试
    final statusCode = err.response?.statusCode ?? 0;
    if (statusCode >= 500 && statusCode < 600) {
      return true;
    }

    return false;
  }
}
