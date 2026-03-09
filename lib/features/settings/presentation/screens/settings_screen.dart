
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



/// 设置页面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: '外观',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: '深色模式',
                trailing: Switch(
                  value: false, // TODO: 从 Provider 获取
                  onChanged: (value) {
                    // TODO: 更新主题状态
                  },
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: '通用',
            children: [
              _SettingsTile(
                icon: Icons.language_outlined,
                title: '语言',
                subtitle: '简体中文',
                onTap: () {
                  // TODO: 打开语言选择
                },
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: '缓存',
                subtitle: '0 MB',
                onTap: () {
                  // TODO: 清理缓存
                },
              ),
            ],
          ),
          _SettingsSection(
            title: '数据',
            children: [
              _SettingsTile(
                icon: Icons.cloud_off_outlined,
                title: '离线模式',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: 切换离线模式
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 设置分组
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}

/// 设置项
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}