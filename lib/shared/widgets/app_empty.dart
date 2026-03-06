import 'package:flutter/material.dart';

/// 统一的空状态组件
///
/// 用于展示无数据时的占位视图，支持自定义图标、文案和操作按钮
class AppEmpty extends StatelessWidget {
  /// 提示文案
  final String? message;

  /// 操作按钮文案
  final String? actionText;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 图标
  final IconData icon;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 是否为全屏模式
  final bool fullScreen;

  const AppEmpty({
    super.key,
    this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 80,
    this.iconColor,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          message ?? '暂无数据',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh),
            label: Text(actionText!),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(child: widget),
      );
    }

    return Center(child: widget);
  }
}

/// 搜索结果为空组件
class SearchEmpty extends StatelessWidget {
  /// 搜索关键词
  final String? keyword;

  /// 操作按钮回调
  final VoidCallback? onClear;

  const SearchEmpty({
    super.key,
    this.keyword,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmpty(
      icon: Icons.search_off_outlined,
      message: keyword != null
          ? '未找到"$keyword"相关内容'
          : '未找到相关内容',
      actionText: onClear != null ? '清除搜索' : null,
      onAction: onClear,
    );
  }
}

/// 网络错误空状态组件
class NetworkEmpty extends StatelessWidget {
  /// 重试回调
  final VoidCallback? onRetry;

  const NetworkEmpty({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmpty(
      icon: Icons.wifi_off_outlined,
      message: '网络连接失败',
      actionText: onRetry != null ? '重试' : null,
      onAction: onRetry,
    );
  }
}

/// 无权限空状态组件
class PermissionEmpty extends StatelessWidget {
  /// 提示文案
  final String? message;

  /// 操作按钮回调
  final VoidCallback? onRequest;

  const PermissionEmpty({
    super.key,
    this.message,
    this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmpty(
      icon: Icons.lock_outline,
      message: message ?? '暂无访问权限',
      actionText: onRequest != null ? '申请权限' : null,
      onAction: onRequest,
    );
  }
}
