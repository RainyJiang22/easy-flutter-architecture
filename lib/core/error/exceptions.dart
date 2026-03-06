/// 统一 API 异常
class ApiException implements Exception {
  /// 错误码
  final int? code;

  /// 错误消息
  final String message;

  /// 附加数据
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

/// 网络异常
class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(message: message ?? '网络连接失败，请检查网络设置');
}

/// 超时异常
class TimeoutException extends ApiException {
  TimeoutException({String? message})
      : super(message: message ?? '请求超时，请稍后重试');
}

/// 业务异常
class BusinessException extends ApiException {
  BusinessException({
    String? message,
    int? code,
    super.data,
  }) : super(
          code: code,
          message: message ?? '业务处理失败',
        );
}
