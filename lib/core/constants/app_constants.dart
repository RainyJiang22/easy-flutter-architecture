/// 全局常量
class AppConstants {
  AppConstants._();

  // ==================== 应用信息 ====================

  /// 应用名称
  static const String appName = 'Easy Flutter Architecture';

  /// 版本号
  static const String version = '1.0.0';

  // ==================== 存储 Key ====================

  /// 认证 Token
  static const String keyAuthToken = 'auth_token';

  /// 用户信息
  static const String keyUserInfo = 'user_info';

  /// 用户偏好设置
  static const String keyUserPreferences = 'user_preferences';

  /// 主题模式
  static const String keyThemeMode = 'theme_mode';

  /// 语言设置
  static const String keyLocale = 'locale';

  /// 最后更新时间
  static const String keyLastUpdateTime = 'last_update_time';

  // ==================== 间距常量（遵循 8px 网格）====================

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // ==================== 圆角常量 ====================

  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;

  // ==================== 动画时长（毫秒）====================

  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 400;
  static const int animationDurationLong = 600;

  // ==================== 最小点击区域 ====================

  /// 最小点击区域尺寸（无障碍规范 48dp）
  static const double minTouchTargetSize = 48.0;
}
