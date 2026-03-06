/// 网络层使用示例
///
/// 本文件展示如何在实际项目中使用网络层封装

import 'package:easy_flutter_architecture/core/core.dart';

// ==================== DTO 定义 ====================

/// 用户 DTO
class UserDTO {
  final int id;
  final String name;
  final String email;

  UserDTO({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

// ==================== API Service 定义 ====================

/// 用户 API 服务
class UserApiService {
  final IApiClient _apiClient;

  UserApiService({IApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 获取用户列表
  Future<Result<List<UserDTO>>> getUsers() async {
    return _apiClient.get<List<UserDTO>>(
      '/users',
      fromJson: (data) {
        return (data as List)
            .map((json) => UserDTO.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 获取单个用户
  Future<Result<UserDTO>> getUserById(int id) async {
    return _apiClient.get<UserDTO>(
      '/users/$id',
      fromJson: (data) => UserDTO.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 创建用户
  Future<Result<UserDTO>> createUser({
    required String name,
    required String email,
  }) async {
    return _apiClient.post<UserDTO>(
      '/users',
      data: {
        'name': name,
        'email': email,
      },
      fromJson: (data) => UserDTO.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 获取用户列表（分页）
  Future<Result<PageResult<UserDTO>>> getUsersPage({
    required int page,
    int pageSize = 20,
  }) async {
    return _apiClient.get<PageResult<UserDTO>>(
      '/users',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (data) {
        return PageResult<UserDTO>.fromJson(
          data as Map<String, dynamic>,
          (json) => UserDTO.fromJson(json as Map<String, dynamic>),
        );
      },
    );
  }
}

// ==================== 在 Repository 中使用 ====================

/// 用户 Repository 接口
abstract class UserRepository {
  Future<Result<List<UserDTO>>> getUsers();
  Future<Result<UserDTO>> getUserById(int id);
}

/// 用户 Repository 实现
class UserRepositoryImpl implements UserRepository {
  final UserApiService _apiService;

  UserRepositoryImpl({UserApiService? apiService})
      : _apiService = apiService ?? UserApiService();

  @override
  Future<Result<List<UserDTO>>> getUsers() async {
    // 可以在这里添加缓存逻辑
    return _apiService.getUsers();
  }

  @override
  Future<Result<UserDTO>> getUserById(int id) async {
    return _apiService.getUserById(id);
  }
}

// ==================== 在 UI 层使用（伪代码） ====================

/// 示例：在页面中使用
///
/// ```dart
/// class UserListPage extends StatefulWidget {
///   @override
///   _UserListPageState createState() => _UserListPageState();
/// }
///
/// class _UserListPageState extends State<UserListPage> {
///   final UserRepository _repository = UserRepositoryImpl();
///   List<UserDTO> _users = [];
///   bool _isLoading = false;
///   String? _errorMessage;
///
///   @override
///   void initState() {
///     super.initState();
///     _loadUsers();
///   }
///
///   Future<void> _loadUsers() async {
///     setState(() {
///       _isLoading = true;
///       _errorMessage = null;
///     });
///
///     final result = await _repository.getUsers();
///
///     setState(() {
///       _isLoading = false;
///     });
///
///     result.onSuccess((users) {
///       setState(() {
///         _users = users;
///       });
///     }).onFailure((message, code) {
///       setState(() {
///         _errorMessage = message;
///       });
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     if (_isLoading) {
///       return AppLoading();
///     }
///
///     if (_errorMessage != null) {
///       return AppError(
///         message: _errorMessage,
///         onRetry: _loadUsers,
///       );
///     }
///
///     if (_users.isEmpty) {
///       return AppEmpty(message: '暂无用户数据');
///     }
///
///     return ListView.builder(
///       itemCount: _users.length,
///       itemBuilder: (context, index) {
///         final user = _users[index];
///         return ListTile(
///           title: Text(user.name),
///           subtitle: Text(user.email),
///         );
///       },
///     );
///   }
/// }
/// ```

// ==================== 高级用法示例 ====================

/// 示例：链式调用和错误处理
void exampleUsage() async {
  final apiService = UserApiService();

  // 1. 基本用法
  final result = await apiService.getUserById(1);

  // 使用模式匹配
  switch (result) {
    case Success<UserDTO>(data: final user):
      print('获取成功: ${user.name}');
    case Failure<UserDTO>(message: final message):
      print('获取失败: $message');
  }

  // 2. 链式调用
  await apiService
      .getUsers()
      .then((result) => result.onSuccess((users) {
            print('用户数量: ${users.length}');
          }).onFailure((message, code) {
            print('错误: $message (code: $code)');
          }));

  // 3. 数据转换
  final names = await apiService.getUsers().then((result) {
    return result.map((users) => users.map((u) => u.name).toList());
  });

  print(names.dataOrNull);

  // 4. 分页数据
  final pageResult = await apiService.getUsersPage(page: 1, pageSize: 10);

  pageResult.onSuccess((page) {
    print('当前页: ${page.page}/${page.totalPages}');
    print('是否还有更多: ${page.hasMore}');
    print('用户列表: ${page.items.map((u) => u.name).join(', ')}');
  });
}
