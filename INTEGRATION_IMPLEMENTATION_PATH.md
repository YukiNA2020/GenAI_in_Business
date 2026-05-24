# Collection Journey App 分阶段整合实施路径

> 上次更新：2026-05-24
> 负责人：成员 E / 成员 5，由 Codex 协助整理
> 当前目标：在不立即完整合并高风险分支的前提下，先把 `20260522-version` 的非 AI 后端 / 数据库逻辑作为整合依据，同时保护 `feature/ai-profile-test` 中 DeepSeek 和 GLM 的 AI 设计，再把 rooms API、正式创建表单、AI 面板、API Contract 和回归路径拆成可执行步骤。

本文件是接下来统一整合前的执行路线。它不替代 `Status.md`、`Test.md` 或 `API_Contract.md`，而是说明“先做什么、怎么做、哪些内容暂时不要直接合并”。

---

## 1. 当前判断

当前可作为工作基线的是 `feature/ai-profile-test`。它已经包含：

- 成员 E 的 AI provider、DeepSeek-compatible 配置、`/api/ai/*` 路由挂载和测试脚本。
- 成员 E 的 Profile 页面与成员 C 浏览 UI 的联调结果。
- 当前 Flutter 前端、Add Demo 页、Gallery/Profile/Room 演示流程。
- DeepSeek 真实调用验证记录和测试文档。
- 本地工作区已完成 GLM Vision 图片理解接入，包括 `imageDataUrl`、`vision.provider.js`、`vision.prompts.js` 和 `verify_glm_vision_live.js`。这批内容尚未全部进入远端提交，开始合并前必须先提交或 stash 保护。

需要整合的来源分支有：

| 来源 | 当前用途 | 风险判断 |
|---|---|---|
| `20260522-version` | 非 AI 后端 / 数据库逻辑的主要依据：`backend/data/collections.db`、collections 列表 year/month 筛选、schema / seed / repository / service / controller 调整；同时吸收前端收藏墙/Gallery/Profile/Room 的 UI/交互修复和 PNG 路径重命名 | 不整体覆盖仓库，但后端数据库和非 AI 后端逻辑以它为准；冲突时只保护 `feature/ai-profile-test` 中 DeepSeek / GLM / `/api/ai` / 成员 E AI 文档和脚本 |
| `feature/member-1-task` | 成员 A rooms API、`room_id` 数据结构、room seed 数据 | 不能先完整合并；该分支相对当前基线会删除大量 `frontend/`、`member_B/`、`member_E/` 文件，也会删除当前 AI 路由适配文件 |

所以本轮策略是：先开准备分支，按功能手动迁移有效内容；`20260522-version` 先按本文档对齐非 AI 后端 / 数据库逻辑并摘取目标前端修复，`feature/member-1-task` 只迁移 rooms 相关能力；等 rooms、正式表单、API Contract 和回归都稳定后，再做最后的统一整合分支。

合并冲突总规则：

| 冲突范围 | 取舍 |
|---|---|
| 非 AI 后端 / 数据库逻辑 | 以 `20260522-version` 为准，包括 `backend/data/collections.db`、`backend/src/db/schema.sql`、`backend/src/db/seed.js`、collections controller / service / repository 中非 AI 的列表查询和数据逻辑 |
| `backend/src/app.js` | 合并两边：保留当前 `/api/ai` 挂载和 GLM 所需 `25mb` body limit；如 `20260522-version` 有其他非 AI app 配置，也要人工并入 |
| `Prompt_library.md`、`Status.md`、`Test.md`、`README.md`、`DOCUMENTATION_STATUS.md` | 两边都要采纳；以 `feature/ai-profile-test` / 当前本地较新版本为主干，人工补入 `20260522-version` 中仍有价值的状态、测试、后端数据库和 UI 记录；不要整文件覆盖 |
| `member_E/backend/src/ai/*`、`member_E/docs/*`、`member_E/scripts/*` | 保留 `feature/ai-profile-test` + 本地 GLM Vision 接入；不要被 `20260522-version` 删除或回退 |
| Add 页、Profile、AI 面板等前端冲突 | 以 `feature/ai-profile-test` 为 base，只人工摘取 `20260522-version` 的明确 UI/交互修复 |
| PNG 路径重命名 | 接受 `20260522-version` 的无前导空格文件名，并同步引用路径 |

---

## 2. 分支策略

### 2.1 准备分支

建议从当前稳定基线创建一个准备分支：

```bash
git fetch --all --prune
git switch feature/ai-profile-test
git pull --ff-only
git switch -c codex/integration-prep
```

如果开始前还有未提交的文档改动，先提交文档整理，或使用 stash 临时保护。不要在有混杂未提交内容时开始迁移后端/前端代码。

当前已知本地未提交但必须保护的内容包括：

- `DOCUMENTATION_STATUS.md`
- `INTEGRATION_IMPLEMENTATION_PATH.md`
- `member_E/backend/src/ai/vision.provider.js`
- `member_E/backend/src/ai/vision.prompts.js`
- `member_E/scripts/verify_glm_vision_live.js`
- `backend/src/app.js` 中 `express.json({ limit: '25mb' })`
- `member_E/backend/src/ai/ai.service.js` / `ai.schemas.js` / `ai.routes.js` 中 `imageDataUrl` 和 GLM fallback 逻辑
- Flutter AI payload/service/panel 中的 `imageDataUrl`

### 2.2 对比而不是直接合并

先只做差异审查：

```bash
git diff --name-status feature/ai-profile-test..feature/member-1-task
git diff --name-status feature/ai-profile-test..20260522-version
```

`feature/member-1-task` 的有效内容应以 rooms API 相关文件为主。不要执行：

```bash
git merge feature/member-1-task
```

除非已经进入最后整合阶段，并且确认删除/覆盖清单全部被处理。

同理，`20260522-version` 也不要作为第一步直接 merge。虽然它只有 1 个独立提交，但会和当前 AI / Profile / 文档产生真实冲突；正确做法是按阶段 1 的清单吸收它的非 AI 后端 / 数据库逻辑，再人工保护 DeepSeek / GLM / `/api/ai`。

### 2.3 最终整合分支

等准备分支通过完整回归后，再从准备分支开最终整合分支：

```bash
git switch codex/integration-prep
git switch -c codex/final-integration
```

最终整合分支只负责收口：解决剩余 branch delta、文档最终口径、截图素材和提交 PR。它不应该再承载大量未知功能开发。

---

## 3. 阶段 0：冻结当前文档和基线

目标：先保证所有人知道当前项目依据是什么，避免一边合分支一边重新解释文档状态。

要做：

1. 确认 `DOCUMENTATION_STATUS.md`、`Status.md`、`Test.md`、`API_Contract.md` 和 `member_E/docs/E_Current_Status_and_Plan.md` 是当前阅读入口。
2. 在准备分支创建后，记录当前基线提交号：

```bash
git rev-parse --short HEAD
git status --short --branch
```

3. 保存分支差异清单，后续每个功能迁移都要能解释“来自哪个分支、迁移了哪些文件、为什么没有直接全合并”。
4. 如果当前工作区仍有 GLM Vision 或文档改动，先独立提交或 stash。不要在这些改动未保护时开始任何 merge / cherry-pick。
5. 文档类文件的处理口径是“合并记录，不是二选一”：主叙述以 `feature/ai-profile-test` 为准，`20260522-version` 的有效进展以追加条目或小段落补入。

阶段验收：

- 文档改动独立提交或独立保留。
- `git status --short` 中没有不明来源的代码改动。
- 已确认 `feature/member-1-task` 不能作为第一步完整 merge。

---

## 4. 阶段 1：以 `20260522-version` 对齐非 AI 后端 / 数据库逻辑

目标：让非 AI 后端逻辑和数据库状态以 `20260522-version` 为准，同时不让它覆盖当前 DeepSeek、GLM Vision、成员 E 状态和现有 `/api/ai` 接入。前端只吸收用户认可的收藏墙 / Gallery / Profile / Room UI 与交互修复。

本阶段明确要采用或吸收的内容：

| 内容 | 处理方式 |
|---|---|
| `backend/data/collections.db` | 采用 `20260522-version` 版本 |
| `backend/src/db/schema.sql` | 采用 `20260522-version` 的非 AI / 数据库结构逻辑；后续接 rooms 时再叠加 room schema |
| `backend/src/db/seed.js` | 采用 `20260522-version` 的 seed / 数据库初始化逻辑；后续接 rooms 时再合并 room seed |
| collections controller / service / repository | 采用 `20260522-version` 的非 AI 后端逻辑，包括 `year` / `month` 查询参数和相关列表过滤；同时保留当前已有 `visibility` 等不冲突能力 |
| `/api/ai`、DeepSeek、GLM Vision | 不取 `20260522-version` 的回退或删除；保留 `feature/ai-profile-test` + 当前本地 GLM 版本 |
| 前端收藏墙 / Gallery / Profile / Room 的 UI 与交互修正 | 以当前 `feature/ai-profile-test` 文件为 base，人工移植明确修复，不做整文件覆盖 |
| `wall_date_filter_row.dart` | 可作为新增组件吸收，用于 year/month 或墙面日期筛选 |
| 设计导出 PNG 路径重命名 | 接受无前导空格文件名，例如 ` Mobile.png` -> `Mobile.png`，并确认所有引用同步 |

优先审查文件：

| 文件 | 迁移判断 |
|---|---|
| `backend/data/collections.db` | **采用 `20260522-version` 版本**；后续回归时确认 seed / API 与该 DB 状态一致 |
| `backend/src/db/schema.sql` | **非 AI 数据库逻辑以 `20260522-version` 为准**；后续 rooms 再叠加 |
| `backend/src/db/seed.js` | **以 `20260522-version` 为准**；如果后续 rooms seed 接入，再人工合并 room 数据 |
| `backend/src/controllers/collections.controller.js` | **非 AI 后端逻辑以 `20260522-version` 为准**，包含 `year` / `month` query 参数 |
| `backend/src/services/collections.service.js` | **非 AI 后端逻辑以 `20260522-version` 为准**，包含 `year` / `month` 参数传递 |
| `backend/src/repositories/collections.repository.js` | **非 AI 后端逻辑以 `20260522-version` 为准**，包含 `date_acquired LIKE` 的 year/month 过滤逻辑 |
| `backend/src/app.js` | 合并而非覆盖：保留 `/api/ai` 和 `25mb` body limit；其他非 AI app 配置如有差异再采用 `20260522-version` |
| `frontend/lib/features/collection_browse/widgets/wall_date_filter_row.dart` | 新增组件，可评估是否放入 Gallery / Wall 过滤区 |
| `frontend/lib/features/collection_browse/providers/collection_list_provider.dart` | 只摘取分页、日期筛选或状态修复，不覆盖当前已跑通逻辑 |
| `frontend/lib/features/collection_browse/widgets/collection_wall_slivers.dart` | 只摘取 UI/交互修复 |
| `frontend/lib/features/collection_browse/pages/design_gallery_page.dart` | 重点看 Room 芯片、墙面筛选和导航变化 |
| `frontend/lib/features/collection_browse/pages/collection_room_page.dart` | 只保留能和真实 rooms API 对齐的部分 |
| `frontend/lib/features/collection_browse/providers/app_navigation_provider.dart` | 检查是否影响 Room 页参数传递 |
| `frontend/lib/features/collection_browse/utils/profile_exhibit_utils.dart` | 保留成员 E Profile 联调逻辑，谨慎迁移 |
| `frontend/lib/features/collection_browse/widgets/profile_collection_preview.dart` | 未来要从 `/api/rooms` 读真实数据，避免继续硬编码 |
| `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart` | 只摘取必要交互修复，不能丢失 DeepSeek / image analysis 支持 |
| `frontend/lib/features/profile/pages/profile_page.dart`、`profile_stats.dart` | 检查是否是布局修复 |
| `frontend/web/index.html` | 可迁移加载页文案/样式，但要跑 Flutter build |

设计稿路径重命名也可以吸收，例如把 ` Mobile.png` 修正为 `Mobile.png`。这类变更风险低，但要确认文档和截图脚本引用路径同步。

冲突处理细则：

| 冲突文件 | 处理方式 |
|---|---|
| `backend/data/collections.db` | 取 `20260522-version` |
| `backend/src/db/schema.sql`、`backend/src/db/seed.js` | 取 `20260522-version` 的非 AI 数据库逻辑；后续 rooms 作为下一阶段叠加 |
| `backend/src/controllers/collections.controller.js`、`backend/src/services/collections.service.js`、`backend/src/repositories/collections.repository.js` | 取 `20260522-version` 的非 AI 后端逻辑；确认不要意外删除当前仍需要的字段转换或 `visibility` 能力 |
| `backend/src/app.js` | 手动合并：保留 `/api/ai`、25MB body limit、uploads/static 等当前能力，同时吸收 `20260522-version` 的非 AI 配置 |
| `Prompt_library.md`、`Status.md`、`Test.md`、`README.md`、`DOCUMENTATION_STATUS.md` | 以当前 `feature/ai-profile-test` / 本地版本为主干，同时人工补入 `20260522-version` 中仍有价值的状态、测试和决策记录 |
| `member_E/backend/src/ai/ai.provider.js`、`ai.schemas.js`、`ai.service.js`、`ai.routes.js` | 取当前 `feature/ai-profile-test` + 本地 GLM Vision 版本 |
| `member_E/docs/AI_Provider_Setup.md`、`AI_API_Contract.md`、`AI_Routes_Integration.md` | 取当前本地更新版本，确保 DeepSeek + GLM Vision 都保留 |
| `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart` | 以当前版本为 base，保留 `imageDataUrl` / Recognize / story style，再人工摘取 UI 小修 |
| `frontend/lib/features/profile/*` | 以当前成员 E Profile 版本为 base，只摘取视觉或布局修复 |

不要迁移：

- 删除 `member_E/docs/E_Current_Status_and_Plan.md`、`E_Technical_Route_Map.md`、DeepSeek 测试计划和 live 测试脚本的变更。
- 删除 `backend/.gitignore` 的变更。
- 回退或删除 GLM Vision 接入文件、`imageDataUrl` 合同、25MB body limit。

阶段验收：

- Flutter 静态检查或至少 `flutter test` 能跑通。
- Add Demo、Gallery、Profile、Room 入口没有视觉级崩溃。
- 后端 `GET /api/collections?year=2026&month=5` 这类查询可用。
- `backend/data/collections.db` 确认为 `20260522-version` 版本。
- 非 AI 后端逻辑和数据库初始化逻辑已按 `20260522-version` 对齐。
- `Status.md`、`Test.md`、`Prompt_library.md` 等文档已同时吸收两边有效记录；主口径仍以较新的 `feature/ai-profile-test` 为准。
- 没有破坏当前 `/api/ai/*`、DeepSeek 文档和 GLM Vision 接入。

---

## 5. 阶段 2：局部接入成员 A rooms API

目标：把成员 A 的 rooms 后端能力迁入当前基线，但只迁移必要后端代码，不完整合并 `feature/member-1-task`。

### 5.1 后端文件迁移范围

建议从 `feature/member-1-task` 手动读取并迁移这些内容：

| 文件 | 动作 |
|---|---|
| `backend/src/controllers/rooms.controller.js` | 新增，保留 `listRooms` / `getRoom` |
| `backend/src/routes/rooms.routes.js` | 新增，挂载 `GET /` 和 `GET /:id` |
| `backend/src/services/rooms.service.js` | 新增，但要按当前 collections 字段转换规则补强 |
| `backend/src/repositories/rooms.repository.js` | 新增，建议改成当前 repository 风格，避免拼接 SQL 习惯扩散 |
| `backend/src/db/schema.sql` | 只加入 `rooms` 表和 `collections.room_id` 迁移 |
| `backend/src/db/seed.js` | 加入 rooms seed 和收藏 room_id 分配 |
| `backend/src/app.js` | 只新增 `app.use('/api/rooms', roomsRoutes)`；保留 `/api/ai` |
| `backend/src/routes/collections.routes.js` | create/update schema 增加 `roomId` |
| `backend/src/services/collections.service.js` | FIELD_MAP 增加 `roomId -> room_id` |
| `backend/src/repositories/collections.repository.js` | insert/update/select 字段增加 `room_id` |

不要直接迁移：

- `backend/data/collections.db`，除非 seed 和自动化测试已经验证。
- 删除 `backend/src/routes/ai.routes.js` 的分支变更。
- 删除上传 seed 图片或前端目录的分支变更。

### 5.2 后端合同形态

`rooms` 表建议保持简单：

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | INTEGER | room 主键 |
| `month` | TEXT | `YYYY-MM`，例如 `2026-05` |
| `label` | TEXT | 展示名称，例如 `May Room` 或 `ROOM 01` |
| `created_at` | TEXT | 创建时间 |

`collections` 增加：

| 字段 | 类型 | 说明 |
|---|---|---|
| `room_id` | INTEGER | 指向 `rooms.id`，API 层暴露为 `roomId` |

后端响应建议：

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "month": "2026-05",
      "label": "May Room",
      "createdAt": "2026-05-22 10:00:00"
    }
  ]
}
```

```json
{
  "success": true,
  "data": {
    "id": 1,
    "month": "2026-05",
    "label": "May Room",
    "createdAt": "2026-05-22 10:00:00",
    "collections": [
      {
        "id": 14,
        "title": "Brass ticket from Kyoto",
        "category": "ticket",
        "tags": ["Tickets"],
        "roomId": 1
      }
    ]
  }
}
```

### 5.3 后端实现细节

`collections` 的 create/update 请求体需要接受：

```json
{
  "title": "Blue crystal",
  "category": "crystal",
  "roomId": 1
}
```

建议规则：

- `roomId` 是 optional。
- 如果传入 `roomId`，后端应验证它存在；不存在返回 400 或 404，错误码建议 `ROOM_NOT_FOUND`。
- 如果不传 `roomId`，先不做自动推断，避免根据 `dateAcquired` 自动分房导致用户不清楚结果。
- seed 数据必须给现有 15 条收藏分配 room，保证 Gallery/Profile/Room 能展示真实数据。
- `GET /api/collections` 和 `GET /api/collections/:id` 都返回 `roomId`。
- `GET /api/rooms/:id` 返回 room 下的 collections，用于 Room 页真实数据。

后端基础验证命令：

```bash
cd backend
npm install
npm run seed
npm run dev
```

另开终端验证：

```bash
curl http://localhost:3000/api/health
curl http://localhost:3000/api/rooms
curl http://localhost:3000/api/rooms/1
curl http://localhost:3000/api/collections?page=1&pageSize=3
```

阶段验收：

- `/api/rooms` 可返回 room 列表。
- `/api/rooms/:id` 可返回 room + collections。
- `POST /api/collections` 可保存 `roomId`。
- `PUT /api/collections/:id` 可更新 `roomId`。
- 现有 `/api/ai/*`、`/api/categories`、`/api/users/:id/stats` 不被破坏。

---

## 6. 阶段 3：当前前端接入真实 rooms 数据

目标：收藏模型加 `roomId`，Add/Edit 保存 room，Gallery/Profile/Room 页从 `/api/rooms` 读真实数据。

### 6.1 模型层

修改 `frontend/lib/features/collection_browse/models/collection_item.dart`：

- `CollectionItem` 增加 `final int? roomId;`
- 构造函数加入 `this.roomId`
- `fromJson` 支持 `roomId` 和 `room_id`

建议新增 room 模型，例如：

```dart
class CollectionRoomSummary {
  const CollectionRoomSummary({
    required this.id,
    required this.month,
    this.label,
    this.createdAt,
  });

  final int id;
  final String month;
  final String? label;
  final String? createdAt;
}

class CollectionRoomDetail extends CollectionRoomSummary {
  const CollectionRoomDetail({
    required super.id,
    required super.month,
    super.label,
    super.createdAt,
    this.collections = const [],
  });

  final List<CollectionItem> collections;
}
```

建议文件位置：

```text
frontend/lib/features/collection_browse/models/collection_room.dart
```

### 6.2 Service 层

修改 `frontend/lib/features/collection_browse/services/collection_query_service.dart`：

- 新增 `fetchRooms()`
- 新增 `fetchRoomById(int id)`
- `createCollection` 参数增加 `int? roomId`
- `updateCollection` 参数增加 `int? roomId`
- 创建和更新请求体中写入 `roomId`

示例：

```dart
Future<List<CollectionRoomSummary>> fetchRooms() async {
  final data = await _api.get<List<dynamic>>('/api/rooms');
  return data
      .map((e) => CollectionRoomSummary.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<CollectionRoomDetail> fetchRoomById(int id) async {
  final data = await _api.get<Map<String, dynamic>>('/api/rooms/$id');
  return CollectionRoomDetail.fromJson(data);
}
```

### 6.3 Provider 层

建议新增：

```dart
final roomsProvider = FutureProvider<List<CollectionRoomSummary>>((ref) async {
  return ref.read(collectionQueryServiceProvider).fetchRooms();
});

final roomDetailProvider =
    FutureProvider.family<CollectionRoomDetail, int>((ref, roomId) async {
  return ref.read(collectionQueryServiceProvider).fetchRoomById(roomId);
});

final selectedRoomIdProvider = StateProvider<int?>((ref) => null);
```

现有 `collectionRoomIndexProvider` 可以先保留，用作旧 UI 的 fallback；新路径应逐步改为 `roomId`。

### 6.4 Gallery / Profile / Room 页

Gallery：

- Room chips 从 `roomsProvider` 读取。
- 点击 chip 时传 `roomId`，不是传静态 index。
- 如果 `/api/rooms` 失败，才 fallback 到 `collectory_room_catalog.dart`，保证 Demo 不因后端临时没启动而完全空白。

Profile：

- Room 卡片从 `roomsProvider` 读取最近 3 个 room。
- 每张卡显示 room label、month、collection count。
- collection count 可以来自 `/api/rooms/:id.collections.length`，或后端后续在 `/api/rooms` summary 增加 `collectionCount`。如果不想多次请求，建议后端 list rooms 直接返回 `collectionCount`。

Room 页：

- `CollectionRoomPage` 接收 `roomId`。
- 页面数据从 `roomDetailProvider(roomId)` 读取。
- Highlights / Timeline / Wall 使用 `room.collections`。
- 保留旧静态文案作为 loading/error fallback，不作为真实数据源。

导航：

- `openCollectionRoom(ref, roomId: id, source: ...)`
- `app_navigation_provider.dart` 的 route state 增加 `roomId`。
- `AnimatedSwitcher` key 使用 `roomId`，避免不同 room 之间切换不刷新。

### 6.5 Add / Edit 保存 room

Add：

- 正式表单应包含 room 选择器，数据来自 `roomsProvider`。
- 默认选中最近 room 或第一个 room。
- Save 调用 `createCollection(roomId: selectedRoomId, ...)`。

Edit：

- 初始值使用 `item.roomId`。
- 用户改 room 后调用 `updateCollection(id, roomId: selectedRoomId, ...)`。
- 保存成功后 invalidate：

```dart
ref.invalidate(collectionListProvider);
ref.invalidate(roomsProvider);
ref.invalidate(roomDetailProvider);
```

如果 Riverpod family 不能直接批量 invalidate，就在保存后 invalidate 当前 `roomDetailProvider(oldRoomId)` 和 `roomDetailProvider(newRoomId)`。

阶段验收：

- 新建收藏后，刷新 Gallery/Room，该收藏出现在所选 room。
- 编辑收藏改 room 后，旧 room 不再显示，新 room 显示。
- Profile 的 room 卡片不再只读 `collectory_room_catalog.dart`。
- 后端没启动时，Demo 有可理解的 fallback，不是白屏。

---

## 7. 阶段 4：成员 B 正式创建表单整合

目标：把当前 Add Demo 页里的 AI 面板迁入正式 Create flow。标签建议必须写入正式 Tag input，不再只是 SnackBar。

### 7.1 现状

当前 `AiSuggestionPanel` 已能调用：

- `POST /api/ai/suggest-title`
- `POST /api/ai/suggest-category`
- `POST /api/ai/suggest-tags`
- `POST /api/ai/generate-story`
- `POST /api/ai/analyze-image`

当前问题：

- 它主要挂在 `add_exhibit_design_page.dart` 的 Demo flow。
- `onTagsSuggested` 只是显示 SnackBar / pending note，没有进入正式 tag input。
- 正式 Create flow 的表单状态、校验、图片上传和保存闭环还需要统一。

### 7.2 建议目录结构

如果成员 B 正式表单还没有完整落地，建议按下面结构补齐：

```text
frontend/lib/features/collection_form/
├── models/
│   ├── ai_form_payload.dart
│   ├── ai_image_analysis.dart
│   └── collection_form_state.dart
├── providers/
│   └── collection_form_provider.dart
├── widgets/
│   ├── ai_suggestion_panel.dart
│   ├── category_selector.dart
│   ├── collection_form.dart
│   ├── image_picker_field.dart
│   ├── room_selector.dart
│   └── tag_input_field.dart
└── pages/
    └── create_collection_page.dart
```

### 7.3 表单状态

`CollectionFormState` 建议包含：

```dart
class CollectionFormState {
  const CollectionFormState({
    this.title = '',
    this.category,
    this.dateAcquired,
    this.location = '',
    this.story = '',
    this.tags = const [],
    this.visibility = 'private',
    this.roomId,
    this.imageBytes,
    this.imageFilename,
    this.customFields = const {},
    this.isSaving = false,
  });

  final String title;
  final String? category;
  final String? dateAcquired;
  final String location;
  final String story;
  final List<String> tags;
  final String visibility;
  final int? roomId;
  final List<int>? imageBytes;
  final String? imageFilename;
  final Map<String, String> customFields;
  final bool isSaving;
}
```

Tag input 行为：

- `addTag(String tag)` 去空格。
- 大小写或中文空格规范化。
- 去重。
- 建议最多 10 个 tag。
- AI tags 通过 `mergeTags(List<String>)` 写入同一个状态。

### 7.4 AI 面板迁入正式 flow

`AiSuggestionPanel` 的 callbacks 应改成真实写表单状态：

| AI 输出 | 写入位置 |
|---|---|
| titles | 点击某个 title 后写入 `title` field |
| category | 通过中文类别映射成 slug，写入 category selector |
| tags | 调用 `mergeTags(tags)` 写入正式 Tag input |
| story | 写入 story textarea |
| analyze-image | 同时写入 title/category/tags/story；保留用户可编辑 |
| story style | 仍作为 `generate-story` 参数，不直接影响保存字段 |

`onTagsSuggested` 不应该只是：

```dart
ScaffoldMessenger.of(context).showSnackBar(...)
```

而应该先更新正式状态，再用 SnackBar 做轻提示：

```dart
onTagsSuggested: (tags) {
  ref.read(collectionFormProvider.notifier).mergeTags(tags);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tags added: ${tags.join(', ')}')),
  );
}
```

### 7.5 保存流程

保存按钮逻辑：

1. 校验 title 必填。
2. 校验 roomId 已选择；如果允许无 room，则 UI 要明确显示“未分配 room”。
3. 调用 `createCollection`：

```dart
final created = await service.createCollection(
  title: state.title,
  category: state.category,
  story: state.story,
  visibility: state.visibility,
  tags: state.tags,
  userId: demoUserId,
  roomId: state.roomId,
);
```

4. 如果有图片，再调用：

```dart
await service.uploadCollectionImage(
  created.id,
  bytes: state.imageBytes!,
  filename: state.imageFilename!,
);
```

5. 保存成功后 invalidate collection list、rooms、profile stats，并跳转到详情页或 room 页。
6. 如果图片上传失败，但 collection 创建成功，应提示“收藏已保存，图片上传失败可稍后编辑”，不能直接把整个保存当失败。
7. AI 失败永远不能阻塞手动保存。

阶段验收：

- 正式 Create 页能创建收藏。
- AI tags 会出现在正式 Tag input。
- 选择 room 后保存，后端 `roomId` 可查。
- 图片上传失败时，文本收藏仍可保存。
- Add Tab 最终指向正式 Create flow；旧 Demo Add 页可以保留为手测入口，但不再作为主入口。

---

## 8. 阶段 5：确认并保护 GLM 图片理解接入（已完成）

状态：GLM 图片理解已经完成本地接入。下一位 AI 不应把它当成未完成任务重做；本阶段的任务是保护这些改动、确认它们进入整合分支，并在合并后复测。

目标：保持 `POST /api/ai/analyze-image` 已从“图片描述文本 + DeepSeek 文本推断”升级为“真实图片理解”。文字生成继续由 DeepSeek/OpenAI-compatible provider 负责；图片理解使用智谱 GLM Vision provider，避免把多模态逻辑塞进现有 `ai.provider.js`。

本阶段只负责图片理解，不做图片生成。图片生成不是当前 Recognize 功能的必需能力。

### 8.1 已验证结论

| 项 | 结论 |
|---|---|
| 项目图片来源 | 仓库内已有真实图片，可用 `frontend/assets/screens/add_exhibit.png` 做 live test |
| 此前普通多模态尝试 | 文本调用可用，但同一张图片以 data URL/base64 传入时模型仍回答“没有看到图片”；不作为项目 Vision provider |
| GLM `glm-4.6v-flash` | 接口可达，但实测返回 429“访问量过大”；暂不作为默认模型 |
| GLM `glm-4v-flash` | 实测通过，data URL 和 raw base64 都能正确识别同一张图片 |
| 当前选择 | 已正式接入 `VISION_PROVIDER=glm` + `ZHIPU_VISION_MODEL=glm-4v-flash` |

参考资料：

| 来源 | 用途 |
|---|---|
| `https://docs.bigmodel.cn/cn/guide/models/free/glm-4v-flash` | GLM-4V-Flash 图片理解模型说明 |
| `https://docs.bigmodel.cn/cn/guide/models/free/glm-4.6v-flash` | GLM-4.6V-Flash 备用模型说明；当前实测拥挤 |

### 8.2 推荐架构

保留 DeepSeek 文本链路：

```text
suggest-title / suggest-category / suggest-tags / generate-story
  -> ai.service.js
  -> ai.provider.js
  -> DeepSeek OpenAI-compatible API
```

已新增 GLM Vision 链路，只接 `analyze-image`：

```text
POST /api/ai/analyze-image
  -> ai.routes.js
  -> ai.service.js
  -> vision.provider.js
  -> GLM chat/completions image_url
```

前端仍然只调用一个旧接口：

```text
POST /api/ai/analyze-image
```

### 8.3 环境变量

真实配置写入 `backend/.env`，不要提交该文件。

```env
VISION_PROVIDER=glm
ZHIPU_API_KEY=你的智谱_API_Key
ZHIPU_API_BASE_URL=https://open.bigmodel.cn/api/paas/v4
ZHIPU_VISION_MODEL=glm-4v-flash
ZHIPU_VISION_TIMEOUT_MS=45000
ZHIPU_VISION_MAX_IMAGE_BYTES=20971520
```

`glm-4v-flash` 是当前实测通过的默认模型；`glm-4.6v-flash` 可以作为后续重试模型，但不要在当前演示默认使用。

`member_E/.env.example` 只写占位符，不出现真实 key。

### 8.4 输入合同

`analyze-image` 支持以下请求体：

```json
{
  "imageDataUrl": "data:image/png;base64,...",
  "imageUrl": "https://example.com/image.jpg",
  "imageDescription": "可选：用户补充说明",
  "language": "zh-CN"
}
```

字段规则：

| 字段 | 是否必需 | 说明 |
|---|---|---|
| `imageDataUrl` | 三选一 | 前端本地选图后转成 data URL；本地 Demo 首选 |
| `imageUrl` | 三选一 | 必须是公网 HTTP/HTTPS URL；不要传 localhost URL |
| `imageDescription` | 三选一 / 可选补充 | 无真实图片时走 DeepSeek 文本 fallback；有真实图片时作为补充上下文 |
| `language` | 否 | 默认 `zh-CN` |

推荐前端主路径：Flutter 选图后转 `imageDataUrl`，直接发给后端 `analyze-image`。

### 8.5 输出合同

保持现有 `AiImageAnalysis` 不变，避免前端和成员 B 正式表单大改：

```json
{
  "suggestedTitle": "复古展览票根",
  "suggestedCategory": "票根",
  "suggestedTags": ["展览", "票根", "复古"],
  "description": "这看起来像一张展览或活动票根。"
}
```

可选增强字段不要变成必需字段，避免破坏现有测试。

### 8.6 已完成 / 需保护的文件改动清单

新增文件，合并时必须保留：

```text
member_E/backend/src/ai/vision.provider.js
member_E/backend/src/ai/vision.prompts.js
member_E/scripts/verify_glm_vision_live.js
```

已修改文件，合并时必须保留相关逻辑：

```text
backend/src/app.js
member_E/backend/src/ai/ai.routes.js
member_E/backend/src/ai/ai.service.js
member_E/backend/src/ai/ai.schemas.js
member_E/.env.example
member_E/docs/AI_API_Contract.md
member_E/docs/AI_Routes_Integration.md
member_E/docs/AI_Provider_Setup.md
member_E/docs/prompts/prompt_image.md
member_E/E_Test_Log.md
Test.md
```

`backend/src/app.js` 已需要并应继续支持 data URL body：

```js
app.use(express.json({ limit: '25mb' }));
app.use(express.urlencoded({ extended: true, limit: '25mb' }));
```

### 8.7 `vision.provider.js` 规则

Provider 职责：

1. 读取 `VISION_PROVIDER`、`ZHIPU_API_KEY`、`ZHIPU_API_BASE_URL`、`ZHIPU_VISION_MODEL`、timeout。
2. 只在 `VISION_PROVIDER=glm` 时启用。
3. 接受 `imageDataUrl` 或公网 `imageUrl`。
4. data URL 只允许 JPEG / PNG / GIF / WebP，默认最大 20MB。
5. 调用 `/chat/completions`，用 OpenAI-compatible content parts 传 `image_url` + text prompt。
6. 使用 `parseModelJson()` 解析模型文本。
7. 用 `validateAnalyzeImageResponse()` 校验输出。
8. 失败时抛出 `VisionProviderError`，由 `ai.service.js` 决定是否 fallback。

### 8.8 `ai.service.js` 策略

| 输入 / 配置 | 行为 |
|---|---|
| `VISION_PROVIDER=glm` 且有 `imageDataUrl` 或公网 `imageUrl` | 调 GLM Vision |
| GLM 成功 | 返回真实图片理解 JSON |
| GLM 失败且有 `imageDescription` | fallback 到旧 DeepSeek 文本推断 |
| GLM 失败且没有 `imageDescription` | 返回 502，不阻塞用户手动保存 |
| 无真实图片 | 保持旧逻辑，走 `buildAnalyzeImagePrompt()` + DeepSeek/mock |

### 8.9 Flutter 前端改动

当前前端已支持 `imageDataUrl` 字段，正式表单接入时继续遵守：

1. `AiFormPayload` 包含 `imageDataUrl`。
2. `ai_suggestion_service.dart` 的 `analyzeImage()` 请求体传 `imageDataUrl`。
3. Add / Create 页真实选图后把图片 bytes 转成 data URL。
4. Recognize 优先传 `imageDataUrl`，没有真实图片时才传 `imageDescription` fallback。
5. AI 返回后仍写入现有字段：title / category / tags / story note。

Dart data URL 示例：

```dart
import 'dart:convert';

String imageBytesToDataUrl(List<int> bytes, String mimeType) {
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}
```

### 8.10 测试脚本

GLM live 测试：

```bash
node member_E/scripts/verify_glm_vision_live.js frontend/assets/screens/add_exhibit.png
```

HTTP live 测试：

```bash
cd backend
npm run dev
```

另开终端：

```bash
node -e "
const fs=require('fs');
const path=process.argv[1];
const ext=path.endsWith('.png')?'png':'jpeg';
const body={
  imageDataUrl:'data:image/'+ext+';base64,'+fs.readFileSync(path).toString('base64'),
  imageDescription:'本地测试图片，请识别收藏品类别',
  language:'zh-CN'
};
fetch('http://127.0.0.1:3000/api/ai/analyze-image',{
  method:'POST',
  headers:{'content-type':'application/json'},
  body:JSON.stringify(body)
}).then(r=>r.json()).then(j=>console.log(JSON.stringify(j,null,2))).catch(e=>{console.error(e);process.exit(1);});
" ../frontend/assets/screens/add_exhibit.png
```

回归命令：

```bash
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
cd frontend && flutter test
```

### 8.11 验收标准 / 合并保护标准

| 验收项 | 标准 |
|---|---|
| Env 安全 | `backend/.env` 不进入 git；文档只出现占位符 |
| Provider | `vision.provider.js` 能用 GLM key 调通真实图片理解 |
| Schema | 输出满足 `suggestedTitle/suggestedCategory/suggestedTags/description` |
| HTTP | `POST /api/ai/analyze-image` 支持 `imageDataUrl` 并返回 `success: true` |
| Fallback | 无真实图片或 GLM 失败时，仍能用 `imageDescription` fallback 或提示手动填写 |
| Frontend | Upload / Pick image -> Recognize -> 自动回填标题、分类、标签、描述 |
| 回归 | DeepSeek 文本接口、收藏创建、Gallery/Profile 基础路径不回归 |
| 日志 | 不打印完整 API key，不打印完整 base64 |
| 合并保护 | `20260522-version` 或 `feature/member-1-task` 不能删除 `vision.provider.js`、`vision.prompts.js`、`verify_glm_vision_live.js`，不能回退 `imageDataUrl` 合同 |

### 8.12 常见问题

| 问题 | 排查方向 |
|---|---|
| 401 / invalid api key | 检查 `ZHIPU_API_KEY` 是否放在 `backend/.env`，且没有被引号或空格污染 |
| 429 访问量过大 | 当前先用 `glm-4v-flash`；`glm-4.6v-flash` 拥挤时不要作为默认模型 |
| 413 / request entity too large | `express.json()` limit 太小，改为 `25mb` |
| 模型访问不到图片 | 本地 Demo 用 `imageDataUrl`；不要传 `localhost` URL |
| 返回自然语言不是 JSON | 强化 `vision.prompts.js`，并复用 `parseModelJson()` |
| 分类不在集合内 | 不放宽 schema，先改 prompt；必要时做中文类别归一化 |
| 费用/额度消耗太快 | live 测试只跑 1-2 张小图；不要把 Vision live 放进每次普通回归 |

### 8.13 给新 AI 的执行 Prompt

```text
我是成员 E / 成员 5。GLM 图片理解接入已经完成，请你只测试、保护和维护这条链路，不要把它当作未完成任务重做，不要恢复旧的非 GLM 图片方案，不要重构 DeepSeek 文本 provider，不要改无关成员模块。

当前项目路径是 /Users/jing/Desktop/some_code/GenAI_Coding/GenAI_in_Business，当前协作分支应为 feature/ai-profile-test。开始前请先阅读 README.md、DOCUMENTATION_STATUS.md、Status.md、Test.md、INTEGRATION_IMPLEMENTATION_PATH.md 的“阶段 5：确认并保护 GLM 图片理解接入（已完成）”、member_E/docs/AI_Provider_Setup.md、member_E/docs/AI_API_Contract.md、member_E/backend/src/ai/vision.provider.js、member_E/backend/src/ai/ai.service.js、frontend/lib/features/collection_form/services/ai_suggestion_service.dart。

任务目标：确认并保护 POST /api/ai/analyze-image 能用 GLM 真实识别 imageDataUrl，并在 GLM 失败时保留 imageDescription + DeepSeek 文本 fallback。

backend/.env 中应提供：
VISION_PROVIDER=glm
ZHIPU_API_KEY=我的智谱 API Key
ZHIPU_API_BASE_URL=https://open.bigmodel.cn/api/paas/v4
ZHIPU_VISION_MODEL=glm-4v-flash
ZHIPU_VISION_TIMEOUT_MS=45000

需要测试：
1. node member_E/scripts/verify_glm_vision_live.js frontend/assets/screens/add_exhibit.png
2. /api/ai/analyze-image HTTP live：imageDataUrl + imageDescription
3. /api/ai/analyze-image fallback：只有 imageDescription
4. 成员 E 旧回归脚本
5. flutter test

注意：不要打印完整 API key，不要打印完整 base64，不要提交 backend/.env。
```

## 9. 阶段 6：更新并冻结新版 API Contract

目标：等 rooms、roomId、正式表单实际字段稳定后，更新根目录 `API_Contract.md`，把它作为统一整合后的接口依据。

必须新增或确认：

1. `Collection` 字段增加 `roomId`。
2. `POST /api/collections` 请求体增加 `roomId`。
3. `PUT /api/collections/:id` 请求体增加 `roomId`。
4. `GET /api/collections` 和 `GET /api/collections/:id` 响应增加 `roomId`。
5. 新增 `GET /api/rooms`。
6. 新增 `GET /api/rooms/:id`。
7. room 字段：`id`、`month`、`label`、`createdAt`，如实现了 `collectionCount` 也要写入。
8. 正式 Create flow 最终使用字段：
   - `title`
   - `category`
   - `dateAcquired`
   - `location`
   - `story`
   - `tags`
   - `visibility`
   - `categoryTemplate`
   - `customFields`
   - `roomId`
   - 图片 multipart 字段 `image`
9. AI 端点最终合同：
   - `suggest-title`
   - `suggest-category`
   - `suggest-tags`
   - `generate-story`
   - `analyze-image`
10. GLM 图片理解输出 schema 已在阶段 5 写入；后续只需随最终 API Contract 同步。

冻结标准：

- 前端实际 payload 和 `API_Contract.md` 一致。
- 后端 zod schema / service FIELD_MAP 和 `API_Contract.md` 一致。
- `member_E/docs/AI_API_Contract.md` 与根目录合同不冲突。
- `Test.md` 中记录新版合同的验证结果。

---

## 10. 阶段 7：完整回归

目标：在完全合并前，先证明“局部整合后的准备分支”已经能跑。

### 10.1 后端 API 回归

后端启动：

```bash
cd backend
npm install
npm run seed
npm run dev
```

基础检查：

```bash
curl http://localhost:3000/api/health
curl http://localhost:3000/api/categories
curl http://localhost:3000/api/users/1/stats
curl http://localhost:3000/api/rooms
curl http://localhost:3000/api/rooms/1
```

成员 E 脚本：

```bash
node member_E/scripts/verify_phase1_task1_title.js
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
```

如果使用真实 DeepSeek：

```bash
node member_E/scripts/verify_deepseek_provider_live.js
```

真实 key 只放本地 `.env`，不要写入文档或提交。

### 10.2 Flutter 回归

```bash
cd frontend
flutter pub get
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://localhost:3000
```

手动 Demo 路径：

1. Home 能进入 Gallery。
2. Gallery 能看到真实 rooms。
3. 点击 room chip 进入真实 Room 页。
4. Add / Create 选择 room、用 AI 建议 tags、保存。
5. 保存后进入对应 Room 能看到新收藏。
6. Edit 修改 room，旧 room 消失、新 room 出现。
7. Profile room 卡片读取真实 rooms。
8. Share / Preview 原路径不坏。
9. AI 失败时手动保存仍可用。
10. 后端临时关闭时，前端 fallback 不白屏。

### 10.3 成员 6 素材

需要补截图：

| 素材 | 用途 |
|---|---|
| Gallery 真实 rooms | PPT 展示“按月份/房间组织收藏” |
| Room 页真实数据 | 报告展示后端 API 联动 |
| Create 正式表单 + AI tags 写入 | 展示成员 B + 成员 E 整合 |
| Edit 修改 room | 展示完整管理闭环 |
| Profile rooms + stats | 展示用户主页 |
| AI 面板 / GLM 图片理解最终效果 | 最终 Demo 前补截图 |

---

## 11. 阶段 8：最后才做完全整合

目标：局部功能都通过后，再把分支口径收成一个统一分支。

最后整合动作：

1. 从准备分支创建 `codex/final-integration`。
2. 重新对比：

```bash
git diff --name-status codex/final-integration..feature/member-1-task
git diff --name-status codex/final-integration..20260522-version
```

3. 对剩余差异逐项分类：
   - 已手动迁移，忽略。
   - 文档旧口径，若已被 `feature/ai-profile-test` 新记录覆盖则不迁移；若包含仍有用的状态、测试或后端数据库说明，则人工补入。
   - `20260522-version` 的 `backend/data/collections.db` 已按阶段 1 采用，不再回退。
   - 其他分支的二进制数据库一般不直接采用，优先通过 schema + seed 重建。
   - 仍有价值，继续手动迁移。
   - 必须团队确认。
4. 如果需要执行 `git merge`，先确认不会删除当前 `frontend/`、`member_E/` 和 AI 路由。
5. 完成后跑阶段 7 的完整回归。
6. 更新并冻结：
   - `Status.md`
   - `Test.md`
   - `API_Contract.md`
   - `DOCUMENTATION_STATUS.md`
   - `member_E/docs/Member6_Demo_Handoff.md`
   - `frontend/demo-screenshots/README.md`

最后整合通过标准：

- 当前主 Demo 路径全部可跑。
- `feature/member-1-task` 的 rooms 有效内容已经进入统一分支。
- `20260522-version` 的非 AI 后端 / 数据库逻辑已经成为统一分支依据。
- `20260522-version` 的有效 UI/体验内容已经进入统一分支或有明确“不迁移”理由。
- 没有误删当前成员 E AI / DeepSeek / GLM 文档和脚本。
- 成员 6 可以直接按最终 handoff 做 PPT、报告和视频。

---

## 12. 暂未完成清单

这些内容不要因为写了路线就标记完成：

| 事项 | 当前状态 | 完成条件 |
|---|---|---|
| 完全整合 `feature/member-1-task` | 暂不直接合并 | rooms API 局部迁移和回归通过后，最终分支处理剩余差异 |
| 完全整合 `20260522-version` | 暂不直接合并 | 非 AI 后端 / 数据库逻辑已按该分支对齐；有效 UI/体验内容逐项迁移或明确放弃；DeepSeek / GLM 未被覆盖 |
| rooms API 接入当前前端 | 待开发 | Gallery/Profile/Room/Add/Edit 都使用真实 `roomId` / `/api/rooms` |
| 成员 B 正式 Create flow | 待开发 | AI 面板进入正式表单，tags 写入 Tag input，保存完整字段 |
| GLM 图片理解 | 已完成接入，合并时保护 | `vision.provider.js`、`vision.prompts.js`、`verify_glm_vision_live.js`、`imageDataUrl` 合同和 25MB body limit 均保留；最终以 live/HTTP/Flutter 回归确认 |
| 新版 API Contract 冻结 | 待 rooms/Form/GLM Vision 稳定 | `API_Contract.md` 与后端 schema、前端 payload 一致 |
| 完整回归 | 待实现后执行 | 后端 API、Flutter release build、手动 Demo、成员 6 截图均通过 |
| 最终文档口径清理 | 待最终整合后执行 | `Status.md`、`Test.md`、成员 6 handoff 全部改为统一整合后的结论 |

---

## 13. 执行时不要做的事

1. 不要把 `feature/member-1-task` 作为第一步完整 merge。
2. 不要让任何分支删除当前 `frontend/`、`member_B/`、`member_E/` 的有效内容。
3. 不要删除 `/api/ai` 路由挂载、DeepSeek provider、GLM Vision provider 和测试文档。
4. 不要把“保护 AI 设计”误解成保留 `feature/ai-profile-test` 的所有后端逻辑；非 AI 后端 / 数据库逻辑应以 `20260522-version` 为准。
5. 不要直接采用 `feature/member-1-task` 或其他后续分支里的 `backend/data/collections.db`；只有 `20260522-version` 的数据库文件是本轮明确要保留的数据库状态。
6. 不要把 `collectory_room_catalog.dart` 当成最终数据源；它只能作为 fallback 或设计元数据。
7. 不要让 AI tags 继续只停留在 SnackBar；正式 Create flow 必须写入表单状态。
8. 不要为图片理解大改前端外部合同；先保留现有 `analyze-image` 接口。
