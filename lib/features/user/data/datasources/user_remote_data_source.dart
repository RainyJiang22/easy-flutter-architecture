import '../../../../core/network/api_client.dart';
import '../dto/user_dto.dart';

/// 用户远程数据源
class UserRemoteDataSource {
  final IApiClient _apiClient;

  UserRemoteDataSource({required IApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<UserDTO>> getUsers() async {
    final result = await _apiClient.get<List<UserDTO>>(
      '/users',
      fromJson: (data) => (data as List)
          .map((json) => UserDTO.fromJson(json as Map<String, dynamic>))
          .toList(),
    );

    return result.getOrThrow();
  }

  Future<UserDTO> getUserById(int id) async {
    final result = await _apiClient.get<UserDTO>(
      '/users/$id',
      fromJson: (data) => UserDTO.fromJson(data as Map<String, dynamic>),
    );

    return result.getOrThrow();
  }

  Future<UserDTO> createUser({
    required String name,
    required String email,
    String? avatar,
  }) async {
    final result = await _apiClient.post<UserDTO>(
      '/users',
      data: {
        'name': name,
        'email': email,
        'avatar': avatar,
      },
      fromJson: (data) => UserDTO.fromJson(data as Map<String, dynamic>),
    );

    return result.getOrThrow();
  }
}
