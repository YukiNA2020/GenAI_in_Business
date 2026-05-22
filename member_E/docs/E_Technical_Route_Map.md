# 成员 E 全任务技术路线地图

负责人：成员 E / 成员 5
用途：给新的开发 AI / 测试 AI 一个确定口径，避免只凭总任务描述自由发挥。
适用范围：成员 E 阶段一到阶段五全部任务。

---

## 1. 总原则

1. 当前工作分支是 `memberE`，不要直接在 `main` 或 `feature/ai-profile-test` 上开发或提交。
2. 一次只做一个任务，例如只做 `E3-4`，不要顺手完成其他任务。
3. 成员 E 的 AI 后端代码优先放在 `member_E/backend/src/ai/`；根目录 `backend/` 只做必要的最小挂载或适配。
4. 成员 E 的前端新增内容必须接入当前 Flutter App：`frontend/lib/app.dart` + `frontend/lib/features/collection_browse/`。不要另起一个脱离现有 `app.dart` 的孤立页面体系。
5. 成员 E 的测试和文档先写入 `member_E/` 局部文件；阶段结束、影响跨成员接口、测试通过/失败、或新增重要文件时，再同步根目录 `Status.md`、`Prompt_library.md`、`Test.md`。
6. `past_doc/` 只作为立项参考，不作为成员 E 当前开发依据。

---

## 2. 当前固定技术栈和代码边界

| 方向 | 当前固定路线 |
|---|---|
| 后端框架 | Node.js + Express，根目录后端入口为 `backend/src/app.js` |
| AI 业务代码 | `member_E/backend/src/ai/` |
| AI 根目录挂载 | `backend/src/routes/ai.routes.js` 作为适配层，`backend/src/app.js` 挂载 `/api/ai` |
| AI Provider | `generateJson(prompt, { validate, mockKind })`，无 Key 时可用 mock |
| AI 错误码 | `AI_VALIDATION_ERROR`、`AI_PROVIDER_UNAVAILABLE`、`AI_INVALID_RESPONSE` |
| 分类输出 | AI 返回中文分类，写入收藏前映射为英文 slug，映射参考 `GET /api/categories` 或 `ai_category_mapping.dart` |
| 前端框架 | Flutter + Riverpod |
| 当前前端主架构 | `frontend/lib/app.dart`、`frontend/lib/features/collection_browse/` |
| AI 表单面板 | `frontend/lib/features/collection_form/` 和 `member_B/frontend/lib/features/collection_form/` |
| Profile 当前实现 | `ProfileDesignPage` + `ProfileCollectionPreview`，不要重复造一个不接入 App 的 Profile |
| 测试记录 | `member_E/E_Test_Log.md` 优先；必要时同步根目录 `Test.md` |
| 当前分支来源 | `memberE` 基于最新 `origin/feature/ai-profile-test` 创建；远端 `origin/feature/member-1-task` 的 rooms API 尚未合并 |

---

## 3. 阶段一：AI Prompt 模板和 API Contract

阶段一已经完成。新 AI 不应重做，除非用户明确要求修改 Prompt。

| 任务 | 当前状态 | 确定文件 | 技术路线 | 验收口径 |
|---|---|---|---|---|
| E1-1 标题 Prompt | 已完成 | `docs/prompts/prompt_title.md`、`ai.prompts.js`、`ai.schemas.js` | `buildTitlePrompt()` 生成 Prompt；`validateTitleResponse()` 保证 3 个标题且每个不超过 20 字 | 自检脚本 `verify_phase1_task1_title.js` 通过 |
| E1-2 分类 Prompt | 已完成 | `docs/prompts/prompt_category.md`、`ai.prompts.js`、`ai.schemas.js` | 输出中文分类 + confidence；分类必须来自固定集合 | 分类集合不能随意改名 |
| E1-3 标签 Prompt | 已完成 | `docs/prompts/prompt_tags.md`、`ai.prompts.js`、`ai.schemas.js` | 输出 3-8 个不重复标签 | 不允许空字符串和重复标签 |
| E1-4 故事 Prompt | 已完成 | `docs/prompts/prompt_story.md`、`ai.prompts.js`、`ai.schemas.js` | 生成温暖、可编辑、不编造事实的故事 | 输出 JSON `{ "story": "..." }` |
| E1-5 AI API Contract | 已完成 | `docs/AI_API_Contract.md` | 固定四个文字 AI 接口输入、输出、错误格式和 loading 建议 | 成员 B 能按 Contract 接入 |

---

## 4. 阶段二：文字 AI 接口和表单联调

阶段二在远端分支中已有实现，但需要成员 E 接管确认、独立测试和成员 B / 整体 UI 联调。不要只因为文件存在就判定最终完成。

| 任务 | 当前状态 | 确定文件 | 技术路线 | 验收口径 |
|---|---|---|---|---|
| E2-1 AI Provider 封装 | 已完成 | `ai.provider.js`、`AI_Provider_Setup.md`、`.env.example`、`verify_phase2_task1_provider.js` | 使用 `generateJson()` 封装 OpenAI/mock、timeout、JSON 解析和错误映射 | 自检 11/11 通过；无 Key 时 mock 可跑 |
| E2-2 标题建议接口 | 远端已有实现，待成员 E 确认/独立测试 | `ai.service.js`、`ai.routes.js`、`backend/src/routes/ai.routes.js` | `POST /api/ai/suggest-title`，description 必填，返回 3 个标题 | HTTP 返回结构符合 `AI_API_Contract.md` |
| E2-3 分类和标签接口 | 远端已有实现，待成员 E 确认/独立测试 | 同上 | `POST /api/ai/suggest-category`、`POST /api/ai/suggest-tags` | 分类中文名合法；标签 3-8 个 |
| E2-4 故事生成接口 | 远端已有实现，待成员 E 确认/独立测试 | 同上 | `POST /api/ai/generate-story`，调用 `buildStoryPrompt()` | AI 失败返回 502，不阻塞手动保存 |
| E2-5 AI 面板联调 | 远端已有预交付，待成员 E / 成员 B 确认 | `frontend/lib/features/collection_form/`、`member_B/frontend/lib/features/collection_form/`、`Phase2_Task5_AI_Panel_by_Member_E.md` | `AiSuggestionPanel` 调四个 AI 接口；Add 页有最小挂钩；成员 B 后续迁入正式创建表单 | 能从表单输入 description 后获取 AI 建议，且用户选择后写入表单 |

阶段二测试优先级：

1. 先运行 `member_E/scripts/verify_phase2_task1_provider.js` 和 `member_E/scripts/verify_phase2_tasks2_4_api.js`。
2. 再启动根目录 `backend`，用 curl 或测试脚本验证 `/api/ai/*`。
3. 最后在 Flutter Add 页人工检查 `AiSuggestionPanel` 是否能触发和回填。

---

## 5. 阶段三：用户主页、统计、资料和登录占位

阶段三在远端最新分支中已有实现。提交作者显示为 `Jean030`，因此这里的准确口径是“远端已有实现，待成员 E 接管确认和独立测试”，不是成员 E 本人已确认完成。成员 C 已经实现了 Profile 收藏展示骨架，当前远端实现通过 `ProfilePage` 单页整合成员 E 的用户资料区与成员 C 的收藏展示区。

### 阶段三共同前端落点

| 用途 | 当前文件 |
|---|---|
| App 页面切换 | `frontend/lib/app.dart` |
| overlay / tab 状态 | `frontend/lib/features/collection_browse/providers/app_navigation_provider.dart` |
| Profile Tab 入口 | `frontend/lib/features/collection_browse/pages/profile_design_page.dart` |
| Profile 主体 | `frontend/lib/features/profile/pages/profile_page.dart` |
| 成员 C 收藏展示嵌入 | `frontend/lib/features/collection_browse/widgets/profile_collection_preview.dart` |
| 用户 stats provider | `frontend/lib/features/collection_browse/providers/collection_list_provider.dart` |
| API service | `frontend/lib/features/collection_browse/services/collection_query_service.dart` |
| 视觉 token | `frontend/lib/core/theme/collectory_theme.dart`、`collectory_tokens.dart` |

| 任务 | 当前状态 | 推荐文件 / 动作 | 技术路线 | 验收口径 |
|---|---|---|---|---|
| E3-1 开发用户主页 | 远端已有实现，待成员 E 确认/独立测试 | `frontend/lib/features/profile/pages/profile_page.dart`、`profile_header.dart` | `profile_design_page.dart` 已挂载成员 E `ProfilePage` | Profile 能展示头像、昵称、简介、统计、最近收藏、编辑入口 |
| E3-2 收藏统计展示 | 远端已有实现，待成员 E 确认/独立测试 | `profile_stats.dart`、`collection_list_provider.dart` 的 `userStatsProvider` | 调 `GET /api/users/:id/stats`；离线时用 fallback | 显示 totalCollections、categoryCount、publicCollections、recentCollections |
| E3-3 个人资料编辑页面 | 远端已有实现，待成员 E 确认/独立测试 | `edit_profile_page.dart`、`profile_providers.dart` | V1 本地 mock 保存 nickname/avatar/bio/preferences，不写后端 | Profile 有编辑入口；编辑页可打开、保存 mock 数据、返回 Profile |
| E3-4 登录 / 注册占位 | 远端已有实现，待成员 E 确认/独立测试 | `login_placeholder_page.dart`、`register_placeholder_page.dart`、`profile_providers.dart` | 纯前端 mock 登录状态，不接 JWT，不接真实用户接口 | 登录/注册页可打开；mock 登录后回 Profile；可退出登录 |
| E3-5 与成员 C 联调主页收藏展示 | 远端已有接入，待成员 E / 成员 C 确认 | `profile_exhibit_utils.dart`、`profile_collection_preview.dart`、`ProfilePage` | `ProfileCollectionPreview(embeddedInMemberEProfile: true)` 嵌入单页，避免重复统计区 | 最近收藏、空状态、详情跳转、公开预览不被破坏 |

---

## 6. 阶段四：图片识别和多风格故事

阶段四在远端最新分支中已有实现。当前实现看起来支持图片识别 mock / imageDescription 输入、多风格故事和 Add 页 Recognize 联调，但仍需成员 E 接管确认、独立测试和真实 UI 复测。

| 任务 | 当前状态 | 推荐文件 / 动作 | 技术路线 | 验收口径 |
|---|---|---|---|---|
| E4-1 图片识别 Prompt | 远端已有实现，待成员 E 确认/独立测试 | `docs/prompts/prompt_image.md`、`ai.prompts.js` | 输入图片描述 / imageUrl / 用户补充描述；输出 title、category、tags、description | 输出结构固定，分类仍为中文集合 |
| E4-2 图片识别接口方案 | 远端已有实现，待成员 E 确认/独立测试 | `ai.schemas.js`、`ai.service.js`、`ai.routes.js`、`verify_phase4_tasks1_5_api.js` | 新增 `POST /api/ai/analyze-image`；无 Vision 时可用 mock / imageDescription | 无图片能力时仍可演示；AI 失败不影响用户手动填表 |
| E4-3 多风格故事 Prompt | 远端已有实现，待成员 E 确认/独立测试 | `docs/prompts/prompt_story_styles.md`、`ai.prompts.js` | 支持 `concise`、`scrapbook`、`travel`、`vintage` 四种 style | 每种 style 有明确语气说明和 JSON 输出样例 |
| E4-4 扩展故事生成接口 | 远端已有实现，待成员 E 确认/独立测试 | `buildStoryPrompt()`、`generateStory()`、`validateStoryResponse()` | 沿用 `POST /api/ai/generate-story`，新增可选 `style` 参数；不新增重复故事接口 | 不传 style 保持旧行为；传 style 后输出符合风格 |
| E4-5 图片识别填表联调 | 远端已有接入，待成员 E / 成员 B 确认 | `AiSuggestionPanel`、`ai_image_analysis.dart`、Add 页 Recognize | 用户上传 / 模拟图片描述后点击 Recognize，建议写入标题/分类/标签/描述 | 能从 Add 页触发，失败时只提示，不阻塞保存 |

阶段四重要边界：

1. 图片上传、图片保存、collections 图片字段主要是成员 A / B 范围，成员 E 只消费图片 URL / 描述做 AI 建议。
2. 如果没有真实 Vision API key，优先保持 mock 可演示。
3. 新增接口必须同步 `AI_Routes_Integration.md` 或新增阶段四接口说明文档。

---

## 7. 阶段五：测试、Bug 跟踪和 Demo 支持

阶段五在远端最新分支中已有文档和脚本。后续主要工作是成员 E 接管确认、独立测试、补充复测记录、在需要时给成员 6 更新最终 Demo 材料。

| 任务 | 当前状态 | 推荐文件 / 动作 | 技术路线 | 验收口径 |
|---|---|---|---|---|
| E5-1 编写测试计划 | 远端已有文档，待成员 E 确认 | 根目录 `Test.md`、`member_E/docs/Phase5_Demo_Checklist.md` | 覆盖创建收藏、上传、AI、收藏墙、详情、Profile、Demo | 测试范围、环境、命令、人工路径清楚 |
| E5-2 编写核心测试用例 | 远端已有文档，待成员 E 确认 | 根目录 `Test.md` | TC-ME-P5-01～15 | 覆盖成员文档列出的核心路径 |
| E5-3 建立 Bug 跟踪表 | 远端已有文档，待成员 E 确认 | 根目录 `Test.md` | BUG-ME-001～005 | 每个 Bug 有状态，不混在聊天记录里 |
| E5-4 全链路 Demo 测试 | 远端已有脚本/记录，待独立复核 | `verify_phase5_demo_e2e.js`、`E_Test_Log.md`、`Test.md` | API 全链路 11/11，连续 2 轮；Flutter 手测清单另列 | Demo 路径可复现，失败点清楚 |
| E5-5 给成员 6 输出测试结论和 Demo 亮点 | 远端已有初稿，待成员 E 确认 | `member_E/docs/Member6_Demo_Handoff.md` | 汇总功能完成、AI 示例输出、Demo 流程、已知问题、PPT 可用结论 | 成员 6 可直接拿去写 PPT / 报告 / 视频稿 |

---

## 8. 技术路线明确度结论

| 范围 | 结论 | 说明 |
|---|---|---|
| 阶段一 | 已明确 | 已有 Prompt 文档、Contract、JS builder、schema、自检 |
| 阶段二 | 已明确，远端已有实现 | 已有 Provider、service、routes、根目录挂载、联调说明、自检；待成员 E 确认 |
| 阶段三 | 已明确，远端已有实现 | 当前实现位于 `frontend/lib/features/profile/`，并通过 Profile Tab 接入；待成员 E 确认 |
| 阶段四 | 已明确，远端已有实现 | 图片识别 mock / imageDescription、多风格故事和 Add 页联调已实现；待成员 E 确认 |
| 阶段五 | 已明确，远端已有文档/脚本 | 测试计划、Bug 表、Demo e2e 和成员 6 handoff 已出现；待成员 E 确认 |

如果新的 AI 发现实际代码与本文件冲突，应先停止并说明冲突，不要自行选择一条路线硬写。

---

## 9. 同伴更新兼容性记录（2026-05-22）

已检查 `origin/feature/member-1-task` 最新提交 `a26da25`：

1. 成员 A 新增 `rooms` 表。
2. `collections` 新增 `room_id` 字段。
3. 后端新增 `GET /api/rooms` 和 `GET /api/rooms/:id`。
4. Seed 数据变为每月一个 room，五月包含四类展品各 4 件。

当前 `memberE` 分支尚未合并该成员 A 更新。后续如果合并，应更新成员 E Profile / Room 相关路线：

1. `ProfilePage` 和成员 C room 入口优先读取后端 rooms API，而不是只依赖 `collectory_room_catalog.dart`。
2. Add / AI 填表如能选择 room，应写入 `roomId`。
3. Demo 测试需要新增 rooms API 和 `roomId` 回归用例。
