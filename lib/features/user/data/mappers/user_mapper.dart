import '../dto/user_dto.dart';
import '../../domain/entities/user.dart';

/// User Mapper
class UserMapper {
  static User toEntity(UserDTO dto) {
    return User(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      avatarUrl: dto.avatar,
    );
  }

  static UserDTO toDTO(User entity) {
    return UserDTO(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatarUrl,
    );
  }

  static List<User> toEntityList(List<UserDTO> dtoList) {
    return dtoList.map((dto) => toEntity(dto)).toList();
  }
}
