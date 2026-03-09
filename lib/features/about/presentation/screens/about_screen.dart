import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          //应用图标和名称
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.flutter_dash,
                    size: 48,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '版本1.0.0',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .outline,
                  ),
                ),
                const SizedBox(height: 32),
                //链接列表
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text('源代码'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    //Todo : 打开github
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('开源许可'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(
                        context: context,
                        applicationName: 'Easy Flutter Architecture',
                        applicationVersion: '1.0.0'
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    //TODO 打开隐私政策
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('反馈建议'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    //TODO 打开反馈页面
                  },
                ),
                const SizedBox(height: 32),
                // 版权信息
                Center(
                  child: Text(
                    '© 2026 Easy Flutter Architecture',
                    style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                      Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
