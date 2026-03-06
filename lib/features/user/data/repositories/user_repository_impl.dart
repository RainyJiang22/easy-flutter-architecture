import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../mappers/user_mapper.dart';
import '../../../../core/utils/result.dart';

/// User Repository 实现
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl({UserRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? UserRemoteDataSource();

  @override
  Future<Result<List<User>>> getUsers() async {
    try {
      final dtoList = await _remoteDataSource.getUsers();
      final users = UserMapper.toEntityList(dtoList);
      return Success(users);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<User>> getUserById(int id) async {
    try {
      final dto = await _remoteDataSource.getUserById(id);
      final user = UserMapper.toEntity(dto);
      return Success(user);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<User>> createUser({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    try {
      final dto = await _remoteDataSource.createUser(
        name: name,
        email: email,
        avatar: avatarUrl,
      );
      final user = UserMapper.toEntity(dto);
      return Success(user);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
