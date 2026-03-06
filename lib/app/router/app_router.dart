import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/user/presentation/screens/user_list_screen.dart';

/// 路由配置
final goRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    // 首页 - 用户列表
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const UserListScreen(),
    ),
    // 用户详情
    GoRoute(
      path: '/users/:id',
      name: 'user-detail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return UserDetailScreen(userId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '页面未找到',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
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
