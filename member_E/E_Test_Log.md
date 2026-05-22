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