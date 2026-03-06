import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/user_provider.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/app_error.dart';

/// 用户列表页面
class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // 页面加载时获取数据
    Future.microtask(() {
      ref.read(userListProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(userListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(UserListState state) {
    switch (state.status) {
      case UserListStatus.initial:
      case UserListStatus.loading:
        return const ListSkeleton(
          itemCount: 5,
          itemHeight: 80,
        );

      case UserListStatus.error:
        return AppError(
          message: state.errorMessage,
          onRetry: () {
            ref.read(userListProvider.notifier).loadUsers();
          },
          fullScreen: false,
        );

      case UserListStatus.loaded:
        if (state.users.isEmpty) {
          return AppEmpty(
            message: '暂无用户数据',
            actionText: '刷新',
            onAction: () {
              ref.read(userListProvider.notifier).refresh();
            },
            fullScreen: false,
          );
        }
        return _buildUserList(state.users);
    }
  }

  Widget _buildUserList(List users) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(userListProvider.notifier).refresh();
      },
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            key: ValueKey(user.id),
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl != null
                  ? CachedNetworkImageProvider(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(user.name[0].toUpperCase())
                  : null,
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/users/${user.id}');
            },
          );
        },
      ),
    );
  }
}

/// 用户详情页面
class UserDetailScreen extends ConsumerWidget {
  final int userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户详情'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const AppEmpty(
              message: '用户不存在',
              fullScreen: false,
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.hasAvatar
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: !user.hasAvatar
                      ? Text(
                          user.name[0].toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${user.id}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => AppError(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(userDetailProvider(userId));
          },
          fullScreen: false,
        ),
      ),
    );
  }
}
