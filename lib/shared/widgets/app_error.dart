import 'package:flutter/material.dart';
import 'package:easy_flutter_architecture/core/error/exceptions.dart';

/// 统一的错误状态组件
///
/// 用于展示加载失败时的错误视图，支持自定义图标、文案和重试按钮
class AppError extends StatelessWidget {
  /// 提示文案
  final String? message;

  /// 重试按钮回调
  final VoidCallback? onRetry;

  /// 错误对象
  final dynamic error;

  /// 错误图标
  final IconData icon;

  /// 是否为全屏模式
  final bool fullScreen;

  const AppError({
    super.key,
    this.message,
    this.onRetry,
    this.error,
    this.icon = Icons.error_outline,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final errorMessage = _getErrorMessage();

    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 80, color: colorScheme.error),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            errorMessage,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ],
    );

    return fullScreen ? Scaffold(body: Center(child: widget)) : Center(child: widget);
  }

  String _getErrorMessage() {
    if (message != null) return message!;
    if (error != null) {
      if (error is ApiException) return (error as ApiException).message;
      if (error is NetworkException) return (error as NetworkException).message;
      if (error is TimeoutException) return (error as TimeoutException).message;
      if (error is BusinessException) return (error as BusinessException).message;
      return error.toString();
    }
    return '加载失败，请重试';
  }
}

/// 网络错误组件
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool fullScreen;

  const NetworkError({super.key, this.onRetry, this.fullScreen = true});

  @override
  Widget build(BuildContext context) {
    return AppError(
      icon: Icons.wifi_off_outlined,
      message: '网络连接失败，请检查网络设置',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }
}

/// 超时错误组件
class TimeoutError extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool fullScreen;

  const TimeoutError({super.key, this.onRetry, this.fullScreen = true});

  @override
  Widget build(BuildContext context) {
    return AppError(
      icon: Icons.timer_off_outlined,
      message: '请求超时，请重试',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }
}

/// 服务器错误组件
class ServerError extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool fullScreen;

  const ServerError({super.key, this.onRetry, this.fullScreen = true});

  @override
  Widget build(BuildContext context) {
    return AppError(
      icon: Icons.cloud_off_outlined,
      message: '服务器开小差了，请稍后再试',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }
}
