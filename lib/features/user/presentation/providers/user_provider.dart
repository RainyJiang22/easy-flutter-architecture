import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../core/di/injection.dart';

/// 用户 Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return getIt<UserRepository>();
});

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
final userListProvider =
    StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserListNotifier(repository);
});

/// 用户详情 Provider
final userDetailProvider = FutureProviderFamily<User?, int>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUserById(userId);
  return result.dataOrNull;
});
