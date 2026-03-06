# Flutter通用架构

基于实际项目实践与 Flutter 官方建议的**分层架构**：表现层 → 领域层（可选）→ 数据层 → 核心层，配合
Material 3、Riverpod/Bloc、GoRouter、Dio 等最新方案，结合ai工作流生成一套可直接用于生产项目的通用架构。

---

## 架构概览

```
┌─────────────────────────────────────────────────────────┐
│  表现层 (Presentation)                                   │
│  UI · 路由 · 状态展示 · 用户输入                          │
│  Material 3 · Riverpod/Bloc · GoRouter                   │
├─────────────────────────────────────────────────────────┤
│  领域层 (Domain) [可选]                                  │
│  实体 · 用例 · 业务规则 · Result/Either                  │
├─────────────────────────────────────────────────────────┤
│  数据层 (Data)                                           │
│  Repository 实现 · 远程/本地数据源 · DTO↔Entity 转换     │
├─────────────────────────────────────────────────────────┤
│  核心层 (Core)                                           │
│  网络封装 · 存储封装 · DI · 错误类型 · 常量              │
│  Dio · Hive/Isar/secure_storage · Riverpod/get_it        │
└─────────────────────────────────────────────────────────┘
```

**依赖方向**：上层仅依赖下层，不反向、不跨层直调；业务不直接依赖 Dio/Hive，依赖接口与 DTO/Entity。

---

## 技术栈与选型

| 层级      | 推荐方案                                                                 |
|---------|----------------------------------------------------------------------|
| UI / 主题 | Flutter 3.x · Material 3 · Sliver/CustomScrollView                   |
| 状态管理    | **Riverpod 2.x** 或 **Bloc 8.x**（二选一，全项目统一）                           |
| 路由      | **GoRouter 2.x**（声明式、深链、ShellRoute）                                  |
| 网络      | **Dio** + 单例 Client + 拦截器链；可选 dio_retrofit/chopper 强类型 API           |
| 本地存储    | 抽象接口 + shared_preferences / Hive / Isar；敏感数据用 flutter_secure_storage |
| 依赖注入    | Riverpod 或 get_it + injectable                                       |

---

## 项目结构

```
lib/
├── app/              # 入口、路由表、DI 注册、主题
├── core/             # 网络、存储、DI、错误类型、常量
├── domain/           # [可选] 实体、用例、Repository 接口
├── data/             # Repository 实现、DataSource、DTO、Mapper
├── features/         # 按功能划分
│   └── feature_xxx/
│       └── presentation/   # screens/、widgets/、providers 或 blocs
└── shared/           # 跨 feature 的 UI 组件、主题、工具、常量
```

---

## 核心原则

- **可测试**：核心逻辑可单测；网络/存储通过接口抽象，便于 Mock。
- **可扩展**：新功能以 feature 接入，公共能力沉淀到 core/shared。
- **生产可用**：统一 Loading/Empty/Error、主题与无障碍；网络超时/重试/错误统一；UI 不裸调 Dio/DB。

详细规范见 *
*[docs/ai-context/flutter-architecture-requirements.md](docs/ai-context/flutter-architecture-requirements.md)
**（分层、UI、网络、存储、状态与路由、工程与可交付物）。

---

## 快速开始

```bash
# 依赖
flutter pub get

# 分析
dart analyze

# 运行
flutter run
```

---