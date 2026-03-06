# Flutter 企业级架构文档

## 项目概述

本项目采用企业级分层架构，遵循 Flutter 官方最佳实践，实现清晰的关注点分离和高度可测试性。

## 架构分层

```
┌─────────────────────────────────────────────────────────┐
│  表现层 (Presentation)  UI、路由、状态展示、用户输入      │
├─────────────────────────────────────────────────────────┤
│  领域层 (Domain) [可选]  实体、用例、业务规则             │
├─────────────────────────────────────────────────────────┤
│  数据层 (Data)  Repository 实现、远程/本地数据源、DTO 转换 │
├─────────────────────────────────────────────────────────┤
│  核心层 (Core)  网络封装、存储封装、DI、错误类型、常量     │
└─────────────────────────────────────────────────────────┘
```

**依赖方向**: 上层依赖下层，不反向，不跨层直调。

## 目录结构

```
lib/
├── app/                    # 应用入口、路由配置、全局配置
│   └── router/             # GoRouter 路由表
├── core/                   # 核心基础设施层
│   ├── constants/          # 全局常量
│   ├── di/                 # 依赖注入配置
│   ├── error/              # 统一错误类型
│   ├── network/            # 网络封装
│   ├── storage/            # 存储封装
│   └── theme/              # 主题配置
├── data/                   # 数据层
│   ├── datasources/        # 数据源（远程/本地）
│   ├── dto/                # 数据传输对象
│   ├── mappers/            # DTO ↔ Entity 转换
│   └── repositories/       # Repository 实现
├── domain/                 # 领域层（可选）
│   ├── entities/           # 业务实体
│   └── repositories/       # Repository 接口
├── features/               # 功能模块（按 feature 划分）
│   └── feature_xxx/
│       └── presentation/   # 页面、Widget、状态管理
└── shared/                 # 公共层
    ├── utils/              # 工具类
    └── widgets/            # 通用 UI 组件
```

## 技术栈

### 核心依赖

| 类别 | 技术选型 | 版本 | 说明 |
|------|---------|------|------|
| 网络请求 | Dio | 5.4.0 | HTTP 客户端，拦截器链 |
| 本地存储 | SharedPreferences | 2.2.2 | 轻量级 KV 存储 |
| 安全存储 | FlutterSecureStorage | 9.0.0 | 敏感数据加密存储 |
| 状态管理 | Riverpod | 2.4.9 | 编译安全、可测试 |
| 路由管理 | GoRouter | 13.0.0 | 声明式路由 |
| 依赖注入 | GetIt | 7.6.4 | 服务定位器 |
| 测试工具 | Mocktail | 1.0.2 | Mock 测试库 |

### 代码规范

- **Effective Dart**: 遵循官方代码风格指南
- **Lint 规则**: 严格启用 100+ lint 规则
- **命名规范**:
  - 类名: PascalCase (例如 `UserRepository`)
  - 文件名: snake_case (例如 `user_repository.dart`)
  - 变量名: camelCase (例如 `userName`)
  - 常量名: camelCase (例如 `maxRetryCount`)

## 核心层设计

### 网络层

- 单例 Dio Client
- 拦截器链: 日志 / 认证 / 错误处理 / 重试
- 抽象接口 `IApiClient`
- 统一错误类型: `ApiException`, `NetworkException`, `TimeoutException`

### 存储层

- 抽象接口: `IKVStorage`, `ISecureStorage`
- 多实现可替换: SharedPreferences, Hive, SQLite
- 敏感数据加密存储

### 错误处理

- 统一错误类型定义
- 业务层不散落 try/catch
- UI 层统一错误展示

## 状态管理

使用 **Riverpod** 作为主要状态管理方案:

- **Provider**: 全局状态注入
- **StateNotifier**: 复杂状态逻辑
- **AsyncValue**: 异步状态管理 (loading/data/error)

## 路由管理

使用 **GoRouter** 声明式路由:

- 路由表集中配置
- 支持深链接
- 支持路由守卫
- 类型安全传参

## 测试策略

### 单元测试

- 核心业务逻辑 100% 覆盖
- Repository 层测试
- Mapper 转换测试

### Widget 测试

- UI 组件测试
- 页面交互测试

### 集成测试

- 完整业务流程测试

## 开发工作流

### 1. 添加新 Feature

```bash
# 1. 创建 feature 目录
mkdir -p lib/features/feature_xxx/presentation

# 2. 创建 domain 层 (可选)
# entities, repositories 接口

# 3. 创建 data 层
# dto, mappers, repositories 实现

# 4. 创建 presentation 层
# screens, widgets, providers
```

### 2. 添加新 API

```dart
// 1. 定义 DTO
class UserDTO {
  final int id;
  final String name;
  // ...
}

// 2. 创建 Mapper
class UserMapper {
  static User toEntity(UserDTO dto) { /* ... */ }
}

// 3. 实现 Repository
class UserRepositoryImpl implements UserRepository {
  // ...
}

// 4. 注册到 DI
getIt.registerSingleton<UserRepository>(UserRepositoryImpl());
```

### 3. 运行测试

```bash
# 单元测试
flutter test

# 测试覆盖率
flutter test --coverage

# 代码分析
flutter analyze
```

## 性能优化

- const 构造函数优先
- ListView.builder 用于长列表
- 避免不必要的 rebuild
- 图片缓存与占位

## 安全规范

- 敏感数据使用 SecureStorage
- Token 不入库，仅内存/安全存储
- HTTPS 强制
- 日志脱敏

## 待办事项

- [ ] Day 2: 网络层完整实现
- [ ] Day 3: 存储层与 DI 配置
- [ ] Day 4: 主题系统与基础组件
- [ ] Day 5: 状态管理与路由集成
- [ ] Feature 示例实现
- [ ] 测试覆盖
- [ ] CI/CD 配置

## 参考文档

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Effective Dart](https://dart.dev/effective-dart)
- [Riverpod 文档](https://riverpod.dev/)
- [GoRouter 文档](https://pub.dev/packages/go_router)
- [项目架构规范](./ai-context/flutter-architecture-requirements.md)
