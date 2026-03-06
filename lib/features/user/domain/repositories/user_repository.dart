import '../../domain/entities/user.dart';
import '../../../../core/utils/result.dart';

/// 用户 Repository 接口
abstract class UserRepository {
  Future<Result<List<User>>> getUsers();
  Future<Result<User>> getUserById(int id);
  Future<Result<User>> createUser({
    required String name,
    required String email,
    String? avatarUrl,
  });
}
