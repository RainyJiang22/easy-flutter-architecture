/// 用户 DTO (数据传输对象)
class UserDTO {
  final int id;
  final String name;
  final String email;
  final String? avatar;

  UserDTO({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
