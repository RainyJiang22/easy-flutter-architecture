/// Token 提供者抽象接口
///
/// 用于解耦网络层与存储层，由应用层实现具体逻辑
abstract class AuthTokenProvider {
  /// 获取当前 Token
  Future<String?> getToken();

  /// 保存 Token
  Future<void> saveToken(String token);

  /// 清除 Token
  Future<void> clearToken();

  /// Token 失效回调（可用于跳转登录页）
  Future<void> onUnauthorized();
}

/// 基于 ISecureStorage 的 Token 提供者实现
///
/// 通过依赖注入获取存储实例，避免循环依赖
class SecureStorageTokenProvider implements AuthTokenProvider {
  final Future<String?> Function(String) read;
  final Future<void> Function(String, String) write;
  final Future<void> Function(String) delete;
  final Future<void> Function()? onUnauthorizedCallback;

  static const _tokenKey = 'auth_token';

  SecureStorageTokenProvider({
    required this.read,
    required this.write,
    required this.delete,
    this.onUnauthorizedCallback,
  });

  @override
  Future<String?> getToken() => read(_tokenKey);

  @override
  Future<void> saveToken(String token) => write(_tokenKey, token);

  @override
  Future<void> clearToken() => delete(_tokenKey);

  @override
  Future<void> onUnauthorized() async {
    await onUnauthorizedCallback?.call();
  }
}
