# member_E 工作区说明

本文件夹是成员 E / 成员 5 的独立工作区，用于存放 AI 功能、用户主页、测试支持相关的任务文档和阶段交付物。

当前已完成：阶段一；阶段二（含任务五 AI 面板预交付）；阶段三·任务 1–4「用户主页与资料」。

---

## 1. 文件结构

```text
member_E/
├── README.md
├── Member_5_AI_Profile_Test_Detail_Plan.md
├── E_Status_Log.md
├── E_Prompt_Log.md
├── E_Test_Log.md
├── scripts/
│   ├── verify_phase1_task1_title.js
│   ├── verify_phase2_task1_provider.js
│   └── verify_phase2_tasks2_4_api.js
├── .env.example
├── docs/
│   ├── AI_API_Contract.md
│   ├── AI_Provider_Setup.md
│   ├── AI_Routes_Integration.md
│   ├── Phase_1_Completion_Report.md
│   └── prompts/
│       ├── prompt_title.md
│       ├── prompt_category.md
│       ├── prompt_tags.md
│       └── prompt_story.md
└── backend/
    └── src/
        └── ai/
            ├── ai.prompts.js
            ├── ai.schemas.js
            ├── ai.provider.js
            ├── ai.service.js
            └── ai.routes.js
```

---

## 2.1 阶段二·任务一交付物

| 任务 | 交付物 |
|---|---|
| 任务 1：实现 AI Provider 封装 | `backend/src/ai/ai.provider.js`、`docs/AI_Provider_Setup.md`、`.env.example`、`scripts/verify_phase2_task1_provider.js` |
| 任务 2–4：四个 AI HTTP 接口 | `ai.service.js`、`ai.routes.js`、`docs/AI_Routes_Integration.md`、`scripts/verify_phase2_tasks2_4_api.js`；根目录 `backend/src/routes/ai.routes.js` + `app.js` 挂载 |
| 任务 5：AI 建议面板（成员 B 工作区） | `../member_B/` + `frontend/lib/features/collection_form/`（成员 E 编写）；见 `member_B/docs/Phase2_Task5_AI_Panel_by_Member_E.md` |

### 阶段三·任务 1–4 交付物

| 任务 | 交付物 |
|---|---|
| 任务 1–2 | `frontend/lib/features/profile/pages/profile_page.dart` 等 |
| 任务 3 | `edit_profile_page.dart` |
| 任务 4 | `login_placeholder_page.dart`、`register_placeholder_page.dart` |
| 说明 | `docs/Phase_3_Profile_Completion.md` |

---

## 2. 当前阶段一交付物

| 阶段一任务 | 交付物 |
|---|---|
| 任务 1：设计标题生成 Prompt | `docs/prompts/prompt_title.md`、`backend/src/ai/ai.prompts.js`、`scripts/verify_phase1_task1_title.js` |
| 任务 2：设计分类建议 Prompt | `docs/prompts/prompt_category.md`、`backend/src/ai/ai.prompts.js` |
| 任务 3：设计标签推荐 Prompt | `docs/prompts/prompt_tags.md`、`backend/src/ai/ai.prompts.js` |
| 任务 4：设计故事生成 Prompt | `docs/prompts/prompt_story.md`、`backend/src/ai/ai.prompts.js` |
| 任务 5：确定 AI API Contract | `docs/AI_API_Contract.md`、`backend/src/ai/ai.schemas.js` |

---

## 3. 成员 E 局部记录文件

成员 E 可以先在本文件夹内维护局部状态，阶段结束后再同步到根目录主文档。

| 局部文件 | 对应根目录文件 | 用途 |
|---|---|---|
| `E_Status_Log.md` | `../Status.md` | 记录成员 E 的阶段进度、文件变化和待办事项 |
| `E_Prompt_Log.md` | `../Prompt_library.md` | 记录成员 E 的局部对话、Prompt 和关键决策 |
| `E_Test_Log.md` | `../Test.md` | 记录成员 E 的详细测试过程、Bug 和测试结论 |

命名规则：成员 E 局部记录文件统一使用 `E_..._Log.md`，不能命名为 `Status.md`、`Prompt_library.md` 或 `Test.md`，避免和根目录主文档混淆。

---

## 4. 局部到全局同步规则

### 4.1 平时开发

日常小修改、草稿、局部自检，先写入 `member_E/` 内部三个局部记录文件：

1. 进度变化写入 `E_Status_Log.md`。
2. Prompt、用户要求、AI 行动和关键决策写入 `E_Prompt_Log.md`。
3. 测试步骤、开发自检和 Bug 细节写入 `E_Test_Log.md`。

### 4.2 阶段结束

每个阶段结束时，必须把成员 E 的阶段摘要同步到根目录：

1. 从 `E_Status_Log.md` 摘要同步到 `../Status.md`。
2. 从 `E_Prompt_Log.md` 摘要同步到 `../Prompt_library.md`。
3. 从 `E_Test_Log.md` 摘要同步到 `../Test.md`。

### 4.3 必须立即同步根目录的情况

以下情况不能等阶段结束，需要立刻同步根目录主文档：

1. 改动会影响成员 A 的后端接口、字段、目录结构。
2. 改动会影响成员 B 的创建收藏页面或 AI 建议面板接入。
3. 改动会影响成员 C 的收藏展示、搜索或用户主页展示。
4. 改动会影响成员 D 的视觉规范或组件样式。
5. 测试发现阻塞 Demo 的严重 Bug。
6. 阶段状态从“待测试”变成“测试通过”或“测试失败”。

---

## 5. 给开发 AI 的提醒

1. 成员 E / 成员 5 只负责 AI 功能、用户主页、测试支持和 Demo 联调相关内容。
2. 当前阶段一只固定 Prompt 和 API Contract，不直接接入真实 OpenAI / Claude API。
3. 真实接口开发属于阶段二，后续应与成员 A / 成员 1 的后端结构对齐。
4. 如果未来需要把 `member_E/backend/src/ai/` 合并到根目录 `backend/src/ai/`，需要先与成员 A 确认目录和路由结构。
5. 每次修改后先更新 `E_Status_Log.md` 和 `E_Prompt_Log.md`；如涉及测试，更新 `E_Test_Log.md`。
6. 阶段结束或涉及跨成员影响时，再同步根目录 `Status.md`、`Prompt_library.md` 和必要的 `Test.md`。

---

## 6. 给测试 AI 的提醒

测试阶段一时，请重点检查：

1. 四个 Prompt 文档是否存在且输出 JSON 结构稳定。
2. API Contract 是否覆盖请求字段、响应字段、错误码和 loading 处理。
3. `ai.prompts.js` 和 `ai.schemas.js` 是否可以被 Node.js 正常解析。
4. 阶段一是否没有越界实现阶段二真实 AI Provider 或接口服务。
5. 详细测试过程先写入 `E_Test_Log.md`；阶段测试结论再同步到根目录 `Test.md`。
