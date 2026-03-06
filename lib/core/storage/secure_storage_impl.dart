import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_interface.dart';

/// 安全存储实现
///
/// 使用平台级加密存储敏感数据
class SecureStorageImpl implements ISecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageImpl({
    AndroidOptions? androidOptions,
  }) : _storage = FlutterSecureStorage(
          aOptions: androidOptions ??
              const AndroidOptions(
                encryptedSharedPreferences: true,
              ),
        );

  @override
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<Set<String>> getAllKeys() async {
    final map = await _storage.readAll();
    return map.keys.toSet();
  }
}
