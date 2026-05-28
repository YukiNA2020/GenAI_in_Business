# 给未来 AI 的 Prompt

> 本文件是成员 C / 成员 3 的实际开发任务文档。请先阅读 `README.md`、`Project_intro.md`、`Status.md`、`Prompt_library.md` 和 `Final_Team_Work_Division.md`，再按本文档执行。
>
> 成员 C / 成员 3 负责收藏墙、收藏详情页、搜索筛选、分页刷新和浏览体验。不要随意修改成员 A、B、D、E 或成员 6 的职责文件和模块；如必须改共享接口、字段或页面约定，请同步记录到 `Status.md`。
>
> 每次完成开发、修复或文档更新后，请在 `Status.md` 和 `Prompt_library.md` 中标明“负责人：成员 C / 成员 3”。`past_doc/` 中的旧版本规划仅供参考，不作为当前任务依据。

---

# 成员 3 开发任务详细文档 - 收藏墙、浏览与搜索

> 对应最终分工：成员 3｜收藏墙、浏览与搜索  
> 角色类型：全栈 - 展示层  
> 建议 DDL：18-21 号  
> 主要依赖方：成员 1、成员 4、成员 5

---

## 一、角色目标

成员 3 负责用户打开 App 后最主要的浏览体验，包括收藏卡片墙、收藏详情页、搜索筛选、分页刷新和个人主页中的收藏展示。

一句话概括：

> 成员 3 要让用户能够美观、快速、稳定地浏览自己的收藏，并通过搜索和筛选找到想看的内容。

---

## 二、总体负责范围

成员 3 负责：

1. 收藏卡片墙。
2. 收藏卡片组件。
3. 收藏详情页。
4. 搜索框。
5. 分类筛选。
6. 标签筛选。
7. 下拉刷新。
8. 分页加载。
9. 空状态和加载状态。
10. 个人主页中的收藏展示区域。

成员 3 不主要负责：

1. 创建收藏表单。
2. AI Prompt 和 AI 接口。
3. 数据库 schema。
4. 高保真 UI 原稿。
5. PPT 和视频。

---

## 三、技术路线总览

| 层级 | 技术方案 | 说明 |
|------|----------|------|
| 前端框架 | Flutter | App 展示层实现 |
| 布局 | flutter_staggered_grid_view / GridView | 收藏墙布局 |
| 图片缓存 | cached_network_image | 提升图片加载体验 |
| 状态管理 | Riverpod / Provider | 管理列表、分页、筛选状态 |
| 搜索 | debounce 300-500ms | 避免频繁请求 |
| 网络请求 | dio / http | 调用成员 1 的列表和详情接口 |
| 动效 | flutter_animate / AnimatedSwitcher | 页面过渡和加载反馈 |

推荐目录：

```text
frontend/lib/features/collection_browse/
├── pages/
│   ├── collection_wall_page.dart
│   └── collection_detail_page.dart
├── widgets/
│   ├── collection_card.dart
│   ├── collection_grid.dart
│   ├── collection_search_bar.dart
│   ├── category_filter_tabs.dart
│   ├── tag_filter_sheet.dart
│   ├── loading_skeleton.dart
│   └── empty_collection_state.dart
├── providers/
│   └── collection_list_provider.dart
├── models/
│   ├── collection_item.dart
│   └── collection_query_state.dart
└── services/
    └── collection_query_service.dart
```

---

## 四、阶段一：V1.1 收藏墙基础页面和卡片组件

### 阶段目标

先把收藏内容以卡片墙形式展示出来，能够加载成员 1 提供的 Mock 数据或列表接口数据。

### 任务 1：开发收藏数据模型

模型建议：

```dart
class CollectionItem {
  final int id;
  final String title;
  final String? category;
  final String? dateAcquired;
  final String? location;
  final String? story;
  final String? imageUrl;
  final List<String> tags;
}
```

实现重点：

1. 兼容后端返回字段。
2. `tags` 为空时显示空数组。
3. 图片为空时使用占位图。

### 任务 2：开发收藏卡片组件

组件名称：

```text
CollectionCard
```

卡片内容：

1. 图片。
2. 标题。
3. 分类。
4. 标签。
5. 地点。
6. 日期。

视觉要求：

1. 严格参考成员 4 的卡片规范。
2. 图片是主视觉。
3. 标签使用胶囊样式。
4. 卡片高度可以随图片和文字变化。

### 任务 3：开发收藏墙页面

页面名称：

```text
CollectionWallPage
```

页面结构：

```text
顶部标题
  -> 搜索区域
  -> 分类筛选
  -> 收藏卡片 Grid
  -> 加载更多状态
```

实现重点：

1. 首屏展示 seed 数据。
2. 支持从 API 拉取列表。
3. 加载中显示 skeleton。
4. 请求失败显示错误状态。

### 任务 4：实现图片加载和占位状态

需要覆盖：

1. 图片 URL 正常。
2. 图片 URL 为空。
3. 图片加载失败。
4. 图片加载中。

技术方案：

```text
cached_network_image
```

### 任务 5：点击卡片进入详情页

实现重点：

1. 点击卡片跳转。
2. 跳转时传递 `collectionId`。
3. 详情页根据 id 拉取完整数据。

### 阶段一验收标准

1. 收藏墙可以显示多条收藏。
2. 卡片样式和成员 4 的设计一致。
3. 图片加载体验稳定。
4. 点击卡片可以进入详情页。

---

## 五、阶段二：V1.2 收藏详情页

### 阶段目标

完成单个收藏的完整展示页面，让用户可以查看图片、故事和所有结构化信息。

### 任务 1：开发详情页基础结构

页面名称：

```text
CollectionDetailPage
```

展示内容：

1. 大图。
2. 标题。
3. 分类。
4. 日期。
5. 地点。
6. 标签。
7. 故事。
8. 编辑入口。
9. 删除入口。

### 任务 2：接入详情接口

接口：

```text
GET /api/collections/:id
```

实现重点：

1. 页面进入后请求数据。
2. 加载中显示 skeleton。
3. 查询不到显示 not found。
4. 网络错误显示重试按钮。

### 任务 3：设计故事展示区域

展示要求：

1. 文本可换行。
2. 长故事不要溢出。
3. 保留足够阅读间距。
4. 视觉上像收藏档案，不像普通表格。

### 任务 4：实现编辑和删除入口

编辑：

```text
跳转 EditCollectionPage
```

删除：

```text
点击删除
  -> 显示确认弹窗
  -> 调用 DELETE /api/collections/:id
  -> 删除成功返回收藏墙
```

### 任务 5：展示动态字段

如果数据中有 `customFields`，详情页需要展示。

展示方式：

1. 以信息组展示。
2. 字段名使用成员 1 / 2 提供的 label。
3. 空字段不展示。

### 阶段二验收标准

1. 收藏详情页数据完整。
2. 图片、故事、标签和地点日期显示清楚。
3. 删除需要二次确认。
4. 动态字段可以被展示。

---

## 六、阶段三：V1.3 搜索、筛选、分页和刷新

### 阶段目标

让用户可以从大量收藏中快速找到目标收藏。

### 任务 1：实现查询状态模型

模型建议：

```dart
class CollectionQueryState {
  final String keyword;
  final String? category;
  final List<String> tags;
  final String sortBy;
  final int page;
  final int pageSize;
}
```

### 任务 2：开发搜索框

组件名称：

```text
CollectionSearchBar
```

实现要求：

1. 输入关键词。
2. 300-500ms debounce。
3. 清空按钮。
4. 搜索中显示状态。

调用接口：

```text
GET /api/collections?keyword=xxx
```

### 任务 3：开发分类筛选

组件名称：

```text
CategoryFilterTabs
```

实现要求：

1. 默认“全部”。
2. 点击类别刷新列表。
3. 当前类别高亮。
4. 类别数据后续可从 `GET /api/categories` 获取。

### 任务 4：开发标签筛选

组件名称：

```text
TagFilterSheet
```

实现要求：

1. 可以打开标签筛选面板。
2. 支持单选或多选标签。
3. 支持清空筛选。
4. 筛选条件变化后刷新列表。

### 任务 5：实现分页加载

实现方式：

1. 首次请求 page=1。
2. 滚动到底部请求下一页。
3. 拼接列表数据。
4. 没有更多时显示结束状态。
5. 请求中避免重复加载。

### 任务 6：实现下拉刷新

实现要求：

1. 下拉后重新请求第一页。
2. 清除旧错误状态。
3. 保留当前搜索和筛选条件。

### 阶段三验收标准

1. 搜索可以返回正确结果。
2. 分类和标签筛选可用。
3. 分页不会重复加载。
4. 下拉刷新可用。
5. 无结果时有空状态。

---

## 七、阶段四：V2.1 个人主页收藏展示

### 阶段目标

配合成员 5 的用户主页，把收藏内容和统计信息展示在个人主页中。

### 任务 1：开发主页收藏预览组件

组件名称：

```text
ProfileCollectionPreview
```

展示内容：

1. 最近收藏。
2. 代表性收藏卡片。
3. 点击进入收藏详情。

### 任务 2：开发收藏统计展示区域

数据来源：

```text
GET /api/users/:id/stats
```

展示内容：

1. 收藏总数。
2. 分类数量。
3. 最近记录时间。
4. 公开收藏数。

### 任务 3：开发按类别展示区域

展示方式：

1. 类别 tabs。
2. 类别下收藏列表。
3. 和收藏墙共用卡片组件。

### 任务 4：支持公开和私密状态展示

规则：

1. 私密收藏在自己的主页可见。
2. 公开主页只显示 public 收藏。
3. unlisted 收藏只通过链接访问。

### 任务 5：与成员 5 联调主页数据

重点：

1. 用户数据字段。
2. 统计数据字段。
3. 收藏列表复用。
4. 空主页状态。

### 阶段四验收标准

1. 个人主页可以展示收藏预览。
2. 统计数据可显示。
3. 收藏卡片组件可以复用。
4. 公开和私密展示逻辑不混乱。

---

## 八、阶段五：V3.1 公开浏览和展示扩展

### 阶段目标

为分享和增长阶段预留公开收藏展示能力。

### 任务 1：公开收藏列表页面

页面名称：

```text
PublicCollectionsPage
```

接口：

```text
GET /api/public/collections
```

### 任务 2：精选收藏区域

展示内容：

1. 精选收藏。
2. 最近公开收藏。
3. 按类别浏览入口。

### 任务 3：公开收藏详情页

实现要求：

1. 不展示私密字段。
2. 可展示分享入口。
3. 可展示作者信息。

### 任务 4：社交互动占位

为 V3.3 预留：

1. 点赞按钮。
2. 评论入口。
3. 收藏按钮。
4. 关注入口。

### 任务 5：与成员 6 对接演示素材

给成员 6 提供：

1. 收藏墙截图。
2. 搜索筛选截图。
3. 详情页截图。
4. 公开收藏展示截图。

### 阶段五验收标准

1. 收藏展示模块可以支持个人和公开两种场景。
2. 页面状态完整。
3. 可用于最终 Demo 和 PPT 截图。

---

## 九、最终交付物清单

| 交付物 | 用途 |
|--------|------|
| `collection_wall_page.dart` | 收藏墙页面 |
| `collection_card.dart` | 收藏卡片组件 |
| `collection_grid.dart` | 收藏墙布局 |
| `collection_detail_page.dart` | 收藏详情页 |
| `collection_search_bar.dart` | 搜索框 |
| `category_filter_tabs.dart` | 分类筛选 |
| `tag_filter_sheet.dart` | 标签筛选 |
| `profile_collection_preview.dart` | 个人主页收藏展示 |
| `Browse_Flow_Test_Notes.md` | 浏览流程自测说明 |

---

## 十、成员 3 最终汇报重点

成员 3 在汇报中应重点说明：

1. 如何实现美观收藏墙。
2. 如何让用户查看完整收藏详情。
3. 如何实现搜索、分类筛选、标签筛选和分页。
4. 如何复用收藏展示到个人主页和公开页面。
5. 展示体验如何体现“数字收藏档案”的产品定位。
