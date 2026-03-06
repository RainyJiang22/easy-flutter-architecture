import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../core/core.dart';

/// 用户列表状态
enum UserListStatus { initial, loading, loaded, error }

/// 用户列表状态类
class UserListState {
  final UserListStatus status;
  final List<User> users;
  final String? errorMessage;

  UserListState({
    this.status = UserListStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  UserListState copyWith({
    UserListStatus? status,
    List<User>? users,
    String? errorMessage,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 用户列表 Notifier
class UserListNotifier extends StateNotifier<UserListState> {
  final UserRepository _repository;

  UserListNotifier(this._repository) : super(UserListState());

  Future<void> loadUsers() async {
    state = state.copyWith(status: UserListStatus.loading);

    final result = await _repository.getUsers();

    if (result.isSuccess) {
      state = state.copyWith(
        status: UserListStatus.loaded,
        users: result.dataOrNull ?? [],
      );
    } else {
      state = state.copyWith(
        status: UserListStatus.error,
        errorMessage: result.errorOrNull,
      );
    }
  }

  Future<void> refresh() async {
    await loadUsers();
  }
}

/// 用户列表 Provider
/// 直接使用 GetIt 获取 Repository 实例，避免 Provider 包装层
final userListProvider =
    StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  return UserListNotifier(getIt<UserRepository>());
});

/// 用户详情 Provider
final userDetailProvider = FutureProvider.autoDispose.family<User?, int>((ref, userId) async {
  final result = await getIt<UserRepository>().getUserById(userId);
  return result.dataOrNull;
});
