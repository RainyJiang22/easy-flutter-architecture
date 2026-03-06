/// 分页结果模型
class PageResult<T> {
  /// 数据列表
  final List<T> items;

  /// 总数
  final int total;

  /// 当前页码（从 1 开始）
  final int page;

  /// 每页数量
  final int pageSize;

  /// 是否有下一页
  final bool hasMore;

  const PageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// 是否为空
  bool get isEmpty => items.isEmpty;

  /// 是否非空
  bool get isNotEmpty => items.isNotEmpty;

  /// 总页数
  int get totalPages => (total / pageSize).ceil();

  /// 从 JSON 创建（适用于常见分页 API 响应格式）
  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT, {
    String itemsKey = 'items',
    String totalKey = 'total',
    String pageKey = 'page',
    String pageSizeKey = 'pageSize',
  }) {
    final items = (json[itemsKey] as List)
        .map((item) => fromJsonT(item))
        .toList();

    final total = json[totalKey] as int? ?? items.length;
    final page = json[pageKey] as int? ?? 1;
    final pageSize = json[pageSizeKey] as int? ?? 20;

    return PageResult(
      items: items,
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: page * pageSize < total,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson(
    Map<String, dynamic> Function(T item) toJsonT,
  ) {
    return {
      'items': items.map(toJsonT).toList(),
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  /// 复制并修改
  PageResult<T> copyWith({
    List<T>? items,
    int? total,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PageResult(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// 映射数据类型
  PageResult<R> map<R>(R Function(T item) transform) {
    return PageResult(
      items: items.map(transform).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  @override
  String toString() {
    return 'PageResult(items: ${items.length}, total: $total, '
        'page: $page/$totalPages, pageSize: $pageSize, hasMore: $hasMore)';
  }
}
