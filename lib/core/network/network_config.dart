/// 网络配置
class NetworkConfig {
  NetworkConfig._();

  /// 开发环境 BaseUrl
  static const String baseUrlDev = 'https://dev-api.example.com';

  /// 生产环境 BaseUrl
  static const String baseUrlProd = 'https://api.example.com';

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 5000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 15000;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = 10000;

  /// 最大重试次数
  static const int maxRetryCount = 2;
}
