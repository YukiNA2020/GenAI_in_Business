# Post-MVP Issues - 待处理问题记录

> 上次更新：2026-05-26
> 记录人：成员 E
> 用途：记录 MVP 整合后发现的新问题，不混入 Test.md / Status.md 等已有文档

---

## 问题 1：Room Reflection Redo 按钮无功能

### 概述

Room 页面（Collection Room Page）的「AI ROOM REFLECTION」卡片中包含一个 **Redo** 按钮，点击后无任何反应。

### 现状

| 组件 | 文件 | 现状 |
|------|------|------|
| `_AiReflectionCard` | `frontend/lib/features/collection_browse/pages/collection_room_page.dart:446` | `onPressed: () {}` 为空实现 |
| Reflection 内容 | `frontend/lib/features/collection_browse/utils/collectory_room_catalog.dart:77` | 硬编码静态字符串，非 AI 生成 |

**当前行为（2026-05-26 确认）：**

- Reflection 显示的内容来自 `CollectoryRoomSpec.reflection`（写死的英文描述）
- Redo 按钮的 `onPressed` 是空函数 `() {}`，点击不触发任何操作
- 用户点击 Redo 没有任何 UI 反馈

**预期行为：**

- 点击 Redo 应调用后端 AI，基于该房间内所有展品的数据，生成一段中文总结语
- 新的 reflection 替换旧内容

### 实现所需工作

**后端（新增）：**

1. `member_E/backend/src/ai/ai.prompts.js`：新增 `buildRoomReflectionPrompt(input)`，接收展品列表，输出中文总结语 prompt
2. `member_E/backend/src/ai/ai.service.js`：新增 `generateRoomReflection(input)` 函数，调用 `generateJson()`
3. `member_E/backend/src/ai/ai.routes.js`：新增路由 `POST /api/ai/generate-room-reflection`
4. `backend/src/routes/ai.routes.js`（适配层）：无需修改，已通过 `createAiRouter` 自动集成

**前端（改造）：**

5. `_AiReflectionCard` 组件需要改为 `StatefulWidget`，支持内部状态更新
6. Redo 按钮连接 `AiSuggestionService`，调用新 API 并更新 reflection 状态
7. 处理 loading 态和 AI 失败 SnackBar（保持非阻塞）

**框架已支持，无需新写：**

- 后端 `ai.provider.js` 已支持 OpenAI/DeepSeek 兼容接口，只需配置 `AI_BASE_URL` 环境变量即可切换
- 前端 `AiSuggestionService` 已有完整的 API 调用模式可复用

### 复现步骤

1. 启动 App，进入 Gallery
2. 点击任意 Room（如 ROOM 01 May 2026）
3. 看到「AI ROOM REFLECTION」卡片（内容为英文硬编码）
4. 点击 Redo 按钮
5. **预期**：生成新的中文 reflection；**实际**：无任何反应

### 严重程度

**中** — 不阻塞核心功能（创建/浏览/收藏），但影响 AI 功能完整性的第一印象

### 状态

❌ 未实现

---

## 问题 2：Add 页 AI 生成在空输入时的灵活度不足

### 概述

同伴测试时反馈：在 Add 页面完全不填写内容，直接点击 AI 生成按钮时，系统行为不够灵活，生成结果过于模板化（都用"收藏品"作为描述）。

### 当前行为分析

**空输入时的处理链路（2026-05-26 确认）：**

```
用户：Add 页完全不填 → 点击 AI 生成按钮
  ↓
前端 buildPayload() → description 字段：
  form.story 非空？ → 用 story
  form.story 为空但 title 非空？ → 用 title
  均为空？ → 用 '收藏品'（hardcoded fallback）
  ↓
前端 _ensureDescription() → 检查 description.trim().isEmpty
  为空 → SnackBar 警告 "Add a short story note first"
  不为空 → 继续调用 AI
  ↓
后端 POST /api/ai/suggest-*
  ↓
  AI_PROVIDER=mock → 返回硬编码 mock 数据（如 '我的收藏记忆'）
  AI_PROVIDER=openai + key → 调用真实 AI，prompt 中以 '收藏品' 为 description
```

### 问题表现

1. **fallback 内容过于简单**："收藏品"三个字信息量极少，即使调真实 AI 也很难生成有意义的建议
2. **mock 模式结果固化**：没有 API Key 时，每次点击都返回完全相同的标题/分类/标签，对测试和演示不友好
3. **行为不够渐进**："完全不填"和"填写很少"两种情况的 AI 输出差异不够明显

### 涉及代码

| 文件 | 位置 | 现状 |
|------|------|------|
| `frontend/lib/features/collection_form/pages/create_collection_page.dart` | `buildPayload()` | `'收藏品'` 为空 fallback |
| `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart` | `_ensureDescription()` | 空 description → SnackBar 拦截，不发请求 |
| `member_E/backend/src/ai/ai.provider.js` | `getMockPayload()` | mock 模式返回完全相同的硬编码数据 |

### 解决方案选项

**方案 A（最小改动）：改进 fallback 提示文案**

空输入时 SnackBar 提示更具体，引导用户提供更多信息，而不是用"收藏品"硬撑。

```dart
// ai_suggestion_panel.dart
if (desc.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('请先填写一些描述，AI 才能生成更准确建议。')),
  );
}
```

**方案 B（中等改动）：mock 模式加入随机性**

mock 模式下让返回结果有一定随机性（多准备几套 mock 数据随机返回），改善演示体验。

**方案 C（较大改动）：新增"快速生成"模式**

允许 AI 在 description 极简时（如"随便""都行"），主动询问用户偏好（类别方向、风格），再生成结果。

### 严重程度

**低** — 不影响功能；属于 UX 体验优化

### 状态

❌ 尚未处理

---

## 问题 3：Room 月份不一致（前端硬编码 vs 后端 API）

### 概述

合并后 Gallery 和 Profile 页面的 Room 月份来源从"前端硬编码"切换为"后端 rooms API"，导致显示的月份与原始设计文档（May/June/July）不一致。

### 现状对比

| 数据源 | Gallery 上方 RoomSelectorRow | Profile 下方 RoomPreviewRow | 实际月份 |
|--------|------------------------------|----------------------------|----------|
| **原始设计文档** | May 2026 / June 2026 / July 2026 | 同左 | 5-7 月 |
| **当前合并后（接入了 rooms API）** | GET `/api/rooms` | 同左 | **March / April / May** |

### 根因分析

这个问题来自两条开发路径的历史分歧：

```
Git 历史：
a26da25  成员A，rooms API → seed 有 13 个房间（跨 2023-12 ~ 2025-03）
  ↓
a291a5d  Member C 前端上传
  ↓
bad9389  20260522 version（同伴分支）→ 前端仍用硬编码 May/June/July，后端 seed 改为 3 个（March/April/May）
  ↓
a7630f6  成员E，对齐后端逻辑
  ↓
1294603  成员E，接入成员A rooms API → seed 改为 3 个（March/April/May）
  ↓
3364f1a  完成MVP整合
```

**同伴分支（bad9389）的状态：**
- Gallery / Profile 的 Room 显示：纯读前端 `CollectoryRoomCatalog.rooms`（May/June/July）
- 后端 seed：3 个房间（March/April/May）
- 两者完全独立，没有关联

**合并接入 API 后（3364f1a）：**
- Gallery / Profile 的 Room 显示：改读 `GET /api/rooms`（March/April/May）
- `CollectoryRoomCatalog.rooms` 的 May/June/July 不再被使用（仅作 fallback）

### 影响范围

| 页面 | 组件 | 当前显示月份 | 是否受此问题影响 |
|------|------|------------|-----------------|
| Gallery | `RoomSelectorRow` + `roomsProvider` | March / April / May | ✅ 是 |
| Profile | `_RoomPreviewRow` + `roomsProvider` | March / April / May | ✅ 是 |
| Collection Room | `CollectoryRoomSpec`（硬编码） | May / June / July | ❌ 否（仅作 fallback） |

### 复现步骤

1. 启动 App，打开 Gallery 页面
2. 观察 Room 切换条：显示 **March / April / May**（而非设计文档的 May/June/July）
3. 打开 Profile 页面，下方 Room 卡片同样显示 March/April/May

### 解决方案选项

**选项 A：统一后端 seed 为 May/June/July（推荐，改动最小）**

```javascript
// backend/src/db/seed.js
rooms: [
  { month: '2026-05', label: 'May Room' },
  { month: '2026-06', label: 'June Room' },
  { month: '2026-07', label: 'July Room' },
],
```

这样后端 API 返回的月份与设计文档一致，前端无需改动。

**选项 B：前端改为显示 room 的 label 而非 month**

`RoomSelectorRow` 目前显示 `room.month`（如 "May 2026"），可以改为显示 `room.label`（如 "May Room"）——但这只能改善展示，不能解决数据源问题。

**选项 C：保留当前行为，更新设计文档**

将设计文档中 Gallery/Profile 的预期月份改为 March/April/May，但这与产品面向"当月收藏"的概念不够契合。

### 严重程度

**中** — 用户可见月份与设计预期不符，影响 Demo 展示一致性；不阻塞功能

### 状态

❌ 尚未处理

---

## 问题 4：RoomSelectorRow 中 Room 名称字符长度不一致导致排版问题

### 概述

在 Gallery 页面的 `RoomSelectorRow` 组件中，各月份 Room 名称的字符长度不一致（"March Room" 11字符 vs "May Room" 9字符），可能导致视觉对齐和溢出问题。

### 现状分析

**涉及的组件和数据：**

| 文件 | 内容 |
|------|------|
| `frontend/lib/features/collection_browse/widgets/design/room_selector_row.dart` | Gallery 顶部 Room 切换条，`RoomSelectorRow` 组件 |
| `backend/src/db/seed.js` | 后端 seed：March Room / April Room / May Room |

**后端 seed 数据（`seed.js:266-268`）：**

```javascript
rooms: [
    { month: '2026-03', label: 'March Room' },   // "March" = 5 字母
    { month: '2026-04', label: 'April Room' },  // "April" = 5 字母
    { month: '2026-05', label: 'May Room' },    // "May" = 3 字母
],
```

**`RoomSelectorRow` 显示内容（`room_selector_row.dart:65-78`）：**

```dart
// 第一行：room.month（来自后端，如 "2026-03"）
Text(
  room.month,
  style: CollectoryTypography.metaLabel.copyWith(fontSize: 9, ...),
),

// 第二行：room.label（来自后端，如 "March Room"）
Text(
  label,  // = room.label ?? room.month
  style: CollectoryTypography.cardTitle.copyWith(fontSize: 14, ...),
),
```

**各 Room 字符串长度对比：**

| Room | `room.month`（8字符，等宽） | `room.label`（不等宽） |
|------|--------------------------|------------------------|
| March Room | `2026-03`（8） | **"March Room"（11字符，5字母）** |
| April Room | `2026-04`（8） | **"April Room"（11字符，5字母）** |
| May Room | `2026-05`（8） | "May Room"（9字符，3字母） |

### 问题表现

**`room.month` 字段：** 三个均为 "2026-0X" 格式，字符宽度相同，无问题。

**`room.label` 字段（主要问题）：**
- "March Room" / "April Room" = 11 字符，字体 14px
- "May Room" = 9 字符，字体 14px
- 两者相差 2 字符 × 14px ≈ **28px 的视觉宽度差异**
- 在 `RoomSelectorRow` 的等宽 `Expanded` 卡片内，内容靠左对齐，第二行起点相同但宽度不同
- "March Room" 更长，但没有 `maxLines` 或 `overflow` 约束，可能在窄屏下溢出

### 根因

这个问题**不是新引入的**，而是原始设计时就存在的字母长度差异：

- 设计文档（`Member_4_UI_Visual_Design_Detail_Plan.md`）用的是 **May / June / July**
- "June" = 4 字母，"July" = 4 字母，均只比 "May" 多 1 字符
- 接入后端 API 后切换为 **March / April / May**
- "March" / "April" = 5 字母，比 "June" / "July" 又多 1 字符
- 加上 "Room" 后缀（4字母），最终 "March Room"（11字符）vs "May Room"（9字符）差距更明显

### 影响范围

| 页面 | 组件 | 问题 |
|------|------|------|
| Gallery | `RoomSelectorRow` | `label` 文本（"March Room"）无 `maxLines`/`overflow` 约束 |
| Profile | `_RoomPreviewCard`（`profile_collection_preview.dart:711`） | `title` 字段有 `maxLines: 1` + `ellipsis`，**不受影响** |

### 解决方案

**方案 A（推荐）：`RoomSelectorRow` 的 `label` Text 增加 `maxLines: 1` + `overflow: ellipsis`**

```dart
// room_selector_row.dart，约第 75 行
Text(
  label,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,  // ← 新增
  style: CollectoryTypography.cardTitle.copyWith(...),
),
```

改动最小，不影响功能，只做视觉保护。

**方案 B：在 seed 中统一 Room 名称格式**

如果希望所有 label 等宽，可以考虑类似 "Month 1 / Month 2 / Month 3" 的命名格式，但改动较大且语义不明确。

### 严重程度

**低** — 仅视觉对齐问题，不影响功能；修复成本低

### 状态

❌ 尚未处理

---

## 中文内容清单

> 产品设计目标：**英文 UI**。以下中文是开发过程中因"方便开发者理解"而设置的。
> 本清单按用途分类，便于后续统一替换为英文。

### 分类说明

| 分类 | 说明 |
|------|------|
| **A. AI 生成内容（后端 mock 返回给前端的用户可见内容）** | AI 服务返回的中文内容，展示给用户看的，属于 AI 功能的正常输出 |
| **B. AI 系统 Prompt（后端内部 prompt 模板）** | AI 服务内部使用的 prompt，不是用户直接看到的内容 |
| **C. 前后端字段映射（中文 ↔ 英文 slug）** | 前后端约定的中文↔slug 映射表，是技术接口的一部分 |
| **D. AI fallback 内部参数** | 前端发给 AI 的 fallback 参数，不直接展示给用户，但会在 prompt 中出现 |
| **E. Flutter 开发者方便用中文（非用户面向）** | 代码中直接写的中文字符串，仅开发者可见，不出现在正式 UI |
| **F. 社交占位按钮（用户面向 UI）** | 真实用户可见的界面文字，目前为中文 |

---

### A. AI 生成内容（后端 mock 返回）

这些是 AI 功能返回给前端展示的内容——如果产品目标是英文 UI，这些应该替换为英文，或保持 AI 随机生成英文内容。

**文件：`member_E/backend/src/ai/ai.provider.js`**

| 行号 | 内容 | 用途 |
|------|------|------|
| 62-69 | 四种故事风格 mock（简洁风/手账风/旅行日记风/复古风） | `generate-story` 的 mock 返回，中文 |
| 75-80 | 票根类 mock：`'复古展览票根'` / `'票根'` / `['展览', '票根', '复古']` | `analyze-image` mock 票根分支 |
| 83-88 | 黑胶类 mock：`'封面完好的黑胶'` / `'黑胶唱片'` / `['黑胶', '音乐', '收藏']` | `analyze-image` mock 黑胶分支 |
| 91-96 | 矿石类 mock：`'天然矿石标本'` / `'矿石'` / `['矿石', '自然', '标本']` | `analyze-image` mock 矿石分支 |
| 100-103 | 默认类 mock：`'值得保存的小物'` / `'其他'` / `['收藏', '纪念', '日常']` | `analyze-image` mock 默认分支 |
| 110 | `{ category: '明信片', confidence: 0.75 }` | `suggest-category` mock 返回 |
| 112 | `{ tags: ['旅行', '明信片', '书店'] }` | `suggest-tags` mock 返回 |
| 128 | `['我的收藏记忆', '一件小小收藏', '值得保存的瞬间']` | `suggest-title` mock 返回 |

**说明**：这些是 AI 服务的 mock 测试数据，不是真实 AI 生成。如果真实 AI（如 DeepSeek）可用，则这些 mock 不被调用，AI 真实返回的内容语言取决于 prompt 模板（见下方 B 类）。

---

### B. AI 系统 Prompt（后端内部 prompt 模板）

这些是发给 AI 模型的中文 prompt 指令，影响 AI 返回内容的语言和风格。

**文件：`member_E/backend/src/ai/ai.prompts.js`**

| 行号 | 内容摘要 |
|------|---------|
| 4-8 | 四种故事风格提示（简洁风/手账风/旅行日记风/复古风），含中文写作指导 |
| 15-33 | `buildTitlePrompt` — 要求生成"3 个中文标题建议"，输出 JSON 含中文键 |
| 37-59 | `buildCategoryPrompt` — 要求从"固定类别列表中选择"，类别为中文（见 C 类） |
| 62-82 | `buildTagsPrompt` — 要求生成"3 到 8 个中文标签" |
| 85-113 | `buildStoryPrompt` — 要求生成"100 到 150 个中文字符左右的收藏故事草稿" |

**文件：`member_E/backend/src/ai/vision.prompts.js`**

| 行号 | 内容摘要 |
|------|---------|
| 14-34 | 图片识别 prompt — 要求生成中文标题、标签、描述；规则要求"不超过 20 个中文字符"等 |

**影响**：如果调用真实 AI，这些 prompt 决定了 AI 返回中文内容。替换为英文 UI 需要同步修改这些 prompt。

---

### C. 前后端字段映射（中文 ↔ slug）

这是技术接口约定，不直接面向用户，但影响 UI 显示内容。

**文件：`frontend/lib/features/collection_form/utils/ai_category_mapping.dart`**

```dart
// AI 返回中文 → 转英文 slug（写入数据库）
'矿石': 'mineral',
'水晶': 'crystal',
'黑胶唱片': 'vinyl',
'明信片': 'postcard',
'票根': 'ticket',
'旅行纪念品': 'souvenir',
'邮票': 'stamp',
'其他': 'other',

// 数据库英文 slug → 中文显示名（前端展示）
'mineral': '矿石',
'crystal': '水晶',
'vinyl': '黑胶唱片',
'postcard': '明信片',
'ticket': '票根',
'souvenir': '旅行纪念品',
'stamp': '邮票',
'other': '其他',
```

**文件：`member_E/backend/src/ai/ai.schemas.js`**

| 行号 | 内容 |
|------|------|
| 2-8 | `COLLECTION_CATEGORIES = ['矿石', '水晶', '黑胶唱片', '明信片', '票根', '旅行纪念品', '邮票', '其他']` — AI 返回的 category 候选项 |

**说明**：这是前后端约定的合同。如果要切换为英文 UI，需要同步改动这些映射表和 AI prompt 中的类别名称。

---

### D. AI fallback 内部参数

**文件：`frontend/lib/features/collection_form/pages/create_collection_page.dart:343`**

```dart
description: form.story.isNotEmpty
    ? form.story
    : (form.title.isNotEmpty
        ? form.title
        : '收藏品'),  // ← fallback，仅发给 AI，不直接展示给用户
```

**说明**：当用户没有填写 story 也没有填写 title 时，用 `'收藏品'` 作为发给 AI 的 description 参数。这是内部参数，不直接展示给用户，但在 AI prompt 中出现。如果产品目标为英文，这里应改为英文 `'collectible'`。

---

### E. Flutter 开发者方便用中文（非用户面向）

**文件：`frontend/lib/features/profile/models/user_profile.dart:47`**

```dart
bio: '热爱收藏生活中的每一个美好瞬间。矿石、唱片、票根、明信片——每件小物背后都有一段旅程。',
```

**文件：`frontend/lib/features/collection_browse/pages/add_exhibit_design_page.dart:428-431`**

```dart
ExhibitIconKind.ticket => '一张泛黄的展览票根照片，边缘略有磨损，印刷字体清晰',
ExhibitIconKind.vinyl => '黑胶唱片封面照片，色彩饱和，中央圆形标签可见',
ExhibitIconKind.mineral => '天然矿石标本特写，表面有晶体反光',
_ => '收藏品物件照片，光线柔和，适合识别类别',
```

**说明**：这些是开发阶段 mock 数据用的中文描述，展示给用户时会作为图片识别提示。不属于正式 UI 字符串，但需要注意它们不是 AI 真实生成的内容。

---

### F. 社交占位按钮（用户面向 UI）

这些是当前真实展示给用户的中文 UI 字符串。

**文件：`frontend/lib/features/collection_browse/pages/public_collections_page.dart`**

| 行号 | 内容 | 说明 |
|------|------|------|
| 108 | `'暂无公开收藏'` | 公开收藏空状态标题 |
| 109 | `'将收藏设为 public 后会出现在此列表。'` | 公开收藏空状态说明 |
| 170 | `_SocialPlaceholderButton(label: '点赞')` | 点赞按钮（占位） |
| 171 | `_SocialPlaceholderButton(label: '评论')` | 评论按钮（占位） |
| 172 | `_SocialPlaceholderButton(label: '收藏')` | 收藏按钮（占位） |
| 173 | `_SocialPlaceholderButton(label: '关注')` | 关注按钮（占位） |

**说明**：这些是用户真实可见的 UI 文字，按产品英文目标应替换为英文。

---

### 替换优先级建议

| 优先级 | 内容 | 说明 |
|--------|------|------|
| **P0 必须改** | F 类（社交占位按钮） | 直接面向用户，当前就是中文 |
| **P1 应该改** | B 类 prompt（改为英文指令） + C 类映射（改为英文 slug） | 切换英文 UI 的基础设施 |
| **P2 可以改** | A 类 mock（改为英文） | 影响 Demo 展示效果 |
| **P3 不急着改** | D 类 fallback（`'收藏品'` → `'collectible'`） | 仅内部参数 |
| **P4 不需要改** | E 类（开发者方便用中文） | 仅代码注释/开发mock，不影响正式 UI |

---

## 更新日志

- **2026-05-26**（成员 E / 成员 5，由 Codex 协助）：新建本文档。记录 Room Reflection Redo 按钮无功能（BUG-ME-006 原记录于 Test.md，现移至本文档）、Room 月份不一致两个问题。
- **2026-05-26**（成员 E / 成员 5，由 Codex 协助）：新增问题 4：`RoomSelectorRow` 中 "March Room" 字符多于 "May Room" 导致视觉对齐差异；建议方案为给 `label` Text 增加 `maxLines: 1` + `overflow: ellipsis`。并注明该问题在切换为 March/April/May 后比原始 June/July 设计更明显。
- **2026-05-26**（成员 E / 成员 5，由 Codex 协助）：新增"中文内容清单"章节。按 A/B/C/D/E/F 六类梳理了全库中文内容：AI mock 返回（A）、AI prompt 模板（B）、中文↔slug 映射（C）、AI fallback 参数（D）、开发 mock 中文（E）、用户面向 UI 中文（F）。标注了替换优先级。
- **2026-05-26**（成员 E / 成员 5，由 Codex 协助）：新增问题 2：Add 页空输入时 AI 生成灵活度不足——空 description fallback 到 `'收藏品'`，mock 模式返回固化结果；分析了完整链路 `buildPayload → _ensureDescription → API/mock`，并提出三个解决方案选项（提示优化 / mock 随机性 / 快速生成模式）。
