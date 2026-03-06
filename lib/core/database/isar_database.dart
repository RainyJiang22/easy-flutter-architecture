import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'database_interface.dart';

/// Isar 数据库实现
class IsarDatabase implements IDatabase {
  Isar? _isar;
  DatabaseConfig _config = const DatabaseConfig();
  final List<IDatabaseMigration> _migrations = [];

  @override
  Isar get instance {
    if (_isar == null) {
      throw StateError('数据库未初始化，请先调用 initialize()');
    }
    return _isar!;
  }

  @override
  bool get isInitialized => _isar != null && _isar!.isOpen;

  /// 添加迁移脚本
  void addMigration(IDatabaseMigration migration) {
    _migrations.add(migration);
  }

  @override
  Future<void> initialize({
    DatabaseConfig? config,
    List<CollectionSchema<dynamic>>? schemas,
  }) async {
    if (isInitialized) {
      return;
    }

    _config = config ?? const DatabaseConfig();

    // 确保 schemas 不为空
    if (schemas == null || schemas.isEmpty) {
      throw ArgumentError('必须提供至少一个 CollectionSchema');
    }

    // 获取应用文档目录
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      schemas,
      directory: dir.path,
      name: _config.name,
      inspector: _config.enableLog,
    );

    // 执行数据库迁移
    await _runMigrations();
  }

  @override
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  @override
  Future<void> clearAll() async {
    if (!isInitialized) return;
    await _isar!.clear();
  }

  @override
  Future<int> getSize() async {
    if (!isInitialized) return 0;
    return await _isar!.getSize();
  }

  /// 执行数据库迁移
  Future<void> _runMigrations() async {
    if (_migrations.isEmpty) return;

    // 按版本号排序
    _migrations.sort((a, b) => a.version.compareTo(b.version));

    for (final migration in _migrations) {
      if (migration.version > _config.version) {
        break;
      }
      await migration.migrate(instance);
    }
  }
}
