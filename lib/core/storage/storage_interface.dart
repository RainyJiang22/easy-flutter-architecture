/// 键值存储抽象接口
///
/// 用于轻量级的键值对存储，适合配置、开关、简单数据
abstract class IKVStorage {
  /// 保存字符串
  Future<void> setString(String key, String value);

  /// 获取字符串
  Future<String?> getString(String key);

  /// 保存布尔值
  Future<void> setBool(String key, bool value);

  /// 获取布尔值
  Future<bool?> getBool(String key);

  /// 保存整数
  Future<void> setInt(String key, int value);

  /// 获取整数
  Future<int?> getInt(String key);

  /// 保存双精度浮点数
  Future<void> setDouble(String key, double value);

  /// 获取双精度浮点数
  Future<double?> getDouble(String key);

  /// 保存字符串列表
  Future<void> setStringList(String key, List<String> value);

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key);

  /// 删除指定 key
  Future<void> remove(String key);

  /// 清空所有数据
  Future<void> clear();

  /// 检查 key 是否存在
  Future<bool> containsKey(String key);

  /// 获取所有 key
  Future<Set<String>> getKeys();
}

/// 安全存储抽象接口
///
/// 用于敏感数据的加密存储，如 Token、密码等
abstract class ISecureStorage {
  /// 保存数据（加密存储）
  Future<void> save(String key, String value);

  /// 读取数据（自动解密）
  Future<String?> read(String key);

  /// 删除指定 key
  Future<void> delete(String key);

  /// 清空所有数据
  Future<void> deleteAll();

  /// 检查 key 是否存在
  Future<bool> containsKey(String key);

  /// 获取所有 key
  Future<Set<String>> getAllKeys();
}
