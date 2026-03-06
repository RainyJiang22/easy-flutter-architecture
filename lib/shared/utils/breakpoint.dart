import 'package:flutter/material.dart';

/// 响应式断点
enum Breakpoint {
  /// 手机竖屏 (< 600)
  mobile,

  /// 手机横屏 / 小平板 (600 - 839)
  tablet,

  /// 大平板 / 桌面 (>= 840)
  desktop,
}

/// 响应式布局工具类
class Responsive {
  final BuildContext context;
  final double width;

  Responsive(this.context) : width = MediaQuery.sizeOf(context).width;

  /// 当前断点
  Breakpoint get breakpoint {
    if (width < 600) return Breakpoint.mobile;
    if (width < 840) return Breakpoint.tablet;
    return Breakpoint.desktop;
  }

  /// 是否为手机
  bool get isMobile => breakpoint == Breakpoint.mobile;

  /// 是否为平板
  bool get isTablet => breakpoint == Breakpoint.tablet;

  /// 是否为桌面
  bool get isDesktop => breakpoint == Breakpoint.desktop;

  /// 是否为窄屏（手机）
  bool get isNarrow => width < 600;

  /// 是否为宽屏（平板及以上）
  bool get isWide => width >= 600;

  /// 根据断点返回不同值
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobile;
      case Breakpoint.tablet:
        return tablet ?? mobile;
      case Breakpoint.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 获取网格列数
  int get gridColumns => value(
        mobile: 2,
        tablet: 3,
        desktop: 4,
      );

  /// 获取内容最大宽度
  double get contentMaxWidth => value(
        mobile: width,
        tablet: 600,
        desktop: 840,
      );

  /// 获取列表项高度
  double get listItemHeight => value(
        mobile: 72,
        tablet: 80,
        desktop: 88,
      );

  /// 获取边距
  EdgeInsets get padding => value(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(24),
        desktop: const EdgeInsets.all(32),
      );
}

/// 响应式构建器
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Responsive responsive) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, Responsive(context));
  }
}

/// 响应式布局组件
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        if (responsive.isDesktop && desktop != null) {
          return desktop!;
        }
        if (responsive.isTablet && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
