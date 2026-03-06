import 'package:isar/isar.dart';
import '../database/database_interface.dart';
import '../database/models/user_cache_model.dart';

/// 数据库缓存服务
///
/// 提供通用的缓存操作，支持过期时间
class CacheService {
  final IDatabase _database;

  CacheService({required IDatabase database}) : _database = database;

  Isar get _isar => _database.instance;

  // ==================== 用户缓存 ====================

  /// 保存用户缓存
  Future<void> saveUser(UserCacheModel user) async {
    await _isar.writeTxn(() async {
      await _isar.userCacheModels.put(user);
    });
  }

  /// 批量保存用户缓存
  Future<void> saveUsers(List<UserCacheModel> users) async {
    await _isar.writeTxn(() async {
      await _isar.userCacheModels.putAll(users);
    });
  }

  /// 根据 ID 获取用户缓存
  Future<UserCacheModel?> getUser(int userId) async {
    final user = await _isar.userCacheModels
        .where()
        .userIdEqualTo(userId)
        .findFirst();

    if (user != null && user.isExpired) {
      await deleteUser(userId);
      return null;
    }

    return user;
  }

  /// 获取所有有效用户缓存
  Future<List<UserCacheModel>> getAllUsers() async {
    final users = await _isar.userCacheModels.where().findAll();

    // 过滤掉过期数据
    final validUsers = users.where((u) => !u.isExpired).toList();

    // 删除过期数据
    final expiredIds = users.where((u) => u.isExpired).map((u) => u.id).toList();
    if (expiredIds.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.userCacheModels.deleteAll(expiredIds);
      });
    }

    return validUsers;
  }

  /// 删除用户缓存
  Future<bool> deleteUser(int userId) async {
    return await _isar.writeTxn(() async {
      return await _isar.userCacheModels
          .where()
          .userIdEqualTo(userId)
          .deleteFirst();
    });
  }

  /// 清空所有用户缓存
  Future<void> clearAllUsers() async {
    await _isar.writeTxn(() async {
      await _isar.userCacheModels.clear();
    });
  }

  /// 监听用户缓存变化
  Stream<void> watchUsers() {
    return _isar.userCacheModels.watchLazy();
  }

  // ==================== 通用缓存操作 ====================

  /// 清理所有过期缓存
  Future<int> cleanExpiredCache() async {
    final users = await _isar.userCacheModels.where().findAll();
    final expiredIds = users.where((u) => u.isExpired).map((u) => u.id).toList();

    if (expiredIds.isEmpty) return 0;

    await _isar.writeTxn(() async {
      await _isar.userCacheModels.deleteAll(expiredIds);
    });

    return expiredIds.length;
  }

  /// 获取缓存统计
  Future<CacheStats> getStats() async {
    final userCount = await _isar.userCacheModels.count();
    final dbSize = await _database.getSize();

    return CacheStats(
      userCount: userCount,
      totalSizeBytes: dbSize,
    );
  }
}

/// 缓存统计信息
class CacheStats {
  final int userCount;
  final int totalSizeBytes;

  const CacheStats({
    required this.userCount,
    required this.totalSizeBytes,
  });

  String get formattedSize {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
