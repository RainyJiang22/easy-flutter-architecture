/// 路由名称常量
///
/// 用于 GoRouter 的 name 参数，便于路由导航和追踪
abstract class RouteNames {
  RouteNames._();

  /// 首页 - 用户列表
  static const home = 'home';

  /// 用户详情
  static const userDetail = 'user-detail';
}

/// 路由路径常量
///
/// 用于 GoRouter 的 path 参数和页面导航
abstract class RoutePaths {
  RoutePaths._();

  /// 首页 - 用户列表
  static const home = '/';

  /// 用户详情（带参数）
  static const userDetail = '/users/:id';

  /// 生成用户详情路径
  ///
  /// [id] 用户ID
  /// 返回完整的路由路径，如 `/users/123`
  static String userDetailPath(int id) => '/users/$id';
}

/// 路由参数 Key
///
/// 用于从 GoRouterState 中获取路径参数
abstract class RouteParams {
  RouteParams._();

  /// 用户ID
  static const userId = 'id';
}
