import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            // 用户头像和信息
            _ProfileHeader(),
            const SizedBox(height: 24),
            // 统计信息
            _ProfileStats(),
            const SizedBox(height: 24),
            // 功能列表
            _ProfileMenuList(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text('用户昵称', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'user@example.com',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

/// 功能菜单列表
class _ProfileMenuList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('编辑资料'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到编辑资料页
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: const Text('浏览历史'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到历史记录页
          },
        ),
        ListTile(
          leading: const Icon(Icons.bookmark_outline),
          title: const Text('我的收藏'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 导航到收藏页
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('退出登录'),
          textColor: Theme.of(context).colorScheme.error,
          iconColor: Theme.of(context).colorScheme.error,
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 执行退出登录逻辑
            },
            child: Text(
              '确定',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
