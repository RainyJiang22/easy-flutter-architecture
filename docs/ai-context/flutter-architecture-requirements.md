# Flutter 通用项目架构 — 标准需求提示词

基于中大厂实践与 Flutter 官方最新建议，用于指导「通用项目架构」设计与实现。可作为需求文档或给 AI/团队的提示词使用。

---

## 一、总体原则

1. **分层清晰**：UI / 业务逻辑 / 数据（远程+本地）/ 基础设施 分层，依赖单向（上层依赖下层，不反向）。
2. **可测试**：核心逻辑可单测；网络、存储、系统能力通过接口抽象，便于 Mock。
3. **可扩展**：新功能以模块/Feature 形式接入，公共能力沉淀到 core/common，避免复制粘贴。
4. **遵循官方**：架构与状态管理参考 [Flutter 官方文档](https://docs.flutter.dev/) 与 [Effective Dart](https://dart.dev/effective-dart)；优先使用官方推荐方案（如 Material 3、Sliver、声明式 UI）。
5. **第三方库**：允许使用成熟第三方库，但需统一封装、版本收敛、有替换/降级方案；禁止在 UI 层直接裸调第三方 API。

---

## 二、合理分层与各层最优方案

依赖方向：**表现层 → 领域层 → 数据层 → 核心/基础设施层**（上层仅依赖下层，不反向、不跨层直调）。

```
┌─────────────────────────────────────────────────────────┐
│  表现层 (Presentation)                                   │
│  UI、路由、状态展示、用户输入                             │
├─────────────────────────────────────────────────────────┤
│  领域层 (Domain) [可选，中大型项目建议]                   │
│  实体、用例、业务规则                                     │
├─────────────────────────────────────────────────────────┤
│  数据层 (Data)                                           │
│  Repository 实现、远程/本地数据源、DTO↔Entity 转换         │
├─────────────────────────────────────────────────────────┤
│  核心/基础设施层 (Core)                                  │
│  网络封装、本地存储封装、DI、错误类型、常量与工具           │
└─────────────────────────────────────────────────────────┘
```

### 2.1 表现层 (Presentation)

**职责**：UI 渲染、用户交互、路由与导航、将状态展示为界面；不直接调网络/DB，不写业务规则。

**最新最优方案**：

| 方面 | 推荐方案 | 说明 |
|------|----------|------|
| UI 框架 | Flutter 3.x + Material 3 | 使用 Material 3 组件与主题；复杂列表用 Sliver、CustomScrollView；声明式构建 Widget 树。 |
| 状态管理 | **Riverpod 2.x** 或 **Bloc 8.x** | Riverpod：编译安全、可测试、与 Flutter 官方示例一致；Bloc：事件-状态流清晰、适合复杂交互。二选一，全项目统一。 |
| 路由 | **GoRouter 2.x**（声明式） | 声明式路由、深链、redirect、ShellRoute 嵌套；路由表集中、类型安全。 |
| 异步与加载 | AsyncValue / Loading↔Data↔Error | 统一用 AsyncValue（Riverpod）或 Bloc 的 Loading/Loaded/Error 状态，UI 只做分支展示，不散落 try/catch。 |
| 依赖获取 | 通过 DI 或 Provider 注入 | 在表现层只拿 Repository/UseCase 接口，不拿 Dio、不拿具体 DataSource。 |

**禁止**：在 Widget/Controller 内直接 `Dio().get()`、直接读 Hive/SQLite；在 build 里发起请求或重计算。

---

### 2.2 领域层 (Domain) [可选]

**职责**：实体（Entity）定义、业务规则、用例（UseCase）编排；纯 Dart，不依赖 Flutter、不依赖具体数据源。

**最新最优方案**：

| 方面 | 推荐方案 | 说明 |
|------|----------|------|
| 实体 | 纯 Dart 类，无注解 | 仅业务字段与简单校验；与 DTO/表结构解耦，便于多端复用与单测。 |
| 用例 | 单职责 UseCase 类 | 一个用例一个类，内部只调 Repository 接口；便于单测与复用。 |
| 错误与结果 | Result / Either 或 sealed class | 用 `Result<T, E>` 或 `Either<Failure, T>` 表达成功/失败，避免到处 throw；与表现层约定统一错误模型。 |

**何时采用**：中大型项目、多端共享业务逻辑、需要强可测试性时引入；小型项目可将「用例」合并到 Repository 或 ViewModel。

---

### 2.3 数据层 (Data)

**职责**：实现 Repository 接口；调用远程 API 与本地存储；做 DTO↔Entity 转换、分页与错误映射。

**最新最优方案**：

| 方面 | 推荐方案 | 说明 |
|------|----------|------|
| 抽象 | Repository 接口在领域层或数据层定义 | 表现层/领域层依赖 `XxxRepository` 接口；数据层提供 `XxxRepositoryImpl`。 |
| 远程 | 调用 Core 层封装的 ApiClient / XxxApi | 不直接 new Dio；用 Dio+Retrofit 风格的类型安全 API；超时、重试、Token 在 Core 层统一处理。 |
| 本地 | 调用 Core 层封装的 IKVStorage / 本地 DB 抽象 | 缓存、持久化通过接口；具体实现（Hive/Isar/SQLite）在 Core 层可替换。 |
| 转换 | DTO → Entity 在 Repository 内完成 | API 返回 DTO，Repository 转成 Entity 或领域模型再返回；列表/分页统一封装（如 `PageResult<T>`）。 |
| 流式/响应式 | Stream 或 Future | 需要持续同步时用 Stream；一次性请求用 Future；错误通过 Result/Exception 统一向上传递。 |

**禁止**：在 Repository 里写 UI 逻辑、弹 Toast、依赖 BuildContext。

---

### 2.4 核心/基础设施层 (Core)

**职责**：网络 Client 封装、本地存储封装、DI 注册、全局错误类型与常量、通用工具。

**最新最优方案**：

| 方面 | 推荐方案 | 说明 |
|------|----------|------|
| 网络 | Dio + 单例 Client + 拦截器链 + Retrofit 风格 API | 见下文「四、网络层」；对外暴露 `IApiClient` / `XxxApi`，业务只依赖接口。 |
| 本地存储 | 抽象接口 + 实现（shared_preferences / Hive / Isar / secure_storage） | 见下文「五、本地存储」；敏感数据用 flutter_secure_storage。 |
| 依赖注入 | **Riverpod**（与状态管理统一）或 **get_it + injectable** | 在 App 启动时注册 ApiClient、Repository、Storage；表现层通过 Provider 或 GetIt 获取，不 new 具体实现。 |
| 错误类型 | 统一 ApiException / AppException | 在 Core 定义，网络/存储层抛出，表现层只消费统一错误模型与文案。 |
| 常量与配置 | 单文件或按环境注入 | BaseUrl、超时、Feature 开关等从配置或环境读取，不散落魔法值。 |

**禁止**：Core 层依赖表现层或领域层；不在 Core 写业务分支逻辑。

---

### 2.5 目录与分层对应（推荐）

```
lib/
├── app/                    # 入口、路由表、DI 注册、主题
├── core/                    # 基础设施：network、storage、di、error、constants
├── domain/                  # [可选] 实体、用例、Repository 接口
├── data/                    # Repository 实现、DataSource、DTO、Mapper
├── features/                # 按功能划分的表现层
│   ├── feature_a/
│   │   ├── presentation/    # 页面、Widget、状态（Riverpod/Bloc）
│   │   └── (domain/data 若未全局拆分则可放 feature 内)
│   └── feature_b/
└── shared/                  # 跨 feature 的公共 UI 组件、工具、常量
```

各层采用上述最新最优方案；网络、存储、状态管理、路由的细节见下文各章。

---

## 三、UI 界面规范（生产可用）

本架构下的 UI 层按本节规范实现，可直接用于生产项目：主题与设计体系统一、状态与异常态完整、性能与无障碍达标、目录与组件可复用。

### 3.1 主题与设计体系

| 项 | 生产可用方案 | 说明 |
|----|--------------|------|
| 组件库与主题 | **Material 3**（ThemeData.useMaterial3） | 使用 M3 组件与 ColorScheme、Typography；与 Flutter 官方一致，后续升级友好。 |
| 颜色 | ColorScheme + 语义 Token | 主色/次要色/表面/错误等从 Theme.of(context).colorScheme 取；业务色（如状态色）定义为扩展或常量，不硬编码 hex。 |
| 字体与排版 | TextTheme + 可选 fontFamily | 使用 theme.textTheme 的 titleMedium、bodyLarge 等；需要品牌字体时在 ThemeData 统一配置。 |
| 间距与圆角 | 统一常量（如 4/8/12/16/24） | 在 core/theme 或 shared/constants 定义 spacing、radius 常量；组件内用常量，禁止魔法数字。 |
| 亮/暗色 | ThemeData.light() / dark() + 系统跟随 | 支持亮暗切换；可从系统或应用设置读取，在 app 层注入 ThemeMode。 |

**目录建议**：`app/theme/` 或 `shared/theme/` 下集中 `app_theme.dart`、`app_colors.dart`、`app_text_styles.dart`（若需扩展）。

### 3.2 页面与组件结构

| 项 | 生产可用方案 | 说明 |
|----|--------------|------|
| 页面组成 | 一个 Screen = Scaffold + 状态驱动 Body | 页面级 Widget 只负责布局与调用 Provider/Bloc；不在此写业务请求，由状态层在 init/load 时拉数。 |
| 状态驱动 | AsyncValue / Loading↔Data↔Error | 列表页：loading 用统一 Loading 组件、data 用内容、error 用统一 Error 组件+重试；与「六、状态管理」一致。 |
| 可复用组件 | 放 `shared/widgets/` 或 feature 内 `widgets/` | 按钮、输入框、卡片、列表项等可复用 UI 抽成无状态 Widget，通过参数配置；带业务含义的放 feature。 |
| 弹窗与底部 sheet | 统一封装 showDialog / showModalBottomSheet | 样式与圆角从主题取；复杂内容抽成独立 Widget，便于单测与复用。 |

**禁止**：在 Page 的 build 里直接发起 Future、在 Widget 内写死颜色/尺寸（除明确仅此处使用的）。

### 3.3 加载 / 空态 / 错误态（必做）

| 态 | 生产可用方案 | 说明 |
|----|--------------|------|
| Loading | 全屏或局部骨架/菊花 | 首屏用统一 AppLoading 或骨架屏；列表下拉刷新用 RefreshIndicator + 列表内 loading 占位。 |
| 空态 | 统一 Empty 组件（插画+文案+操作） | 无数据时展示「暂无内容」类 Empty，带主操作（如去添加）；文案走国际化。 |
| 错误态 | 统一 Error 组件（文案+重试） | 网络/业务错误展示统一 Error 视图，带重试按钮；错误文案从统一错误模型或 l10n 取。 |
| 部分失败 | 列表内 item 错误占位或 Toast | 列表单条失败不整页报错；可单条重试或 Toast 提示，与产品约定一致。 |

以上组件放在 `shared/widgets/`（如 `app_loading.dart`、`app_empty.dart`、`app_error.dart`），全项目统一使用，保证生产环境体验一致。

### 3.4 响应式与多端适配

| 项 | 生产可用方案 | 说明 |
|----|--------------|------|
| 断点 | 基于 LayoutBuilder 或 MediaQuery | 定义 breakpoint（如 600/900）；窄屏单列、宽屏多列或侧栏，用条件布局。 |
| 安全区 | SafeArea + 必要时 Padding | 刘海、底部横条由 SafeArea 处理；固定底部按钮时考虑安全区与键盘。 |
| 横竖屏 | 可选 OrientationBuilder | 若需横竖屏差异，用 OrientationBuilder 或断点+宽高比判断，不写死尺寸。 |
| 多端 | 同一套布局或 Platform 分支 | 手机/平板/桌面可共用一套响应式布局，或按 Platform 提供少量差异化 Widget。 |

生产项目至少保证手机竖屏与安全区正确；若支持平板/桌面，在 theme 或 layout 中明确断点与规则。

### 3.5 无障碍与体验

| 项 | 生产可用方案 | 说明 |
|----|--------------|------|
| 语义 | Semantics / semanticsLabel | 图标按钮、图片、自定义控件补充 semanticsLabel；重要状态用 Semantics 暴露给读屏。 |
| 点击区域 | 最小 48×48 dp（Material 规范） | 可点击区域不足时用 InkWell 外包或 minTouchTargetSize；避免过小难以点击。 |
| 字体缩放 | 支持系统字体缩放 | 文案用 Text 的 style 继承或 theme；不写死 fontSize 时默认支持系统缩放。 |
| 对比度 | 满足 WCAG AA（可选检查） | 主文案与背景对比度达标；重要按钮与背景区分明显。 |

### 3.6 性能与规范

| 项 | 生产可用方案 | 说明 |
|----|--------------|------|
| const | 尽可能 const 构造函数 | 无状态的静态子树用 const，减少 rebuild 开销。 |
| 列表 | 长列表用 ListView.builder / SliverList | 禁止对长列表用 ListView(children: List.generate(...))；图片列表考虑预加载与占位。 |
| Key | 动态列表项设置 Key（如 item.id） | 增删改时保持正确复用与动画；避免不必要的整列表重建。 |
| build 内 | 不发起请求、不重计算、不 new 大对象 | 仅做「根据状态返回 Widget」；异步与计算放在状态层或 initState/未来帧。 |

### 3.7 UI 层目录与分层对应

```
features/
└── feature_xxx/
    └── presentation/
        ├── screens/           # 页面级，对应路由
        │   └── xxx_screen.dart
        ├── widgets/           # feature 内复用组件
        │   ├── xxx_card.dart
        │   └── xxx_list_item.dart
        └── (providers/ 或 blocs/ 按状态管理方案)

shared/
├── theme/                     # 主题、颜色、字体、间距常量
├── widgets/                   # 全局复用：AppLoading、AppEmpty、AppError、通用按钮/输入框等
└── ...
```

页面只依赖状态层（Provider/Bloc）与 shared/widgets、shared/theme；不直接依赖 data/core。按上述规范实现的 UI 层可与「二、合理分层」无缝衔接，直接用于生产。

---

## 四、网络层

**选型原则**：允许并推荐使用成熟第三方库（如 **Dio**、**dio_retrofit**、**chopper** 等），由统一封装层对外暴露接口，业务只依赖封装层，便于替换与测试。单例 HttpClient、拦截器链、强类型 API 层为最优解。

### 4.1 统一封装与入口

1. **单例 Client**：全项目使用一个网络 Client 实例（或按域拆分少数几个），基于 Dio/HttpClient 等第三方库实现；禁止在 Page/Widget/Controller 内直接 `dio.get()` 裸调，业务只调用封装后的 `ApiClient` 或 `XxxRepository`。
2. **抽象接口**：对外暴露 `IApiClient` 或按业务划分的 `XxxApi` 接口，内部实现可替换（今日 Dio，明日可换为其它库），业务与具体 HTTP 库解耦。
3. **强类型 API 层**：请求/响应使用 Model/DTO；列表、分页统一封装（如 `PageResult<T>`）；推荐用 **Retrofit 风格**（dio_retrofit/chopper）生成类型安全接口，减少手写与错误。

### 4.2 高可用（High Availability）

4. **超时与重试**：连接/读/写超时分开配置（如 connect 5s、read 15s）；重试策略可配置：次数（如 2～3 次）、仅对幂等或指定方法重试、退避（指数退避或固定间隔），避免雪崩与无限重试。
5. **熔断与降级（可选）**：对不稳定或第三方接口，可引入熔断思路（连续失败 N 次后短时不再请求，或走缓存/默认数据）；超时或 5xx 时返回友好错误或本地缓存，不直接抛给 UI。
6. **取消与防抖**：支持请求取消（CancelToken）；列表/搜索等场景防抖或节流，避免重复请求与竞态；页面销毁时取消未完成请求，避免泄漏与无效回调。
7. **连接复用**：使用 Keep-Alive、连接池（Dio 等已支持）；同一 BaseUrl 复用连接，减少建连开销，提升弱网与高并发下的可用性。
8. **缓存与离线**：对可缓存的 GET 或配置类接口，可做短期内存/磁盘缓存（如 cache_interceptor、自定义拦截器）；网络不可用时返回缓存或明确「离线」状态，保证基本可用。

### 4.3 配置、安全与可观测

9. **配置集中**：BaseUrl、超时、重试参数、公共 Header、证书校验在单处配置；支持多环境（dev/staging/prod）切换；敏感配置不写死。
10. **安全**：全站 HTTPS；敏感信息不入日志（含 URL 参数、Body）；Token 刷新与 401 在拦截器或统一层处理，业务无感；证书 Pinning 按需启用。
11. **错误统一**：定义统一业务错误类型（如 `ApiException`、`NetworkException`、`TimeoutException`）；服务端错误码/文案在拦截器或 Mapper 层转换，UI 只消费统一错误模型。
12. **可观测**：关键请求可打点（URL 模板、耗时、状态码、是否重试）；日志通过开关控制详细程度，生产环境脱敏；便于排查与监控。

### 4.4 推荐依赖与用法（可选参考）

- **Dio**：拦截器、CancelToken、超时、重试、FormData、适配器扩展成熟；可作为底层 Client。
- **dio_retrofit / chopper**：声明式 API、强类型、代码生成，减少手写样板。
- **dio_smart_retry** 或自定义拦截器：实现带退避的重试与「仅幂等重试」策略。
- 业务层只依赖 `IApiClient` / `XxxApi` 接口与 DTO，不直接依赖 `dio` 包类型，便于单测 Mock 与未来替换。

---

## 五、本地存储

1. **抽象接口**：定义统一的「键值/持久化」抽象（如 IKVStorage、IPersistentStorage），业务只依赖接口；具体实现可为 shared_preferences、Hive、Isar、SQLite 等，可替换。
2. **分层使用**：简单配置/开关用 KV；结构化、可查询用本地 DB；大对象或敏感数据考虑加密与压缩策略。
3. **生命周期**：存储实例在 App 生命周期内单例或按模块注入；异步初始化（如 Hive.init）在 App 启动流程中完成，不阻塞首帧。
4. **迁移与版本**：Schema 变更时提供迁移方案（版本号 + 迁移脚本）；避免破坏性变更导致旧数据不可读。
5. **安全**：敏感数据（Token、密码）使用 flutter_secure_storage 或等价方案；不把敏感信息写进普通 KV 或未加密 DB。

---

## 六、动画

1. **优先官方 API**：优先使用 Flutter 内置 AnimationController、Tween、Curve、ImplicitlyAnimatedWidget、Lottie（若用第三方需统一封装）；避免重复造轮子。
2. **性能**：动画在 60fps 下流畅；避免在动画回调里做重计算或同步 I/O；列表内动画考虑列表懒加载与复用。
3. **可配置**：时长、曲线、延迟等通过常量或主题配置，避免魔法值；支持「减少动效」等无障碍/系统设置。
4. **与状态解耦**：动画状态与业务状态分离；业务逻辑不依赖动画帧数或具体实现细节，便于替换与测试。

---

## 七、状态管理（归属表现层，与二、2.1 一致）

1. **方案统一**：全项目选定一种主方案（如 Provider、Riverpod、Bloc、GetX、flutter_riverpod 等），与 Flutter 官方推荐对齐；同一模块内不混用多种响应式写法。
2. **作用域清晰**：状态与页面/模块/全局作用域对应；避免全局单例持有过大状态；列表/分页等大状态考虑懒加载与释放。
3. **依赖注入**：通过 DI 或 GetIt/Riverpod 等显式注入，避免在 Widget 树深处 `Get.find()` 或全局单例散落；便于测试与替换实现。
4. **异步与副作用**：异步逻辑集中处理（如 async notifier、Cubit）；错误与加载状态有统一表示（Loading/Data/Error），不在 UI 里散落 try/catch。

---

## 八、路由与导航（归属表现层，与二、2.1 一致）

1. **声明式路由**：优先使用 GoRouter 或 Navigator 2.0 声明式路由；路由表集中配置，支持深链、参数、守卫。
2. **命名与参数**：路由名、参数 key 使用常量或枚举，禁止魔法字符串；传参类型明确，避免强转。
3. **与状态解耦**：路由不直接依赖全局单例状态；通过路由参数或 DI 获取所需数据，便于测试与复现。

---

## 九、工程与规范

1. **目录结构**：与「二、合理分层」一致，`lib/` 下按 app / core / domain（可选）/ data / features / shared 划分；core 放网络、存储、DI、错误类型；features 内按功能分子目录，每层职责清晰。
2. **命名**：遵循 Effective Dart；类/文件/变量命名一致；公共 API 有清晰命名，避免缩写歧义。
3. **分析选项**：配置 `analysis_options.yaml`，启用推荐 lint；CI 中跑 `dart analyze` 与测试，不合并未通过变更。
4. **依赖管理**：`pubspec.yaml` 中版本收敛；第三方库有明确选型理由与文档链接；大版本升级有兼容性评估与回归计划。
5. **资源与国际化**：图片/字体等资源按模块或类型归类；文案走国际化方案（如 l10n、ARB），禁止硬编码用户可见文案。

---

## 十、第三方库使用原则

1. **选型**：优先 pub.dev 评分高、维护活跃、与 Flutter/Dart 版本兼容的库；避免冷门或已弃维护的库。
2. **封装**：对外暴露统一接口，内部实现可替换；业务层不直接依赖第三方类型（如 Dio 的 Response），避免库升级时改动面过大。
3. **版本**：主库版本在 pubspec 中固定或范围可控；子依赖冲突时优先升级或替换，避免 override 滥用。
4. **文档与注释**：引入新库时在 README 或架构文档中说明用途、封装位置、替换策略；复杂用法加注释或示例。

---

## 十一、可交付物（架构落地时建议产出）

1. **架构图**：分层图 + 模块/依赖关系图（可 Mermaid 或图示）。
2. **目录与模块说明**：各目录职责、核心类与接口列表。
3. **UI 与主题**：主题配置（Material 3）、AppLoading/AppEmpty/AppError 等通用组件；与「三、UI 界面规范」一致。
4. **网络/存储/路由示例**：各层 1～2 个完整调用链示例（从 UI 到 API/DB）。
5. **状态管理约定**：选型说明 + 创建/注入/释放的约定。
6. **README 或 CONTRIBUTING**：新人接入步骤、规范链接、常用命令（分析、测试、运行）。

---

## 十二、提示词用法示例

将上述条款作为「需求提示词」使用时，可这样表述：

- 「请按本文档『二、合理分层』、『三、UI 界面规范』与『四、网络层』、『五、本地存储』的要求，设计并实现分层架构与 UI/网络/存储层，要求生产可用、统一入口、可测试、可替换实现。」
- 「在现有项目上，按本文档『一～十一』做一轮架构合规检查，输出不符合项与改造建议，按优先级排序。」
- 「基于本文档『二、合理分层』与『三、UI 界面规范』生成一份 Flutter 通用架构的 Mermaid 架构图与目录结构示例（含表现层与 UI 规范、数据层、核心层与网络、存储、动画、状态管理）。」

---

*文档版本：1.2 | 可随 Flutter 官方与团队实践迭代更新。*
