import '../error/exceptions.dart';

/// Result 模式
///
/// 用于统一处理成功和失败，避免散落的 try/catch
sealed class Result<T> {
  const Result();

  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 是否失败
  bool get isFailure => this is Failure<T>;

  /// 获取成功数据（可能为 null）
  T? get dataOrNull => switch (this) {
        Success<T>(data: final data) => data,
        Failure<T>() => null,
      };

  /// 获取错误信息（可能为 null）
  String? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(message: final message) => message,
      };

  /// 转换成功数据
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(data: final data) => Success(transform(data)),
        Failure<T>(message: final message, code: final code) =>
          Failure(message: message, code: code),
      };

  /// 异步转换成功数据
  Future<Result<R>> asyncMap<R>(
    Future<R> Function(T data) transform,
  ) async {
    return switch (this) {
      Success<T>(data: final data) => Success(await transform(data)),
      Failure<T>(message: final message, code: final code) =>
        Failure(message: message, code: code),
    };
  }

  /// 成功时执行回调
  Result<T> onSuccess(void Function(T data) action) {
    if (this case Success<T>(data: final data)) {
      action(data);
    }
    return this;
  }

  /// 失败时执行回调
  Result<T> onFailure(void Function(String message, int? code) action) {
    if (this case Failure<T>(message: final message, code: final code)) {
      action(message, code);
    }
    return this;
  }

  /// 获取数据或默认值
  T getOrElse(T defaultValue) => switch (this) {
        Success<T>(data: final data) => data,
        Failure<T>() => defaultValue,
      };

  /// 获取数据或抛出异常
  T getOrThrow() => switch (this) {
        Success<T>(data: final data) => data,
        Failure<T>(message: final message, code: final code) =>
          throw Exception('[$code] $message'),
      };
}

/// 成功结果
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';
}

/// 失败结果
final class Failure<T> extends Result<T> {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// 扩展方法：便捷创建 Result
extension ResultExtension<T> on T {
  /// 将值包装为成功结果
  Result<T> get success => Success(this);
}

/// 扩展方法：Future 转换为 Result
extension FutureResultExtension<T> on Future<T> {
  /// 将 Future 转换为 Result
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Success(data);
    } catch (e) {
      if (e is ApiException) {
        return Failure(message: e.message, code: e.code);
      }
      return Failure(message: e.toString());
    }
  }
}
