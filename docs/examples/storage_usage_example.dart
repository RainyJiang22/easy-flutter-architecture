/// 存储层使用示例
///
/// 本文件展示如何在实际项目中使用存储层封装

import 'package:easy_flutter_architecture/core/core.dart';

// ==================== 使用 IKVStorage ====================

/// 示例：用户配置管理
class UserConfigService {
  final IKVStorage _storage;

  UserConfigService({IKVStorage? storage})
      : _storage = storage ?? getIt<IKVStorage>();

  static const String _keyTheme = 'theme_mode';
  static const String _keyLanguage = 'language_code';
  static const String _keyNotifications = 'notifications_enabled';

  /// 获取主题模式
  Future<String> getThemeMode() async {
    return await _storage.getString(_keyTheme) ?? 'system';
  }

  /// 设置主题模式
  Future<void> setThemeMode(String mode) async {
    await _storage.setString(_keyTheme, mode);
  }

  /// 获取语言代码
  Future<String> getLanguageCode() async {
    return await _storage.getString(_keyLanguage) ?? 'zh';
  }

  /// 设置语言代码
  Future<void> setLanguageCode(String code) async {
    await _storage.setString(_keyLanguage, code);
  }

  /// 是否启用通知
  Future<bool> isNotificationsEnabled() async {
    return await _storage.getBool(_keyNotifications) ?? true;
  }

  /// 设置通知开关
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.setBool(_keyNotifications, enabled);
  }

  /// 清除所有配置
  Future<void> clearAll() async {
    await _storage.remove(_keyTheme);
    await _storage.remove(_keyLanguage);
    await _storage.remove(_keyNotifications);
  }
}

// ==================== 使用 ISecureStorage ====================

/// 示例：认证服务
class AuthService {
  final ISecureStorage _secureStorage;
  final IKVStorage _kvStorage;

  AuthService({
    ISecureStorage? secureStorage,
    IKVStorage? kvStorage,
  })  : _secureStorage = secureStorage ?? getIt<ISecureStorage>(),
        _kvStorage = kvStorage ?? getIt<IKVStorage>();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';

  /// 保存 Token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.save(_keyAccessToken, accessToken);
    await _secureStorage.save(_keyRefreshToken, refreshToken);
  }

  /// 获取访问 Token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(_keyAccessToken);
  }

  /// 获取刷新 Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(_keyRefreshToken);
  }

  /// 保存用户 ID（可以存储在普通存储中）
  Future<void> saveUserId(int userId) async {
    await _kvStorage.setInt(_keyUserId, userId);
  }

  /// 获取用户 ID
  Future<int?> getUserId() async {
    return await _kvStorage.getInt(_keyUserId);
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 清除登录信息
  Future<void> logout() async {
    await _secureStorage.delete(_keyAccessToken);
    await _secureStorage.delete(_keyRefreshToken);
    await _kvStorage.remove(_keyUserId);
  }
}

// ==================== 在 UI 层使用（伪代码） ====================

/// 示例：在页面中使用存储
///
/// ```dart
/// class SettingsPage extends StatefulWidget {
///   @override
///   _SettingsPageState createState() => _SettingsPageState();
/// }
///
/// class _SettingsPageState extends State<SettingsPage> {
///   final UserConfigService _configService = UserConfigService();
///   String _themeMode = 'system';
///
///   @override
///   void initState() {
///     super.initState();
///     _loadConfig();
///   }
///
///   Future<void> _loadConfig() async {
///     final theme = await _configService.getThemeMode();
///     setState(() {
///       _themeMode = theme;
///     });
///   }
///
///   Future<void> _changeTheme(String mode) async {
///     await _configService.setThemeMode(mode);
///     setState(() {
///       _themeMode = mode;
///     });
///     // 应用主题变更
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('设置')),
///       body: ListView(
///         children: [
///           ListTile(
///             title: Text('主题模式'),
///             subtitle: Text(_themeMode),
///             onTap: () => _showThemeDialog(),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```

// ==================== 高级用法示例 ====================

/// 示例：缓存管理
class CacheService {
  final IKVStorage _storage;

  CacheService({IKVStorage? storage})
      : _storage = storage ?? getIt<IKVStorage>();

  /// 保存缓存（带时间戳）
  Future<void> saveCache<T>(
    String key,
    T value, {
    Duration? duration,
  }) async {
    final expireTime = duration != null
        ? DateTime.now().add(duration).millisecondsSinceEpoch
        : null;

    // 存储过期时间
    if (expireTime != null) {
      await _storage.setInt('${key}_expire', expireTime);
    }

    // 根据类型存储值
    if (value is String) {
      await _storage.setString(key, value);
    } else if (value is bool) {
      await _storage.setBool(key, value);
    } else if (value is int) {
      await _storage.setInt(key, value);
    } else if (value is double) {
      await _storage.setDouble(key, value);
    }
    // 复杂对象可以转为 JSON 字符串存储
  }

  /// 获取缓存（检查过期）
  Future<T?> getCache<T>(String key) async {
    // 检查是否过期
    final expireTime = await _storage.getInt('${key}_expire');
    if (expireTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expireTime) {
        // 已过期，清除缓存
        await _storage.remove(key);
        await _storage.remove('${key}_expire');
        return null;
      }
    }

    // 根据类型返回值
    if (T == String) {
      return await _storage.getString(key) as T?;
    } else if (T == bool) {
      return await _storage.getBool(key) as T?;
    } else if (T == int) {
      return await _storage.getInt(key) as T?;
    } else if (T == double) {
      return await _storage.getDouble(key) as T?;
    }

    return null;
  }

  /// 清除过期缓存
  Future<void> clearExpiredCache() async {
    final keys = await _storage.getKeys();
    final expireKeys = keys.where((key) => key.endsWith('_expire'));

    for (final expireKey in expireKeys) {
      final expireTime = await _storage.getInt(expireKey);
      if (expireTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expireTime) {
          // 清除缓存
          final key = expireKey.replaceAll('_expire', '');
          await _storage.remove(key);
          await _storage.remove(expireKey);
        }
      }
    }
  }
}

/// 使用示例
void exampleUsage() async {
  // 1. 用户配置
  final configService = UserConfigService();
  await configService.setThemeMode('dark');
  await configService.setLanguageCode('en');
  print('Theme: ${await configService.getThemeMode()}');

  // 2. 认证管理
  final authService = AuthService();
  await authService.saveTokens(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
  );
  print('Is logged in: ${await authService.isLoggedIn()}');

  // 3. 缓存管理
  final cacheService = CacheService();
  await cacheService.saveCache(
    'user_profile',
    'cached_data',
    duration: Duration(hours: 1),
  );
  print('Cache: ${await cacheService.getCache<String>('user_profile')}');
}
