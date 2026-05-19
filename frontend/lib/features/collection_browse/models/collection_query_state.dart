enum SortOption {
  /// UI: Newest — API `date_desc` (acquired date, matches prior Date ↓ behavior)
  newest('date_desc'),
  /// UI: Oldest — API `date_asc` (acquired date, matches prior Date ↑ behavior)
  oldest('date_asc');

  const SortOption(this.apiValue);
  final String apiValue;
}

class CollectionQueryState {
  const CollectionQueryState({
    this.keyword = '',
    this.category,
    this.tag,
    this.visibility,
    this.sortBy = SortOption.newest,
    this.page = 1,
    this.pageSize = 12,
  });

  final String keyword;
  final String? category;
  final String? tag;
  /// 对应 backend SQLite `collections.visibility`（经 GET /api/collections 筛选）
  final String? visibility;
  final SortOption sortBy;
  final int page;
  final int pageSize;

  /// pageSize=6：Collection wall 每页 6 张卡片
  static const initial = CollectionQueryState(pageSize: 6);

  CollectionQueryState copyWith({
    String? keyword,
    String? category,
    bool clearCategory = false,
    String? tag,
    bool clearTag = false,
    String? visibility,
    bool clearVisibility = false,
    SortOption? sortBy,
    int? page,
    int? pageSize,
  }) {
    return CollectionQueryState(
      keyword: keyword ?? this.keyword,
      category: clearCategory ? null : (category ?? this.category),
      tag: clearTag ? null : (tag ?? this.tag),
      visibility: clearVisibility ? null : (visibility ?? this.visibility),
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      if (category != null && category!.isNotEmpty) 'category': category,
      if (tag != null && tag!.isNotEmpty) 'tag': tag,
      if (visibility != null && visibility!.isNotEmpty) 'visibility': visibility,
      'sort': sortBy.apiValue,
    };
  }
}
