/// 用户实体
class User {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  /// 显示名称
  String get displayName => name.isEmpty ? email : name;

  /// 是否有头像
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
