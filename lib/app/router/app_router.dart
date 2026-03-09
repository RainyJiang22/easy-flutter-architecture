import 'package:easy_flutter_architecture/shared/widgets/shell_with_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/user/presentation/screens/user_list_screen.dart';
import '../../shared/widgets/app_error.dart';
import 'route_names.dart';

/// 路由配置
final goRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: RoutePaths.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellWithDrawer(child: child),
      routes: [
        // 首页 - 用户列表
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (context, state) => const
          UserListScreen(),
        ),
        // 设置页
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (context, state) => const
          SettingsScreen(),
        ),
        // 个人中心
        GoRoute(
          path: RoutePaths.profile,
          name: RouteNames.profile,
          builder: (context, state) => const
          ProfileScreen(),
        ),
        // 关于页
        GoRoute(
          path: RoutePaths.about,
          name: RouteNames.about,
          builder: (context, state) => const
          AboutScreen(),
        ),
      ],
    ),

    // ===== 不带 Drawer 的独立路由 =====
    // // 首页 - 用户列表
    // GoRoute(
    //   path: RoutePaths.home,
    //   name: RouteNames.home,
    //   builder: (context, state) => const UserListScreen(),
    // ),
    // // 用户详情
    GoRoute(
      path: RoutePaths.userDetail,
      name: RouteNames.userDetail,
      builder: (context, state) {
        // 安全解析参数
        final idStr = state.pathParameters[RouteParams.userId];
        final id = int.tryParse(idStr ?? '');
        if (id == null) {
          return const AppError(message: '无效的用户ID', fullScreen: true);
        }
        return UserDetailScreen(userId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('页面未找到', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.home),
            child: const Text('返回首页'),
          ),
        ],
      ),
    ),
  ),
);

/// 路由配置
class AppRouter {
  static GoRouter get router => goRouter;
}
