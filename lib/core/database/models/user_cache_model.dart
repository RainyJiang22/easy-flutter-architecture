import 'package:isar/isar.dart';

part 'user_cache_model.g.dart';

/// 用户缓存模型
///
/// 用于本地缓存用户数据，支持离线访问
@collection
class UserCacheModel {
  /// Isar ID（自增主键）
  Id id = Isar.autoIncrement;

  /// 用户 ID（业务主键）
  @Index(unique: true)
  late int userId;

  /// 用户名
  late String name;

  /// 邮箱
  late String email;

  /// 头像 URL
  String? avatarUrl;

  /// 缓存时间戳
  late DateTime cachedAt;

  /// 数据过期时间（秒）
  late int ttlSeconds;

  /// 是否已过期
  bool get isExpired {
    final expiresAt = cachedAt.add(Duration(seconds: ttlSeconds));
    return DateTime.now().isAfter(expiresAt);
  }

  /// 创建 UserCacheModel
  static UserCacheModel create({
    required int userId,
    required String name,
    required String email,
    String? avatarUrl,
    int ttlSeconds = 86400, // 默认 24 小时
  }) {
    return UserCacheModel()
      ..userId = userId
      ..name = name
      ..email = email
      ..avatarUrl = avatarUrl
      ..cachedAt = DateTime.now()
      ..ttlSeconds = ttlSeconds;
  }
}
