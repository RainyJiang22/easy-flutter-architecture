import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';

///侧滑菜单
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerMenuItem(
                  icon: Icons.home_outlined,
                  label: '首页',
                  path: RoutePaths.home,
                  isSelected: currentPath == RoutePaths.home,
                ),
                _DrawerMenuItem(
                  icon: Icons.person_outline,
                  label: '个人中心',
                  path: RoutePaths.profile,
                  isSelected: currentPath == RoutePaths.profile,
                ),
                _DrawerMenuItem(
                  icon: Icons.settings_outlined,
                  label: '设置',
                  path: RoutePaths.settings,
                  isSelected: currentPath == RoutePaths.settings,
                ),
                _DrawerMenuItem(
                  icon: Icons.info_outline,
                  label: '关于',
                  path: RoutePaths.about,
                  isSelected: currentPath == RoutePaths.about,
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }
}

/// 构建Drawer头部 用户信息
Widget _buildHeader(BuildContext context) {
  return UserAccountsDrawerHeader(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    currentAccountPicture: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(
        Icons.person,
        size: 40,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    ),
    accountName: Text(
      '用户昵称',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
    accountEmail: Text(
      'user@example.com',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}

///构建 Drawer底部 版本信息
Widget _buildFooter(BuildContext context) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            '版本1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );
}

/// 菜单项组件
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: () {
        // 关闭 Drawer
        Navigator.of(context).pop();
        // 导航到目标页面
        context.go(path);
      },
    );
  }
}
