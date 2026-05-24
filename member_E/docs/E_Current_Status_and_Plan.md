# 成员 E 当前状态与下一步计划

负责人：成员 E / 成员 5
更新时间：2026-05-22
用途：替代过时的“从旧任务继续开发”模板，作为成员 E 接下来接管、复测和整合工作的入口。

---

## 1. 当前基线

| 项目 | 当前口径 |
|---|---|
| 当前工作分支 | `feature/ai-profile-test` |
| 分支来源 | 协作分支，已包含成员 E 主要实现 |
| 主要原则 | 当前小范围测试和文档同步直接放在 `feature/ai-profile-test`；高风险实验再单独开分支 |
| 备用方案 | 如果后续要做大范围重构，可重新创建 `memberE` 或 `codex/...` 分支隔离 |
| 当前冲突处理口径 | 以线上最新实现为主，昨晚未提交的旧任务规划文档只保留仍有价值的结构和技术细节 |
| 尚未合入的重要分支 | `origin/feature/member-1-task`，包含 `rooms` 表、`collections.room_id`、`GET /api/rooms`、`GET /api/rooms/:id` |

---

## 2. 当前项目结构

```text
GenAI_in_Business/
├── backend/
│   └── src/
│       ├── app.js                         # Express 入口，已挂载 /api/ai
│       ├── routes/
│       │   ├── collections.routes.js
│       │   ├── categories.routes.js
│       │   ├── users.routes.js
│       │   └── ai.routes.js               # 成员 E AI 路由适配层
│       └── db/schema.sql                  # 当前 feature/ai-profile-test 尚未包含 rooms 表
├── frontend/
│   └── lib/
│       ├── app.dart                       # Flutter 四 Tab + overlay 入口
│       ├── features/collection_browse/    # 成员 C 浏览、详情、Room、Share、Add 壳
│       ├── features/collection_form/      # 成员 E 预交付 AI 面板
│       └── features/profile/              # 成员 E Profile / Edit / Auth mock
├── member_B/
│   └── frontend/lib/features/collection_form/
│                                           # AI 面板副本，供成员 B 正式表单迁入
└── member_E/
    ├── backend/src/ai/                    # 成员 E AI prompt/provider/service/routes
    ├── docs/                              # AI contract、阶段报告、当前计划
    ├── scripts/                           # 成员 E 自检脚本
    ├── E_Status_Log.md
    ├── E_Prompt_Log.md
    └── E_Test_Log.md
```

---

## 3. 成员 E 已有实现

| 阶段 | 当前状态 | 说明 |
|---|---|---|
| 阶段一：Prompt + Contract | 已完成并有自检 | 四类 Prompt、`AI_API_Contract.md`、`ai.prompts.js`、`ai.schemas.js` |
| 阶段二：文字 AI 接口 | 已完成并通过真实 DeepSeek 测试 | `suggest-title`、`suggest-category`、`suggest-tags`、`generate-story`；Provider 支持 mock/OpenAI-compatible DeepSeek |
| 阶段二：AI 面板联调 | 有 Demo 级接入 | `AiSuggestionPanel` 已挂 Add 页；正式创建页仍等成员 B 整合 |
| 阶段三：Profile | 已有实现 | Profile、stats、Edit profile、login/register mock、成员 C 展示嵌入 |
| 阶段四：图片识别 + 多风格故事 | 已有实现 | `analyze-image`、`style`、Recognize 填表；真实图片理解已切到 GLM Vision |
| 阶段五：测试和 Demo | 已有文档和脚本 | `verify_phase5_demo_e2e.js`、`Phase5_Demo_Checklist.md`、`Member6_Demo_Handoff.md` |

这些状态表示“当前分支已有可用实现”，不等于最终团队整合完成。DeepSeek 文字生成已通过真实 API 测试，图片理解已切到 GLM Vision；下一步重点是接成员 A rooms API、接成员 B 正式表单，以及最终 Demo 回归。

---

## 4. 下一步宏观计划

### P0：清理文档冲突（已完成）

目标：让成员 E 文档回到适配当前分支的可提交状态。

动作：

1. 删除过时的 `E_Fresh_AI_Workflow.md`。
2. 保留并更新 `TODO_Guide.md`、`E_Technical_Route_Map.md` 和本文件。
3. 标记 `Prompt_library.md`、`Status.md`、`E_Prompt_Log.md`、`E_Status_Log.md` 冲突已解决。

### P1：同步成员 E 文档到协作分支（已采用）

目标：让队友能在 `feature/ai-profile-test` 看到成员 E 当前接管版本和测试结果。

动作：

1. 确认 `git status` 不包含 `backend/.env`。
2. 将测试文档和无密钥配置示例提交到 `feature/ai-profile-test`。
3. `memberE` 暂不需要推到 GitHub；只有后续大改或实验时再开隔离分支。

### P2：复测当前成员 E 能力（DeepSeek 已完成）

目标：证明当前实现可以运行，而不是只在文档里显示完成。

动作：

1. 在 `backend/` 安装依赖并启动后端。
2. 跑成员 E 自检脚本。
3. DeepSeek service live：5/5。
4. `/api/ai/*` DeepSeek HTTP live：5/5。
5. 阶段 1/2/4/5 自动化回归：66/66；Flutter 单测：1/1。

### P3：接成员 A rooms API

目标：把现有静态月度 room 逻辑逐步对齐后端真实 room 数据。

动作：

1. 合并或 cherry-pick `origin/feature/member-1-task` 中 rooms 相关后端代码。
2. 确认 `collections.room_id`、`GET /api/rooms`、`GET /api/rooms/:id` 可用。
3. 更新 Profile / Room / Add 的数据路线，避免长期只依赖 `collectory_room_catalog.dart`。

### P4：接成员 B 正式创建表单

目标：把成员 E 的 AI 面板从 Demo 挂钩迁到正式创建收藏流程。

动作：

1. 成员 B 表单进入统一分支后，迁入 `AiSuggestionPanel`。
2. 标签建议写入正式 Tag input，而不是只显示 SnackBar。
3. Recognize 结果写入标题、分类、标签、故事和可选 room。

### P5：最终 Demo 回归

目标：交给成员 6 一个可信 Demo 结论。

动作：

1. 跑 API 全链路脚本。
2. 跑 Flutter 手测清单。
3. 更新 `Test.md` 和 `Member6_Demo_Handoff.md`。

---

## 5. 微观技术细节

### AI 后端

| 项 | 当前实现 |
|---|---|
| 根目录挂载 | `backend/src/app.js` 挂载 `/api/ai` |
| 适配层 | `backend/src/routes/ai.routes.js` |
| 成员 E 业务层 | `member_E/backend/src/ai/ai.service.js` |
| Provider | `member_E/backend/src/ai/ai.provider.js` |
| Prompt | `member_E/backend/src/ai/ai.prompts.js` |
| Schema | `member_E/backend/src/ai/ai.schemas.js` |
| Mock 模式 | 无 Key 时自动 mock；也可显式 `AI_PROVIDER=mock` |
| DeepSeek 模式 | `AI_PROVIDER=openai` + `AI_BASE_URL=https://api.deepseek.com`，已用 `deepseek-v4-flash` 实测通过 |
| 错误码 | `AI_VALIDATION_ERROR`、`AI_PROVIDER_UNAVAILABLE`、`AI_INVALID_RESPONSE` |

### AI 分类写入

AI 返回中文分类，例如 `票根`。收藏 API 存英文 slug，例如 `ticket`。写入前必须用 `GET /api/categories` 或 `frontend/lib/features/collection_form/utils/ai_category_mapping.dart` 做映射。

### Profile

当前 Profile 是成员 E 和成员 C 的合并页：

```text
frontend/lib/features/profile/pages/profile_page.dart
  -> ProfileHeader / ProfileStats
  -> ProfileCollectionPreview(embeddedInMemberEProfile: true)
```

限制：

1. 展示资料仍是 mock，本分支没有真实 `GET /api/users/:id` 资料详情接口。
2. 编辑资料是本地 Riverpod mock 保存。
3. 登录 / 注册是占位，不接 JWT。

### Add + AI 面板

当前 Add 页已有 Demo 级 AI 接入：

1. `AiSuggestionPanel` 可触发标题、分类、标签、故事和图片识别。
2. 标题 / 分类 / 故事可写入现有 Add 页字段。
3. 标签目前不是正式多选字段，需要等成员 B 表单接入。
4. 图片识别已接 GLM Vision 主路径；Demo 仍保留 `imageDescription` 文本 fallback，避免外部 API 临时不可用时阻塞手动保存。

### Rooms 适配

当前 `feature/ai-profile-test` 的前端 room 逻辑主要来自成员 C 的静态目录：

```text
frontend/lib/features/collection_browse/utils/collectory_room_catalog.dart
```

成员 A 最新分支已新增后端 rooms。合并后需要：

1. 收藏模型增加 `roomId`。
2. Add / Edit 保存时可写入 `roomId`。
3. Profile / Room 页优先读取 `/api/rooms`。
4. Demo 测试新增 rooms API 用例。

---

## 6. 建议复测命令

```bash
node member_E/scripts/verify_phase1_task1_title.js
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
```

启动后端后再跑 HTTP 层：

```bash
cd backend
npm install
AI_PROVIDER=mock npm run dev
```

另一个终端：

```bash
BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase2_tasks2_4_api.js
BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase4_tasks1_5_api.js
BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase5_demo_e2e.js
```

Flutter 手测：

```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port=8090
```

---

## 7. 当前保留和删除的文档

| 文档 | 处理 |
|---|---|
| `member_E/docs/E_Current_Status_and_Plan.md` | 新增，作为当前入口 |
| `member_E/docs/E_Technical_Route_Map.md` | 保留，作为微观技术路线补充 |
| `member_E/TODO_Guide.md` | 保留，作为快速任务判断表 |
| `member_E/docs/E_Fresh_AI_Workflow.md` | 删除，旧任务模板已不适配当前项目状态 |
