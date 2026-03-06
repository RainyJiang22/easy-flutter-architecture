import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_impl.dart';
import '../storage/shared_prefs_storage.dart';
import '../storage/storage_interface.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';

/// 全局服务定位器
final getIt = GetIt.instance;

/// 初始化依赖注入
///
/// 在应用启动时调用，注册所有核心服务
Future<void> configureDependencies({
  String? baseUrl,
  bool isProduction = false,
}) async {
  // ==================== 核心层服务注册 ====================

  // 1. 注册网络层
  _registerNetworkServices(baseUrl: baseUrl);

  // 2. 注册存储层
  await _registerStorageServices();

  // 3. 注册业务层服务
  _registerDomainServices();

  // 4. 注册其他核心服务
  // TODO: 根据需要添加更多服务
}

/// 注册网络层服务
void _registerNetworkServices({String? baseUrl}) {
  // 注册 DioClient 单例
  getIt.registerSingleton<DioClient>(
    DioClient()..initialize(baseUrl: baseUrl),
  );

  // 注册 ApiClient 单例
  getIt.registerSingleton<IApiClient>(
    ApiClient(dio: getIt<DioClient>().dio),
  );
}

/// 注册存储层服务
Future<void> _registerStorageServices() async {
  // 初始化 SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // 注册 SharedPreferences 存储
  getIt.registerSingleton<IKVStorage>(
    SharedPrefsStorage(sharedPreferences),
  );

  // 注册安全存储
  getIt.registerSingleton<ISecureStorage>(
    SecureStorageImpl(),
  );
}

/// 注册业务层服务
void _registerDomainServices() {
  // 注册用户 Repository
  getIt.registerSingleton<UserRepository>(UserRepositoryImpl());
}

/// 重置依赖注入（主要用于测试）
Future<void> resetDependencies() async {
  await getIt.reset();
}
