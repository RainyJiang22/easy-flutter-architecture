/// 网络配置
class NetworkConfig {
  NetworkConfig._();

  /// 是否为生产环境
  ///
  /// 控制日志输出、错误上报等行为
  static bool isProduction = false;

  /// 开发环境 BaseUrl (JSONPlaceholder - 免费测试 API)
  static const String baseUrlDev = 'https://jsonplaceholder.typicode.com';

  /// 生产环境 BaseUrl
  static const String baseUrlProd = 'https://jsonplaceholder.typicode.com';

  /// 当前环境的 BaseUrl
  static String get baseUrl => isProduction ? baseUrlProd : baseUrlDev;

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 5000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 15000;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = 10000;

  /// 最大重试次数
  static const int maxRetryCount = 2;

  /// 设置环境
  static set production(bool value) {
    isProduction = value;
  }
}
