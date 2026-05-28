# Collection Journey App 后 MVP 下一步详细技术计划

> 上次更新：2026-05-28  
> 当前基线：`codex/integration-prep` 已达到 MVP 整合完成标准。  
> 主要依据：`PROJECT_STATUS.md`、`Post_MVP_Issues.md`、`README.md`、`API_Contract.md`，并结合当前代码状态复核。  
> 本文件用途：作为 Post-MVP bug 修复、演示前打磨、测试补强和后续生产化的具体执行路线。

---

## 0. 当前结论与执行口径

当前项目不是“还没整合完”，而是已经进入 **MVP 后修复和打磨阶段**：

- 后端 Express + sql.js、Flutter 主应用、AI 路由、Profile、Room、Create/Edit、Share Preview 已集中在当前工作树中。
- Create -> Gallery -> Detail -> Edit -> Profile 主路径已经可演示。
- 下一阶段不要再从 `INTEGRATION_IMPLEMENTATION_PATH.md` 或早期 `past_doc/` 重新领旧任务。
- 后续任务优先从本文档领取；每修完一个问题，同步更新 `PROJECT_STATUS.md` 和 `Post_MVP_Issues.md` 的状态。

`Post_MVP_Issues.md` 目前存在编号重复：`问题 6` / `问题 7` 在文档中出现了多次。本文档采用下面的统一编号，和 `PROJECT_STATUS.md` 的问题口径对齐，并额外加入当前代码复核发现的合同风险：

| 统一编号 | 问题 | 优先级 | 当前状态 |
|---|---|---|---|
| ISSUE-08 | 英文化 AI 合同迁移：数据库/schema 已英文，AI prompt/mock/前端映射/测试脚本需同步 | P0 | ✅ 已验证完成（2026-05-27） |
| ISSUE-05 | AI 故事风格切换时内容追加/污染，而非干净替换 | P1 | ✅ 已完成（2026-05-28） |
| ISSUE-06 | Profile Favorite tags 使用 Gallery 当前列表，筛选结果可能错误 | P1 | ✅ 已完成（2026-05-28） |
| ISSUE-01 | Room Reflection Redo 按钮无功能 | P1 | ✅ 已完成（2026-05-28） |
| ISSUE-03 | Room 月份不一致：API 返回 March/April/May，设计预期 May/June/July | P1 | ✅ 已完成（2026-05-28） |
| ISSUE-07 | AI Suggestions 标题旁的 `(Member E)` 标注应移除 | P2 | ✅ 已完成（2026-05-27） |
| ISSUE-04 | RoomSelectorRow room label 过长时缺少溢出保护 | P2 | ✅ 已验证完成（2026-05-28） |
| ISSUE-02 | Add 页空输入时 AI 生成过于模板化 | P3 | 可选未处理 |
| ISSUE-09 | 剩余中文注释 / 历史说明 / 测试日志清理 | P3 | 可选未处理 |

---

## 1. 推荐工作顺序

### 第一轮：先修合同和高风险功能

目标：让 AI、Profile、Room 这三块不会在演示中出现明显错误。

1. ISSUE-08 已完成：英文 category / AI 输出 / 前端映射迁移已验证，可作为后续修复基线。
2. 修复 ISSUE-05：AI 故事风格切换污染。
3. 修复 ISSUE-06：Profile Favorite tags 数据源独立。
4. 修复 ISSUE-01：Room Reflection Redo 接入真实 AI 或稳定 mock。
5. 修复 ISSUE-03：统一 Room seed 月份和演示数据。

### 第二轮：低风险 UI polish

目标：快速消除展示时容易被发现的小问题。

1. 修复 ISSUE-07：移除 `(Member E)`。
2. ISSUE-04 已完成：RoomSelectorRow label 已加 `maxLines` / `ellipsis`，并有窄屏 widget regression test。
3. 修复 ISSUE-02：优化空输入 AI 行为和 mock 随机性。
4. 处理 ISSUE-09 中剩余注释、历史说明和测试日志中文。

### 第三轮：测试、文档和交付整理

目标：让下一位成员可以不依赖聊天记录接手。

1. 跑后端和 AI 回归脚本。
2. 跑 Flutter test/analyze/build。
3. 更新 `PROJECT_STATUS.md`、`Post_MVP_Issues.md`、必要时更新 `API_Contract.md`。
4. 更新 `PictureofProduct/` 或成员 6 demo 材料。
5. 整理分支和提交。

---

## 2. P0：完成英文 AI 合同迁移

### 当前状态

✅ 已验证完成（2026-05-27）。本节保留为技术路线和验收依据，后续成员不需要再把 ISSUE-08 当作未处理 P0 领取；若团队要求“代码文件完全无中文字符”，应另开 P3 注释/历史文案清理任务。

### 问题

团队当前方向已经明确：产品和数据库都要统一为英文。数据库负责人已经把 `backend/src/db/seed.js` 中的 categories / collections / tags 等 demo 数据迁到英文，并且 `member_E/backend/src/ai/ai.schemas.js` 的 `COLLECTION_CATEGORIES` 也已经改成英文：

```js
['Minerals', 'Crystals', 'Vinyl Records', ...]
```

现在的问题不是要回滚数据库，而是 **AI 适配层和前端映射还停在中文合同**。全库代码扫描后，真正影响运行和用户输出的中文落点集中在这些地方：

| 类型 | 文件 | 当前问题 |
|---|---|---|
| AI prompt | `member_E/backend/src/ai/ai.prompts.js` | title/category/tags/story/analyze-image prompt 仍要求输出中文 |
| Vision prompt | `member_E/backend/src/ai/vision.prompts.js` | GLM Vision prompt 仍要求中文标题、标签、描述 |
| AI mock | `member_E/backend/src/ai/ai.provider.js` | mock title/category/tags/story/image analysis 仍返回中文 |
| 前端映射 | `frontend/lib/features/collection_form/utils/ai_category_mapping.dart` | 仍用中文 category -> slug，并把 slug 转中文发给 AI |
| Create fallback | `frontend/lib/features/collection_form/pages/create_collection_page.dart` | 空输入 fallback 是 `'收藏品'` |
| 旧 Add demo | `frontend/lib/features/collection_browse/pages/add_exhibit_design_page.dart` | 图片识别 fallback description 是中文 |
| 公开页 UI | `frontend/lib/features/collection_browse/pages/public_collections_page.dart` | 空状态和社交占位按钮仍是中文 |
| Profile mock | `frontend/lib/features/profile/models/user_profile.dart` | 默认 bio 仍是中文 |
| 测试脚本 | `member_E/scripts/*.js` | sample input、assert 文案、prompt 断言仍按中文写 |
| 旁路副本 | `member_B/frontend/lib/features/collection_form/*` | 成员 B 旧副本仍保留中文 AI 映射；如仍用于交接，也要同步 |

普通中文注释很多，但它们不影响运行合同。建议最后单独清理，不要和功能迁移混在一个提交里。

### 新推荐技术路线

现在应当 **顺着数据库英文化继续迁移**，不要恢复中文 schema。新的 P0 目标是：

1. 后端 AI schema、prompt、mock 全部输出英文。
2. 前端 AI category 映射改为英文 category display name -> API slug。
3. 前端传给 AI 的 category 也改为英文 display name。
4. 测试脚本同步改英文 sample 和断言。
5. 用户可见中文 UI 先清掉，中文注释可后置。

### 英文 category 合同

以数据库和 schema 目前口径为准，统一使用这组 AI category display names：

| AI / category display name | API slug | Favorite tag |
|---|---|---|
| `Minerals` | `mineral` | `Mineral` |
| `Crystals` | `crystal` | `Mineral` |
| `Vinyl Records` | `vinyl` | `Music` |
| `Postcards` | `postcard` | `Memory` |
| `Tickets` | `ticket` | `Ticket` |
| `Travel Souvenirs` | `souvenir` | `Memory` |
| `Stamps` | `stamp` | `Memory` |
| `Other Collections` | `other` | `Memory` |

注意：数据库里的 `category` 字段继续存 slug，例如 `vinyl`、`ticket`。AI 返回的是英文 display name，例如 `Vinyl Records`；前端再映射成 slug / Favorite tag。

### 涉及文件和处理方式

| 文件 | 处理 |
|---|---|
| `member_E/backend/src/ai/ai.schemas.js` | 保持英文 `COLLECTION_CATEGORIES`；可新增/确认 exported category list |
| `member_E/backend/src/ai/ai.prompts.js` | 改成英文 prompt：要求英文 title/tags/story/description，JSON 示例也英文 |
| `member_E/backend/src/ai/vision.prompts.js` | 改成英文 vision prompt；`language` 默认从 `zh-CN` 改为 `en` 或 `en-US` |
| `member_E/backend/src/ai/ai.provider.js` | mock 返回英文；`inferMockKind()` 识别英文 prompt；story style regex 改成英文 |
| `frontend/lib/features/collection_form/utils/ai_category_mapping.dart` | 重命名/新增 `aiCategoryToSlug`、`apiSlugToAiCategory`，全部英文 |
| `frontend/lib/features/collection_form/pages/create_collection_page.dart` | `apiSlugToChineseCategory` 改为英文映射；fallback `'收藏品'` 改为 `'collectible'` 或空字符串拦截 |
| `frontend/lib/features/collection_browse/pages/add_exhibit_design_page.dart` | 中文图片描述 fallback 改为英文 |
| `frontend/lib/features/collection_browse/pages/public_collections_page.dart` | 中文空状态和按钮改英文 |
| `frontend/lib/features/profile/models/user_profile.dart` | 默认 bio 改英文 |
| `member_E/scripts/*.js` | sample input、expected prompt 片段、assert 文案改为英文合同 |
| `member_B/frontend/lib/features/collection_form/*` | 如果成员 B 目录仍作为交接代码，复制同样的英文映射；如果不用，则在文档标注历史副本 |
| `API_Contract.md` / `member_E/docs/AI_API_Contract.md` | 明确 AI category 返回英文 display name，数据库 collection category 仍存 slug |

### 实施步骤

1. **锁定 category 常量**  
   保留 `ai.schemas.js` 中的英文 `COLLECTION_CATEGORIES`，并把所有 prompt 示例改为这些英文值之一，尤其是：
   - category response 示例：`"category": "Postcards"`
   - image analysis 示例：`"suggestedCategory": "Tickets"`
2. **重写 AI prompt 语言**  
   `ai.prompts.js` 中所有“中文标题 / 中文标签 / 中文字符 / 未提供 / 不要编造”等中文指令改为英文：
   - `valueOrEmpty()` fallback 改为 `Not provided`。
   - title：`Generate 3 English title suggestions`。
   - tags：`Generate 3 to 8 short English tags`。
   - story：`Generate an editable English story draft, around 80-130 words`。
   - category fallback：信息不足时选择 `Other Collections`。
3. **重写 Vision prompt**  
   `vision.prompts.js` 默认 `language` 改为 `en-US`，规则要求英文输出，示例 JSON 用英文。
4. **重写 mock provider**  
   `ai.provider.js` 中：
   - mock story 改英文。
   - image analysis mock 改英文 title/category/tags/description。
   - category mock 返回 `{ category: 'Postcards', confidence: 0.75 }`。
   - tags mock 返回英文 tags。
   - title mock 返回英文 title suggestions。
   - `inferMockKind()` 不再依赖中文 prompt 关键词，改识别英文 prompt 或优先使用 `mockKind`。
   - story style match 从 `/风格代码：(\w+)/` 改成英文，例如 `/Style code:\\s*(\\w+)/i`。
5. **重写前端 category 映射**  
   `ai_category_mapping.dart` 建议改成：

```dart
const Map<String, String> aiCategoryToSlug = {
  'Minerals': 'mineral',
  'Crystals': 'crystal',
  'Vinyl Records': 'vinyl',
  'Postcards': 'postcard',
  'Tickets': 'ticket',
  'Travel Souvenirs': 'souvenir',
  'Stamps': 'stamp',
  'Other Collections': 'other',
};

const Map<String, String> apiSlugToAiCategory = {
  'mineral': 'Minerals',
  'crystal': 'Crystals',
  'vinyl': 'Vinyl Records',
  'postcard': 'Postcards',
  'ticket': 'Tickets',
  'souvenir': 'Travel Souvenirs',
  'stamp': 'Stamps',
  'other': 'Other Collections',
};
```

   然后把 `tagLabelForAiCategory(String chineseCategory)` 改成 `tagLabelForAiCategory(String category)`，内部使用 `aiCategoryToSlug`。
6. **更新 Create flow 调用点**  
   `create_collection_page.dart` 中：
   - `apiSlugToChineseCategory[form.category]` 改为 `apiSlugToAiCategory[form.category]`。
   - `'收藏品'` 改为 `'collectible'`，或者更推荐改成空字符串，让 `_ensureDescription()` 提示用户先输入 title/story。
7. **清用户可见中文 UI**  
   先改这些会真实显示给用户的字符串：
   - public browse empty state / social buttons。
   - profile mock bio。
   - 旧 Add demo 的 AI image description fallback。
8. **同步测试脚本**  
   先改会直接断言 prompt 或 schema 的脚本：
   - `verify_phase1_task1_title.js`
   - `verify_phase2_task1_provider.js`
   - `verify_phase2_tasks2_4_api.js`
   - `verify_phase4_tasks1_5_api.js`
   - `verify_phase5_demo_e2e.js`
   - `verify_deepseek_provider_live.js`
   - `verify_glm_vision_live.js`
9. **再处理中文注释**  
   功能迁移通过后，再决定是否把中文注释也换英文。它们不影响合同，但如果要求“代码中完全无中文”，就单独做一个 `docs/comments: translate code comments` 提交。

### 验收标准

- 对运行相关文件执行 `rg -n "[\\p{Han}]" ... --glob '!**/*.md'` 后，剩余命中应只是不影响运行的注释/历史说明；若团队要求代码零中文，再按第 10 节清注释。
- `POST /api/ai/suggest-category` mock 返回英文 category，例如 `Postcards`，并通过 validator。
- `POST /api/ai/analyze-image` mock 返回英文 `suggestedTitle`、`suggestedCategory`、`suggestedTags`、`description`。
- Add 页点击 Category 后可以正确映射到 `Music` / `Ticket` / `Mineral` / `Memory` chip。
- 前端创建 collection 时，数据库保存的 `category` 仍是 slug，不保存英文 display name。
- AI 真实调用时，标题、标签、故事、图片描述都输出英文。

### 测试命令

```bash
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
cd frontend
flutter analyze --no-pub --no-fatal-infos
```

### 2026-05-27 回归结果

已通过：

```bash
node member_E/scripts/verify_phase1_task1_title.js
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
cd frontend && flutter test --no-pub
cd frontend && flutter analyze --no-pub --no-fatal-infos
```

手动 API 复核：

- `/api/ai/suggest-category` 返回英文 category，例如 `Tickets`。
- `/api/ai/analyze-image` 返回英文 title/category/tags/description。

备注：`flutter analyze --no-pub --no-fatal-infos` 退出码为 0，仅剩既有 info 级样式/弃用提示。

---

## 3. P1：AI 故事风格切换污染

### 问题

在 Add/Create 页中，用户先生成 Scrapbook 故事，再切换 Vintage 风格时，新故事会把旧故事当作 description 输入，导致内容像“追加”或重复前缀。

当前关键代码：

- `frontend/lib/features/collection_form/pages/create_collection_page.dart`
  - `buildPayload()` 使用 `form.story` 作为 `description`。
- `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart`
  - 风格 `ChoiceChip` 切换后直接 `_runStory()`，没有清理旧 AI story。

### 推荐技术路线

短期推荐按 `Post_MVP_Issues.md` 的方案 A 修复：**风格切换触发自动重写时，先清空当前 story，再请求新 story**。

这条路线改动小，可以保证新风格不吃到旧风格生成结果。

### 涉及文件

| 文件 | 处理 |
|---|---|
| `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart` | 新增 `VoidCallback? onStoryReset`；风格切换时先调用 |
| `frontend/lib/features/collection_form/pages/create_collection_page.dart` | 传入 `onStoryReset`，同步清空 provider 和 `_storyController` |
| `frontend/lib/features/collection_form/providers/collection_form_provider.dart` | 通常无需修改，复用现有 `updateStory('')` |

### 实施步骤

1. 给 `AiSuggestionPanel` 构造函数新增可选参数：

```dart
final VoidCallback? onStoryReset;
```

2. 在 `ChoiceChip.onSelected` 中调整顺序：

```dart
if (!selected || _storyStyle == style) return;
setState(() => _storyStyle = style);
widget.onStoryReset?.call();
_runStory();
```

3. 在 `CreateCollectionPage` 传入：

```dart
onStoryReset: () {
  ref.read(collectionFormProvider.notifier).updateStory('');
  _storyController.clear();
},
```

4. 手测时注意两种场景：
   - 空 story -> 生成 Scrapbook -> 切 Vintage：新结果应替换旧结果。
   - 用户手动编辑 story 后点 Story 按钮：仍允许使用当前手写内容作为上下文。

如果要做更稳的长期方案，可以在 `CreateCollectionPage` 维护 `_lastAiGeneratedStory`，只有 `form.story == _lastAiGeneratedStory` 时才在风格切换中清空；这样能更好地区分“AI 生成稿”和“用户手写稿”。但演示前不建议扩大改动。

### 验收标准

- 切换任意故事风格后，TextField 中只有新风格故事，没有旧风格前缀或重复句。
- `onStoryApplied(story)` 仍然覆盖正式表单状态。
- AI 失败时不会清空用户已经手动保存的标题、分类、标签、图片和 room 字段。

### 测试建议

手测 Add 页：

1. title 和 story 留空。
2. 点击 Story，记下默认风格输出。
3. 切换 Scrapbook / Travel / Vintage。
4. 确认每次都是替换，而不是把上一段作为素材续写。

同时跑：

```bash
cd frontend
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub
```

---

## 4. P1：Profile Favorite Tags 筛选数据源独立

### 问题

Profile 页 Favorite tags 当前使用的是 `collectionListProvider.items`。这个 provider 同时服务 Gallery，所以当 Gallery 有 keyword/category/tag 筛选或分页状态时，Profile 只拿到 Gallery 当前列表的一部分数据，点击 tag 后可能显示 `No exhibits`。

当前关键代码：

- `frontend/lib/features/collection_browse/widgets/profile_collection_preview.dart`
  - `final list = ref.watch(collectionListProvider);`
  - `filterProfileItems(allItems, categoryId: favoriteCategoryId)`
- `frontend/lib/features/collection_browse/providers/collection_list_provider.dart`
  - `collectionListProvider` 带 Gallery query 状态。

### 推荐技术路线

新增 **Profile 专用收藏数据 provider**，永远使用无 keyword/category/tag 的全量收藏数据，不共享 Gallery 当前筛选状态。

### 涉及文件

| 文件 | 处理 |
|---|---|
| `frontend/lib/features/collection_browse/services/collection_query_service.dart` | 新增 `fetchAllCollections()` 或分页拉取方法 |
| `frontend/lib/features/collection_browse/providers/collection_list_provider.dart` | 新增 `profileCollectionsProvider` |
| `frontend/lib/features/collection_browse/widgets/profile_collection_preview.dart` | 改为读取 Profile 专用 provider |
| `frontend/lib/features/collection_browse/utils/profile_exhibit_utils.dart` | 大概率无需改；继续接收完整 items |

### 实施步骤

1. 在 `CollectionQueryService` 新增方法，避免只拉第一页：

```dart
Future<List<CollectionItem>> fetchAllCollections({
  String? visibility,
  int pageSize = 100,
}) async {
  final items = <CollectionItem>[];
  var page = 1;
  var total = 0;
  do {
    final result = await fetchCollections(
      CollectionQueryState(
        page: page,
        pageSize: pageSize,
        visibility: visibility,
      ),
    );
    items.addAll(result.items);
    total = result.total;
    page += 1;
  } while (items.length < total && page < 20);
  return items;
}
```

2. 在 provider 文件新增：

```dart
final profileCollectionsProvider =
    FutureProvider<List<CollectionItem>>((ref) async {
  return ref.watch(collectionQueryServiceProvider).fetchAllCollections();
});
```

3. 在 `ProfileCollectionPreview` 中：
   - 保留 `userStatsProvider`。
   - 用 `profileCollectionsProvider` 的 data 作为 `allItems`。
   - loading 时显示小型 loading 或使用 `stats.recentCollections` fallback。
   - error 时可以退回 `collectionListProvider.items`，但 UI 需要显示非阻塞错误提示。

4. Profile 的 public preview 仍然可以在前端用 `filterProfileItems(publicOnly: true)` 二次过滤；不要再让 Gallery query 参与 Profile 数据。

### 验收标准

- 在 Gallery 先搜索一个不存在的关键词，然后进入 Profile，Favorite tags 仍能显示对应分类展品。
- Gallery 切到某个 category 后，Profile 切另一个 tag 不受影响。
- Recent exhibits、Last added、Room preview 都基于 Profile 全量数据或 stats fallback。

### 测试建议

手测路径：

1. Gallery 搜索 `zzzz`，让 Gallery 为空。
2. 切到 Profile。
3. 点击 `Music` / `Ticket` / `Mineral` / `Memory`。
4. Profile 应展示真实数据，而不是继承 Gallery 空结果。

---

## 5. P1：Room Reflection Redo 按钮接入 AI

### 问题

Room 页面 `AI ROOM REFLECTION` 卡片里的 Redo 按钮当前是空函数：

```dart
onPressed: () {}
```

Reflection 内容目前也是页面内根据 room item count 拼出来的静态文案，不是 AI 生成。

### 推荐技术路线

新增一个后端 AI endpoint：`POST /api/ai/generate-room-reflection`。前端 Room 页面点击 Redo 时，把当前 room 的 metadata 和 collections 摘要发送给后端，后端返回 `{ reflection: string }`，前端替换当前卡片文案。

短期继续使用现有 AI provider 架构，不新增第三方依赖。

### 后端实施

#### 涉及文件

| 文件 | 处理 |
|---|---|
| `member_E/backend/src/ai/ai.schemas.js` | 新增 endpoint 常量、`validateRoomReflectionResponse()` |
| `member_E/backend/src/ai/ai.prompts.js` | 新增 `buildRoomReflectionPrompt(input)` |
| `member_E/backend/src/ai/ai.service.js` | 新增 `generateRoomReflection(input)` |
| `member_E/backend/src/ai/ai.routes.js` | 新增 body schema 和 route |
| `member_E/backend/src/ai/ai.provider.js` | 新增 mock kind：`roomReflection` |
| `member_E/docs/AI_API_Contract.md` / `API_Contract.md` | 补充 endpoint 合同 |

#### 请求体建议

```json
{
  "roomId": 1,
  "roomLabel": "May Room",
  "month": "2026-05",
  "language": "zh-CN",
  "items": [
    {
      "title": "Pink Floyd — The Dark Side of the Moon",
      "category": "vinyl",
      "tags": ["vinyl", "music"],
      "story": "A 1973 UK pressing...",
      "location": "London, UK",
      "dateAcquired": "2026-05-07"
    }
  ]
}
```

#### 响应体建议

```json
{
  "success": true,
  "data": {
    "reflection": "这个房间像一段五月的收藏日记，音乐、旅行和小物件把不同地点串成同一个记忆柜。"
  }
}
```

#### Prompt 规则

`buildRoomReflectionPrompt(input)` 建议约束：

- 输出 JSON only：`{ "reflection": "..." }`
- 输出英文，长度建议 60-100 words；如果未来重新引入多语言，再由 `language` 控制。
- 只总结 room 内已有展品，不编造人物、品牌、事件。
- items 为空时返回保守文案，不报错。
- 如果 stories 很长，只截取每个 item 的 title/category/tags/location/date/story 前 120 字，避免 prompt 过长。

#### 路由建议

在 `ai.routes.js` 新增独立 schema，不复用现有 `description required` 的 `aiBodySchema`：

```js
const roomReflectionBodySchema = z.object({
  roomId: z.number().optional(),
  roomLabel: z.string().optional(),
  month: z.string().optional(),
  language: z.string().optional(),
  items: z.array(z.object({
    title: z.string().optional(),
    category: z.string().optional(),
    tags: z.array(z.string()).optional(),
    story: z.string().optional(),
    location: z.string().optional(),
    dateAcquired: z.string().optional(),
  })).default([]),
});
```

### 前端实施

#### 涉及文件

| 文件 | 处理 |
|---|---|
| `frontend/lib/features/collection_browse/pages/collection_room_page.dart` | `_AiReflectionCard` 改为有状态，Redo 触发请求 |
| `frontend/lib/features/collection_browse/services/room_reflection_service.dart` | 新增 Room 专用 AI service |
| `frontend/lib/features/collection_browse/providers/collection_list_provider.dart` | 可新增 `roomReflectionServiceProvider` |

#### 推荐前端设计

不要让 Room 页面直接 import `collection_form/services/ai_suggestion_service.dart`，因为那是表单 feature 的服务。建议在 browse feature 下新增轻量服务：

```dart
class RoomReflectionService {
  Future<String> generateRoomReflection({
    required CollectionRoomDetail? room,
    required List<CollectionItem> items,
  });
}
```

请求 payload 从 `CollectionItem` 中取：

- `title`
- `category`
- `tags`
- `story`
- `location`
- `dateAcquired`

`_AiReflectionCard` 可以改成 `ConsumerStatefulWidget`，内部维护：

- `_reflection`
- `_loading`
- `_error`

Redo 行为：

1. 如果 `_loading`，按钮 disabled。
2. 点击后显示 `Redoing...` 或 loading spinner。
3. 成功时 `setState(() => _reflection = result)`。
4. 失败时保留旧 reflection，SnackBar 提示 `AI reflection failed. You can keep browsing.`

### 验收标准

- Room 有展品时点击 Redo，会更新 reflection 文案。
- Room 为空时点击 Redo 不崩溃，返回保守文案或显示可理解提示。
- AI provider 不可用时，页面保留旧文案，用户仍能浏览 highlights/timeline。
- 后端 mock 模式和真实 AI 模式都走同一个 endpoint。

### 测试命令

```bash
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
cd frontend
flutter analyze --no-pub --no-fatal-infos
```

建议新增一个脚本或扩展现有脚本，直接测：

```bash
curl -X POST http://localhost:3000/api/ai/generate-room-reflection \
  -H "Content-Type: application/json" \
  -d '{"roomLabel":"May Room","month":"2026-05","items":[{"title":"A ticket","category":"ticket"}]}'
```

---

## 6. P1：Room 月份数据统一

### 问题

当前 `backend/src/db/seed.js` 中 rooms 是：

```js
{ month: '2026-03', label: 'March Room' },
{ month: '2026-04', label: 'April Room' },
{ month: '2026-05', label: 'May Room' },
```

但设计文档和产品截图口径是 May / June / July。因为 Gallery/Profile 已经改读 `/api/rooms`，所以 UI 现在显示 March / April / May。

### 推荐技术路线

将后端 seed 作为唯一房间来源，统一为 May / June / July。前端继续读取 `/api/rooms`，不回退到硬编码。

为了避免 June/July 房间为空导致演示尴尬，建议同时决定是否把 seed collections 分布到 5/6/7 月：

- 演示前快速修复：只改 room seed 为 May/June/July，保持所有 seed collection 仍为 May。
- 更完整修复：将 15 条 seed collection 按 5 条一组分配到 2026-05、2026-06、2026-07，并更新截图材料。

推荐走更完整修复，因为 Room count、Room detail 和 Profile room preview 会更一致。

### 涉及文件

| 文件 | 处理 |
|---|---|
| `backend/src/db/seed.js` | 修改 `seedData.rooms`；可选修改 collection `date_acquired` 分布 |
| `backend/data/collections.db` | 运行 `npm run seed` 后随代码提交 demo DB |
| `PictureofProduct/` | 如果截图中月份变动，最终 demo 前更新 |
| `PROJECT_STATUS.md` | 更新问题状态 |

### 实施步骤

1. 修改 rooms：

```js
rooms: [
  { month: '2026-05', label: 'May Room' },
  { month: '2026-06', label: 'June Room' },
  { month: '2026-07', label: 'July Room' },
],
```

2. 完整修复时，按收藏顺序分布日期：
   - seed 01-05：`2026-05-xx`
   - seed 06-10：`2026-06-xx`
   - seed 11-15：`2026-07-xx`
3. 运行：

```bash
cd backend
npm run seed
```

4. 启动后端检查：

```bash
curl http://localhost:3000/api/rooms
```

5. 前端手测 Gallery Room selector 和 Profile room preview。

### 验收标准

- `/api/rooms` 返回 May / June / July。
- Gallery 顶部 RoomSelectorRow 显示 May / June / July。
- Profile 下方 Room preview 显示 May / June / July。
- 进入每个 Room 不出现错误态；如果做完整修复，每个 room 至少有若干展品。

---

## 7. P2：移除 AI Suggestions 的 `(Member E)` 标注

### 问题

正式产品展示时，Add 页 AI 面板标题旁显示 `(Member E)`，属于开发标记。

### 技术路线

直接删除 `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart` 中的标注 Text：

```dart
Text(
  '(Member E)',
  style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 10),
),
```

同时删除前面的 `SizedBox(width: 6)`，避免标题后留下多余间距。

### 验收标准

- Add/Create 页 AI 面板只显示 `AI SUGGESTIONS`。
- 面板布局不出现奇怪空白。

---

## 8. P2：RoomSelectorRow label 溢出保护

### 当前状态

✅ 已验证完成（2026-05-28）。本节保留为技术路线和验收依据，后续成员不需要再领取 ISSUE-04。

### 问题

Room label 如 `March Room` / `April Room` 字符较长，原先 `RoomSelectorRow` 第二行 `Text(label)` 缺少 `maxLines` 和 `overflow`，窄屏可能溢出。

### 技术路线

修改 `frontend/lib/features/collection_browse/widgets/design/room_selector_row.dart`：

```dart
Text(
  label,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: CollectoryTypography.cardTitle.copyWith(...),
)
```

如果同时完成 ISSUE-03，标签会变成 May/June/July，风险降低，但这个防护仍应保留。

### 验收标准

- 390px 宽度下 RoomSelectorRow 没有文字溢出。
- May/June/July 或更长 label 都不会撑坏布局。

### 2026-05-28 回归结果

已新增并通过 `frontend/test/room_selector_row_test.dart`：

```bash
flutter test --no-pub test/room_selector_row_test.dart
flutter test --no-pub
flutter analyze --no-pub --no-fatal-infos
```

测试覆盖 240px 窄宽度下的 March / April / May room label，确认没有 Flutter overflow 异常，且 `March Room` 的 `Text` 使用 `maxLines: 1` 和 `TextOverflow.ellipsis`。

---

## 9. P2：Add 页空输入 AI 行为优化

### 问题

当前 `CreateCollectionPage.buildPayload()` 在 title/story 都为空时使用 `'收藏品'` 作为 description fallback。这样 AI 虽然能发请求，但上下文太少；mock 模式下也总是返回固定结果。

### 推荐技术路线

分两步做，先保证体验清楚，再增强演示效果。

### Step A：空输入时明确提示，不强行用 `'收藏品'`

修改 `buildPayload()` 的 fallback：

```dart
description: form.story.isNotEmpty
    ? form.story
    : (form.title.isNotEmpty ? form.title : ''),
```

这样 `_ensureDescription()` 会真正拦截空输入。然后把 SnackBar 文案改得更具体：

```dart
'Add a title or story note first so AI can make useful suggestions.'
```

当前产品路线已经确认英文化，这里统一用英文提示。

### Step B：mock 模式增加少量变体

修改 `member_E/backend/src/ai/ai.provider.js`：

- title mock 从固定一组改为 3-5 组。
- tags mock 根据 prompt 中是否出现 ticket/vinyl/mineral/postcard 返回不同标签。
- story mock 已按 style 有差异，可以保留。

建议不要做真正随机，而是根据 prompt hash 或关键词选择结果，避免测试不稳定。

### 暂不建议：快速生成模式

`Post_MVP_Issues.md` 提到“快速生成模式”。这会引入额外状态、偏好选择和更复杂的交互，演示前不建议做。可以放到 P3。

### 验收标准

- title/story 都为空时，点击 Titles/Category/Tags/Story 会出现清楚提示。
- 有 title 或 story 时，AI 正常工作。
- mock 模式下，输入不同描述时 title/category/tags 至少有一点差异。

---

## 10. P2/P3：剩余中文代码清理

### 问题

ISSUE-08 已经处理影响运行合同的 AI prompt/mock/mapping，以及主要用户可见中文。剩下的中文大多是注释、历史说明或测试日志文案。

这里分两类处理，避免为了“零中文”去改动已经不参与运行的历史代码。

### P2：补清未来发现的用户可见 UI 中文

2026-05-27 复核时，已知公开浏览页用户可见中文已处理。若后续扫描或手测又发现新的用户可见中文，优先按下面口径替换：

| 当前中文 | 建议英文 |
|---|---|
| `暂无公开收藏` | `No public exhibits yet` |
| `将收藏设为 public 后会出现在此列表。` | `Set an exhibit to public and it will appear here.` |
| `点赞` | `Like` |
| `评论` | `Comment` |
| `收藏` | `Save` |
| `关注` | `Follow` |

验收：公开浏览页不再出现中文 UI。

### P3：清注释、测试输出和历史副本

功能合同稳定后，再决定是否清理所有中文注释和历史测试输出。主要范围：

- `frontend/lib/**` 中的中文注释。
- `backend/src/**` 中的中文注释。
- `member_E/scripts/*.js` 中的中文 console/assert 文案。
- `member_B/frontend/lib/features/collection_form/*` 旧副本。
- `member_E/backend/src/ai/ai.prompts.js`
- `member_E/backend/src/ai/vision.prompts.js`
- `member_E/backend/src/ai/ai.provider.js`

如果团队要求“代码文件内不能出现中文字符”，验收命令可以用：

```bash
rg -n "[\\p{Han}]" frontend backend member_E member_B --glob '!**/*.md' --glob '!**/node_modules/**' --glob '!**/build/**'
```

---

## 11. 测试与回归清单

每修完一批问题后，按风险选择测试。

### 后端和 AI

```bash
cd backend
npm run seed
npm start
```

另开终端：

```bash
node member_E/scripts/verify_phase1_task1_title.js
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
```

### Flutter

```bash
cd frontend
flutter test --no-pub
flutter analyze --no-pub --no-fatal-infos
flutter build web --release --no-pub --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:3000
```

### 手测主路径

1. Gallery 打开，Room selector 显示 May/June/July。
2. 点击 Room，Redo reflection 可工作或失败不阻塞。
3. Add 页上传图片、生成标题/分类/标签/故事。
4. 故事风格切换不会复用旧风格文本。
5. 保存后回 Gallery，打开 Detail，再进入 Edit。
6. Gallery 加筛选后切 Profile，Favorite tags 不受 Gallery 状态影响。
7. Share Preview / Public Browse 页面没有明显中文 UI 或开发标记。

---

## 12. 文档更新规则

修复代码后必须同步这些文档：

| 文档 | 更新内容 |
|---|---|
| `PROJECT_STATUS.md` | 对应 issue 状态从未处理改为已处理，补一句验证方式 |
| `Post_MVP_Issues.md` | 对应问题下增加“处理结果 / commit / 测试” |
| `API_Contract.md` | 只有新增或修改 HTTP 合同时更新，例如 Room Reflection endpoint |
| `member_E/docs/AI_API_Contract.md` | AI endpoint 或 AI response schema 改动时更新 |
| `DOCUMENTATION_STATUS.md` | 新增重要文档或改变文档权威状态时更新 |

---

## 13. 分支和提交建议

建议按下面粒度提交，方便回滚和 code review：

1. `fix(ai): migrate AI contract and story flow to English`
2. `fix(profile): isolate favorite tag data from gallery filters`
3. `feat(ai): generate room reflection endpoint`
4. `fix(seed): align room months with demo design`
5. `polish(ui): remove dev labels and guard room selector overflow`
6. `docs: update post-mvp status and next plan`

如果演示时间很近，优先合并 1、2、4、5；`Room Reflection Redo` 涉及新增 API，可以作为单独 PR 或单独提交，避免影响已有 Create/Gallery 主路径。
