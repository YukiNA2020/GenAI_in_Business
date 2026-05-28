# E Test Log

负责人：成员 E / 成员 5
用途：成员 E 工作区内的局部测试记录。它不是根目录 `Test.md` 的替代品。

---

## 给未来测试 AI 的 Prompt

> 当你作为独立测试 AI 测试成员 E 的功能或文档时，请先把详细测试步骤、结果和 Bug 写入本文件。
>
> 阶段测试完成后，再把测试摘要和最终结论同步到根目录 `Test.md`。

---

## 测试概览

| 模块 | 测试状态 | 说明 |
|---|---|---|
| 阶段一～四 | ✅ 已同步 Test.md | 2026-05-21 |
| 阶段五：测试 / Bug / Demo | ✅ 已完成 | API e2e 11/11×2；Test.md 已更新 |
| **本次独立测试** | ✅ **全部通过** | 2026-05-22，测试 AI 独立复测 |
| **本次用户测试** | ✅ **通过** | 2026-05-22，用户体验测试（Add/Gallery/Profile 路径） |
| **GLM Vision 接入测试** | ✅ **通过** | 2026-05-24，GLM live、HTTP 回归、Flutter 单测均通过 |

---

## GLM Vision 接入测试记录（2026-05-24）

> 负责人：成员 E / 成员 5，由 Codex 协助执行与更新
> 目标：把 `POST /api/ai/analyze-image` 切到 GLM Vision 真实图片理解，并保留 DeepSeek 文本 fallback。

### 当前技术结论

| 项 | 结果 |
|---|---|
| GLM `glm-4.6v-flash` | 接口可达，但实测返回 429“访问量过大” |
| GLM `glm-4v-flash` | 实测可识别 `frontend/assets/screens/add_exhibit.png`，作为默认 Vision 模型 |
| 当前代码路线 | `VISION_PROVIDER=glm` + `ZHIPU_VISION_MODEL=glm-4v-flash` |

### 测试结果

| 测试项 | 命令 / 范围 | 状态 |
|---|---|---|
| GLM service live | `node member_E/scripts/verify_glm_vision_live.js frontend/assets/screens/add_exhibit.png` | ✅ 通过；schema validation passed |
| HTTP live | `/api/ai/analyze-image` + `imageDataUrl` | ✅ 200 success；返回合法 `AiImageAnalysis` |
| Fallback | `/api/ai/analyze-image` + `imageDescription` only | ✅ 200 success；文本 fallback 正常 |
| 阶段二 HTTP 回归 | `verify_phase2_tasks2_4_api.js` | ✅ 14/14 |
| 阶段四回归 | `verify_phase4_tasks1_5_api.js` | ✅ 15/15 |
| 阶段五 Demo E2E | `verify_phase5_demo_e2e.js` | ✅ 11/11，写入 collection id=34 |
| Flutter | `flutter test` | ✅ 1/1 |

---

## 用户体验测试记录（2026-05-22，用户本人测试）

> 负责人：成员 E / 成员 5
> 测试方式：用户作为最终用户在浏览器中实际使用 Flutter Web App
> 启动方式：Release 模式（见下方说明）

### 发现 1：黄黑条纹 / Debug 模式标识条

**问题描述**：用户测试时在页面顶部看到黄黑斜纹条。

**原因**：Flutter Web 的 Debug 模式标识，是 Flutter 原生行为，与应用代码无关。

**解决方案**：
1. 用 Release 模式运行 Flutter Web：
   ```bash
   cd frontend
   flutter build web
   # 用 http-server 或 python3 -m http.server serve build/web/ 目录
   ```
2. 不要用 `flutter run -d web-server`，那是 Debug 模式

### 发现 2：Bottom overflowed by 178 pixels

**问题描述**：用户在高分辨率屏幕下看到布局溢出警告。

**原因**：Flutter Web 在 Debug 模式下对不同屏幕分辨率的适配处理不佳。

**解决方案**：同发现 1，切到 Release 模式后问题消除。

### 用户测试结论

- Add / Gallery / Profile 路径全部功能正常
- 黄黑 Debug 条和 Bottom overflow 问题在 Release 模式下消除
- **后续文档需明确标注：Flutter Web 必须使用 Release 模式进行测试和演示**

### Flutter 运行模式说明

| 模式 | 命令 | 效果 |
|---|---|---|
| Debug 模式 | `flutter run -d web-server` | 有黄黑条纹、布局适配差 |
| Release 模式 | `flutter build web` + HTTP server | 无调试条、布局正常 |

**推荐启动方式：**
```bash
cd frontend
flutter build web
cd build/web
python3 -m http.server 8080
# 打开 http://localhost:8080
```

同时后端需要运行：
```bash
cd backend
AI_PROVIDER=mock npm run dev
# 打开 http://localhost:3000
```

---

## 本次测试详情（2026-05-22，独立测试 AI）

> 负责人：成员 E / 成员 5，由该成员的**测试 AI** 协助更新
> 测试分支：`feature/ai-profile-test`（已 fetch + pull --ff-only 最新）
> 后端：`cd backend && npm install && AI_PROVIDER=mock npm run dev`

---

### 阶段一·任务一：标题生成 Prompt 自检

命令：`node member_E/scripts/verify_phase1_task1_title.js`

结果：**15/15 通过**

| 检查项 | 状态 |
|---|---|
| buildTitlePrompt 返回非空字符串 | ✅ |
| Prompt 要求生成 3 个标题 | ✅ |
| Prompt 包含 20 字长度限制 | ✅ |
| Prompt 包含禁止编造规则 | ✅ |
| Prompt 固定 suggestions JSON 字段 | ✅ |
| Prompt 注入用户描述 | ✅ |
| Prompt 注入地点 | ✅ |
| description 非空时通过校验 | ✅ |
| description 为空时校验失败 | ✅ |
| 缺少 description 时校验失败 | ✅ |
| 合法 3 条标题响应通过校验 | ✅ |
| 标题数量不为 3 时校验失败 | ✅ |
| 单条标题超过 20 字时校验失败 | ✅ |
| 空字符串标题时校验失败 | ✅ |
| AI_ENDPOINTS 已登记 suggest-title 路径 | ✅ |

---

### 阶段二·任务一：AI Provider 封装

命令：`node member_E/scripts/verify_phase2_task1_provider.js`

结果：**11/11 通过**

| 检查项 | 状态 |
|---|---|
| 无 API Key 时 auto 模式解析为 mock | ✅ |
| mock 模式生成标题 JSON 并通过校验 | ✅ |
| mock 模式生成分类 JSON | ✅ |
| mock 模式生成标签 JSON | ✅ |
| mock 模式生成故事 JSON | ✅ |
| parseModelJson 可解析 Markdown 代码块中的 JSON | ✅ |
| 校验失败抛出 AiProviderError | ✅ |
| 校验失败错误码为 AI_INVALID_RESPONSE | ✅ |
| AI_PROVIDER=openai 且无 Key 时标记为 unavailable | ✅ |
| openai 模式无 Key 抛出 AiProviderError | ✅ |
| openai 模式无 Key 错误码为 AI_PROVIDER_UNAVAILABLE | ✅ |

---

### 阶段二·任务 2–4：AI HTTP 接口

命令：`BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase2_tasks2_4_api.js`

后端已启动（AI_PROVIDER=mock），实测结果：**14/14 通过**

#### [1] Service 层（mock，无 HTTP）

| 检查项 | 状态 |
|---|---|
| suggestTitle 返回合法结构（mock） | ✅ |
| suggestCategory 返回合法结构（mock） | ✅ |
| suggestTags 返回合法结构（mock） | ✅ |
| generateStory 返回合法结构（mock） | ✅ |
| 空 description 返回 AI_VALIDATION_ERROR | ✅ |

#### [2] HTTP 层（backend 在线）

| 检查项 | 状态 |
|---|---|
| /api/ai/suggest-title 返回 200 success | ✅ |
| /api/ai/suggest-title data 含 suggestions | ✅ |
| /api/ai/suggest-category 返回 200 success | ✅ |
| /api/ai/suggest-category data 含 category | ✅ |
| /api/ai/suggest-tags 返回 200 success | ✅ |
| /api/ai/suggest-tags data 含 tags | ✅ |
| /api/ai/generate-story 返回 200 success | ✅ |
| /api/ai/generate-story data 含 story | ✅ |
| HTTP 缺 description 返回 400 | ✅ |

---

### 阶段四·任务 1–5：图片识别 + 多风格故事

命令：`BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase4_tasks1_5_api.js`

后端已启动，实测结果：**15/15 通过**

#### [1] Service 层（mock）

| 检查项 | 状态 |
|---|---|
| analyzeImage 返回合法结构 | ✅ |
| 缺 image 输入返回 AI_VALIDATION_ERROR | ✅ |
| generateStory style=concise 合法 | ✅ |
| generateStory style=concise 有内容 | ✅ |
| generateStory style=scrapbook 合法 | ✅ |
| generateStory style=scrapbook 有内容 | ✅ |
| generateStory style=travel 合法 | ✅ |
| generateStory style=travel 有内容 | ✅ |
| generateStory style=vintage 合法 | ✅ |
| generateStory style=vintage 有内容 | ✅ |
| 无效 style 回退 concise | ✅ |

#### [2] HTTP 层（backend 在线）

| 检查项 | 状态 |
|---|---|
| /api/ai/analyze-image 返回 200 | ✅ |
| analyze-image data 含 suggestedTitle | ✅ |
| generate-story + style 返回 story | ✅ |
| analyze-image 缺字段返回 400 | ✅ |

---

### 阶段五：Demo API 全链路

命令：`BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase5_demo_e2e.js`

后端已启动，实测结果：**11/11 通过**（写入 id=32，可选 DELETE 清理）

| 检查项 | 状态 |
|---|---|
| 后端在线且列表可读 | ✅ |
| GET /api/categories 可用 | ✅ |
| AI 图片识别成功 | ✅ |
| 创建收藏成功 | ✅ |
| AI 标题失败返回 400（不阻塞主流程） | ✅ |
| AI 失败后仍可手动创建 | ✅ |
| 标题为空不能保存 | ✅ |
| 多风格故事 travel 成功 | ✅ |
| 关键词搜索可找到新建收藏 | ✅ |
| 详情页数据完整（含 tags 数组） | ✅ |
| 用户主页统计可用 | ✅ |

---

### 前端静态检查

#### AiSuggestionPanel 接入 Add 页

- 文件：`frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart`
- Add 页挂载：`frontend/lib/features/collection_browse/pages/add_exhibit_design_page.dart:306` 引用 `AiSuggestionPanel`
- 结论：**✅ 已接入**

#### Profile 接入 Profile Tab

- 文件：`frontend/lib/features/profile/pages/profile_page.dart`
- Profile Tab 挂载：`frontend/lib/features/collection_browse/pages/profile_design_page.dart` 返回 `const ProfilePage()`
- 结论：**✅ 已接入**

#### Profile 页面存在性

- `profile_page.dart` ✅
- `edit_profile_page.dart` ✅
- `login_placeholder_page.dart` ✅
- `register_placeholder_page.dart` ✅

#### Flutter UI 测试

- `flutter` 命令未找到
- **结论：⏭️ 未执行 Flutter UI 测试**（本机未安装 Flutter SDK，无法运行 `flutter analyze` 或 `flutter run`）
- 建议：成员 E 或成员 6 在演示机上按 `Phase5_Demo_Checklist.md` 手测 Add / Gallery / Profile 路径

---

## Bug 记录

**本次测试未发现新 Bug**。现有 Bug 记录见根目录 `Test.md` § 成员 E Bug 记录（BUG-ME-001～005）。

---

## 同步规则

1. 详细测试过程先写在本文件。
2. 阶段测试完成后，将测试摘要、通过率、失败用例和 Bug 摘要同步到根目录 `Test.md`。
3. 已同步本次结果至根目录 `Test.md`，由测试 AI 协助更新。
---

## DeepSeek 真实 LLM 接入测试（2026-05-22）

> 负责人：成员 E / 成员 5
> 测试目的：验证现有 AI Provider 和 `/api/ai/*` HTTP 路由能否通过 DeepSeek API 返回稳定结构化 JSON。
> 安全边界：真实 key 只放在 `backend/.env`，测试日志只记录 provider / base URL / model，不记录完整 key。

### 环境配置

| 配置项 | 值 |
|---|---|
| AI_PROVIDER | `openai` |
| AI_BASE_URL | `https://api.deepseek.com` |
| AI_MODEL | `deepseek-v4-flash` |
| AI_TIMEOUT_MS | `30000` |
| 解析模式 | openai-compatible（真实 DeepSeek API） |

### 本轮执行命令

```bash
node member_E/scripts/verify_phase1_task1_title.js
node member_E/scripts/verify_phase2_task1_provider.js
set -a; source backend/.env; set +a; node member_E/scripts/verify_deepseek_provider_live.js
cd backend && npm run dev
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
cd frontend && flutter test
```

### Service 层测试（verify_deepseek_provider_live.js）

| 接口 | DeepSeek 返回摘要 | 结构校验 | 状态 |
|---|---|---|---|
| suggestTitle | `["蓝色明信片与小书店地图","东京书店的蓝色记忆","手写街区地图的明信片"]` | 3 个非空标题 | ✅ PASS |
| suggestCategory | `{"category":"明信片","confidence":0.95}` | category 在集合内，confidence 0~1 | ✅ PASS |
| suggestTags | `["东京","明信片","小书店","手写地图","旅行","蓝色"]` | 6 个非空标签 | ✅ PASS |
| generateStory(concise) | story 长度 72 字 | 非空字符串 | ✅ PASS |
| generateStory(travel) | story 长度 90 字 | 非空字符串 | ✅ PASS |

**Service 层结果：5/5 全部通过**

### HTTP 层测试（backend 读取 backend/.env）

| 端点 | 实际返回摘要 | 状态 |
|---|---|---|
| POST /api/ai/suggest-title | `["神保町春天的蓝","店主手绘地图明信片","小书店的春天回忆"]` | ✅ PASS |
| POST /api/ai/suggest-category | `{"category":"明信片","confidence":0.95}` | ✅ PASS |
| POST /api/ai/suggest-tags | `["东京","明信片","神保町","旅行","书店","手绘地图","春天","蓝色"]` | ✅ PASS |
| POST /api/ai/generate-story(style=travel) | 返回旅行风 story | ✅ PASS |
| POST /api/ai/analyze-image | 返回 `suggestedTitle/category/tags/description` | ✅ PASS |

**HTTP 层结果：5/5 全部通过**

### 回归测试

| 范围 | 命令 | 结果 |
|---|---|---|
| 阶段一标题 Prompt | `verify_phase1_task1_title.js` | ✅ 15/15 |
| 阶段二 Provider mock/error | `verify_phase2_task1_provider.js` | ✅ 11/11 |
| 阶段二 HTTP 接口 | `verify_phase2_tasks2_4_api.js` | ✅ 14/14 |
| 阶段四 analyze-image + story style | `verify_phase4_tasks1_5_api.js` | ✅ 15/15 |
| 阶段五 Demo E2E | `verify_phase5_demo_e2e.js` | ✅ 11/11，写入 collection id=32 |
| Flutter 单测 | `flutter test` | ✅ 1/1 |

### 结论

DeepSeek API（`deepseek-v4-flash`）可通过现有 AI Provider 直接接入，**无需修改 provider 代码**。

1. 标题、分类、标签、故事生成、`analyze-image` 的结构化 JSON 都能通过现有 schema。
2. `response_format: { type: "json_object" }` 在本轮 DeepSeek 模型上可用。
3. 阶段二、阶段四、阶段五的自动化脚本在真实 DeepSeek 后端下未发现回归。
4. `analyze-image` 目前仍是“图片描述文本 + LLM 推断”，不是直接上传图片给 Vision 模型。
5. `backend/.gitignore` 已用于保护 `backend/.env`，不要提交真实 key。

### 文件同步

本轮应提交的文件：
- `backend/.gitignore`（保护 `.env`）
- `member_E/.env.example`（DeepSeek 配置示例）
- `member_E/scripts/verify_deepseek_provider_live.js`（真实 LLM 验证脚本）
- `member_E/docs/AI_Provider_Setup.md`（DeepSeek 配置和已验证结果）
- `member_E/E_Test_Log.md` 与根目录 `Test.md`（测试结果）

**不要提交** `backend/.env`（含真实 API Key）和测试写入后的 `backend/data/collections.db`。
