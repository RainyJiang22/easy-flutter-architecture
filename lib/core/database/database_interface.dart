import 'package:isar/isar.dart';

/// 数据库配置
class DatabaseConfig {
  /// 数据库名称
  final String name;

  /// 数据库版本
  final int version;

  /// 是否启用日志
  final bool enableLog;

  const DatabaseConfig({
    this.name = 'app_database',
    this.version = 1,
    this.enableLog = false,
  });
}

/// 本地数据库抽象接口
///
/// 提供数据库的统一操作接口，业务层通过此接口访问数据库
abstract class IDatabase {
  /// 获取 Isar 实例
  Isar get instance;

  /// 数据库是否已初始化
  bool get isInitialized;

  /// 初始化数据库
  Future<void> initialize({
    DatabaseConfig? config,
    List<CollectionSchema<dynamic>>? schemas,
  });

  /// 关闭数据库
  Future<void> close();

  /// 清空所有数据
  Future<void> clearAll();

  /// 获取数据库大小（字节）
  Future<int> getSize();
}

/// 数据库迁移接口
///
/// 用于处理数据库版本升级
abstract class IDatabaseMigration {
  /// 迁移版本号
  int get version;

  /// 执行迁移
  Future<void> migrate(Isar isar);
}
