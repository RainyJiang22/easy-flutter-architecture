import 'package:flutter/material.dart';
import 'package:easy_flutter_architecture/core/core.dart';

/// 应用初始化
///
/// 统一管理应用的初始化流程
class AppInitializer {
  /// 初始化应用
  static Future<void> initialize({
    String? baseUrl,
    bool isProduction = false,
    Future<void> Function()? onUnauthorized,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    // 配置依赖注入（包含网络客户端初始化）
    await configureDependencies(
      baseUrl: baseUrl,
      isProduction: isProduction,
      onUnauthorized: onUnauthorized,
    );

    // 其他初始化逻辑
    // TODO: 添加应用启动时需要执行的初始化
  }
}
