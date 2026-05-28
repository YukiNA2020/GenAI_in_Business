# DeepSeek API 接入与真实 LLM 测试计划

负责人：成员 E / 成员 5  
更新时间：2026-05-22  
用途：给新的 AI 对话执行“DeepSeek API 接入和真实 LLM 测试”这一件事。不要在本任务中合并 rooms API、改成员 B 正式表单或做 Flutter 大改。

> 2026-05-22 更新：本计划已执行完成。DeepSeek service live 5/5、HTTP live 5/5、阶段 1/2/4/5 回归 66/66、Flutter 单测 1/1。详细结果见 `member_E/E_Test_Log.md` 和根目录 `Test.md`。

---

## 1. 目标

当前成员 E 的 AI 功能已经通过 mock 测试，但还没有接入真实 LLM。这个任务的目标是：

1. 使用 DeepSeek API 跑通现有 AI Provider。
2. 验证真实模型输出是否符合当前 JSON schema。
3. 必要时只做小范围 prompt / provider / 文档修复。
4. 把测试结果写入成员 E 测试记录。

本任务完成后，团队应该能回答：

> 成员 E 的 AI 标题、分类、标签、故事生成功能是否能用真实 DeepSeek 模型稳定返回结构化 JSON？

---

## 2. 当前代码基础

当前 AI Provider 已经支持 OpenAI-compatible API：

| 文件 | 作用 |
|---|---|
| `member_E/backend/src/ai/ai.provider.js` | 读取 `AI_API_KEY` / `OPENAI_API_KEY`、`AI_BASE_URL`、`AI_MODEL`，调用 `/chat/completions` |
| `member_E/backend/src/ai/ai.service.js` | 调用 provider，提供 title/category/tags/story/analyzeImage |
| `member_E/backend/src/ai/ai.routes.js` | Express 路由工厂 |
| `backend/src/routes/ai.routes.js` | 根目录后端适配层 |
| `backend/src/app.js` | 挂载 `/api/ai` |

DeepSeek 如果使用 OpenAI-compatible Chat Completions，理论上主要改环境变量，不需要重写 provider。

---

## 3. 分支和边界

| 项 | 要求 |
|---|---|
| 工作分支 | `feature/ai-profile-test` |
| 不使用 | 不要再新建或推送 `memberE` 分支 |
| 不提交密钥 | `.env`、API key、截图中含 key 的内容不能提交 |
| 不做范围 | 不合并成员 A rooms API；不接成员 B 正式表单；不做 Flutter UI 大改 |
| 可改范围 | AI provider 配置文档、`.env.example`、DeepSeek 测试脚本、prompt/schema 的小范围稳定性修复、测试记录 |

---

## 4. 环境变量建议

请在本地创建或更新 `backend/.env`，不要提交这个文件。

```env
AI_PROVIDER=openai
AI_API_KEY=填入你的_DeepSeek_API_Key
AI_BASE_URL=https://api.deepseek.com
AI_MODEL=deepseek-v4-flash
AI_TIMEOUT_MS=30000
```

说明：

1. 当前 provider 使用 `AI_API_KEY` 或 `OPENAI_API_KEY` 都可以。
2. `AI_PROVIDER=openai` 表示强制走真实 OpenAI-compatible provider；无 key 时会报错，不会回退 mock。
3. `AI_BASE_URL=https://api.deepseek.com`，provider 内部会请求 `${AI_BASE_URL}/chat/completions`。
4. `AI_TIMEOUT_MS` 建议先设为 `30000`，避免真实模型慢一点时误判失败。
5. 如果 `deepseek-v4-flash` 在当前账号不可用，可按 DeepSeek 控制台可用模型调整 `AI_MODEL`，但要记录到测试日志。

如果只想冒烟测试，也可以先不启动完整 backend，直接在命令行 export：

```bash
export AI_PROVIDER=openai
export AI_API_KEY=填入你的_DeepSeek_API_Key
export AI_BASE_URL=https://api.deepseek.com
export AI_MODEL=deepseek-v4-flash
export AI_TIMEOUT_MS=30000
```

---

## 5. 建议新增测试脚本

建议新增：

```text
member_E/scripts/verify_deepseek_provider_live.js
```

脚本目标：

1. 强制检查 `AI_PROVIDER=openai`。
2. 检查 `AI_API_KEY` 或 `OPENAI_API_KEY` 是否存在。
3. 用真实 DeepSeek 依次调用：
   - `suggestTitle`
   - `suggestCategory`
   - `suggestTags`
   - `generateStory`，至少测 `concise` 和 `travel`
4. 打印返回 JSON，但不要打印 API key。
5. 使用现有 schema 校验结果。
6. 失败时输出失败端点、错误码、错误 message。

示例输入可以使用：

```js
{
  title: "东京蓝色明信片",
  category: "明信片",
  location: "东京",
  dateAcquired: "2026-05-01",
  description: "在东京一家安静的小书店买到的蓝色明信片，背面有手写的街区地图。"
}
```

注意：

1. 不要把 DeepSeek 返回内容写死成断言。
2. 只校验结构，例如 `suggestions` 为 3 个非空标题、`tags` 为 3-8 个不重复标签。
3. 不要测试 `analyzeImage` 的真实视觉能力，因为当前实现仍基于 `imageDescription` / `imageUrl` 文本输入，不是真正的图片多模态上传。

---

## 6. 命令执行顺序

### 6.1 准备分支

```bash
git fetch --all --prune
git switch feature/ai-profile-test
git pull --ff-only origin feature/ai-profile-test
git status --short
```

如果 `git status` 有未提交改动，先停止并询问用户，不要覆盖。

### 6.2 安装后端依赖

```bash
cd backend
npm install
```

### 6.3 跑现有 mock 回归

回到项目根目录：

```bash
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
```

如果 mock 回归失败，先修 mock 回归，不要直接测 DeepSeek。

### 6.4 跑 DeepSeek Provider live 脚本

```bash
AI_PROVIDER=openai \
AI_API_KEY=填入你的_DeepSeek_API_Key \
AI_BASE_URL=https://api.deepseek.com \
AI_MODEL=deepseek-v4-flash \
AI_TIMEOUT_MS=30000 \
node member_E/scripts/verify_deepseek_provider_live.js
```

如果用户不希望 key 出现在 shell 历史中，请让用户自己 `export AI_API_KEY=...`，然后只运行：

```bash
AI_PROVIDER=openai \
AI_BASE_URL=https://api.deepseek.com \
AI_MODEL=deepseek-v4-flash \
AI_TIMEOUT_MS=30000 \
node member_E/scripts/verify_deepseek_provider_live.js
```

### 6.5 启动 backend 做 HTTP live 测试

终端 1：

```bash
cd backend
AI_PROVIDER=openai \
AI_API_KEY=填入你的_DeepSeek_API_Key \
AI_BASE_URL=https://api.deepseek.com \
AI_MODEL=deepseek-v4-flash \
AI_TIMEOUT_MS=30000 \
npm run dev
```

终端 2：

```bash
curl -s http://localhost:3000/api/health
```

然后测试 AI 端点：

```bash
curl -s -X POST http://localhost:3000/api/ai/suggest-title \
  -H "Content-Type: application/json" \
  -d '{"description":"在东京一家安静的小书店买到的蓝色明信片，背面有手写的街区地图。","category":"明信片","location":"东京"}'
```

同样测试：

1. `/api/ai/suggest-category`
2. `/api/ai/suggest-tags`
3. `/api/ai/generate-story`，带 `style: "travel"`

---

## 7. 判断标准

| 测试项 | 通过标准 |
|---|---|
| Provider live | 真实 DeepSeek 返回内容能被 `parseModelJson()` 解析 |
| 标题 | `suggestions` 为 3 个非空字符串，每个不超过 20 字 |
| 分类 | `category` 落在当前中文分类集合内，`confidence` 为数字 |
| 标签 | `tags` 为 3-8 个非空且不重复字符串 |
| 故事 | `story` 为非空字符串 |
| HTTP | `/api/ai/*` 返回 `{ success: true, data: ... }` |
| 失败兜底 | 故意缺 `description` 时返回 400 `AI_VALIDATION_ERROR` |
| 手动保存 | AI 失败不影响 `POST /api/collections` 手动创建 |

---

## 8. 常见问题和修复方向

### 8.1 真实模型没有返回纯 JSON

现有 provider 已尝试：

1. `response_format: { type: "json_object" }`
2. 从 Markdown code fence 中提取 JSON
3. 从首尾 `{}` 中提取 JSON

如果仍失败，优先改 Prompt 的输出约束，不要先改大架构。

建议加一句：

```text
只返回一个 JSON object，不要解释，不要 Markdown，不要代码块。
```

### 8.2 分类返回了英文或不在集合内

优先改分类 Prompt，强调只能返回：

```text
矿石、水晶、黑胶唱片、明信片、票根、旅行纪念品、其他
```

不要直接把 schema 放宽到任意字符串。

### 8.3 标题超过 20 字

优先改 Prompt 或在 service 层做保守截断。若截断，要记录到文档和测试日志。

### 8.4 DeepSeek 不支持当前 `response_format`

如果 API 返回与 `response_format` 相关的错误：

1. 先记录错误原文。
2. 可以在 provider 中根据 `AI_BASE_URL` 包含 `deepseek.com` 时不传 `response_format`。
3. 但必须加强 Prompt JSON 约束，并保留 parse/validate。

### 8.5 429 / 余额 / 权限问题

这不是代码失败。记录为环境问题，不要改业务代码。

---

## 9. 测试记录要求

测试完成后，必须更新：

1. `member_E/E_Test_Log.md`
2. 如结论需要团队知道，再更新根目录 `Test.md`
3. 如改了配置说明，再更新 `member_E/docs/AI_Provider_Setup.md`
4. 如新增脚本，更新 `member_E/README.md` 或本文件的脚本列表

记录必须包含：

1. 使用的 provider：DeepSeek
2. `AI_BASE_URL`
3. `AI_MODEL`
4. 测试时间
5. 哪些接口通过
6. 哪些接口失败
7. 是否修改代码
8. 是否有密钥泄露风险检查

不要记录完整 API key。

---

## 10. 给新 AI 的任务 Prompt

```text
我是成员 E / 成员 5。请你只做 DeepSeek API 接入和真实 LLM 测试，不要合并 rooms API，不要接成员 B 正式表单，不要做 Flutter 大改。

请先确认当前仓库是 YukiNA2020/GenAI_in_Business，当前分支是 feature/ai-profile-test。

开始前执行：
git fetch --all --prune
git switch feature/ai-profile-test
git pull --ff-only origin feature/ai-profile-test
git status --short

如果本地有未提交改动，请停止并告诉我，不要覆盖。

请先阅读：
README.md
Status.md
Test.md
member_E/README.md
member_E/docs/E_Current_Status_and_Plan.md
member_E/docs/DeepSeek_API_Integration_Test_Plan.md
member_E/docs/AI_Provider_Setup.md
member_E/backend/src/ai/ai.provider.js
member_E/backend/src/ai/ai.service.js
member_E/backend/src/ai/ai.schemas.js

我要自己提供 DeepSeek API key。不要把 key 写进任何会提交的文件，不要把完整 key 写入测试日志。

请做：
1. 检查现有 provider 是否可直接通过 AI_BASE_URL 接 DeepSeek。
2. 如需要，新增 member_E/scripts/verify_deepseek_provider_live.js。
3. 更新 .env.example / AI_Provider_Setup.md，说明 DeepSeek 配置方式。
4. 先跑现有 mock 回归。
5. 用我提供的 key 跑真实 DeepSeek provider live 测试。
6. 如后端可启动，再测 /api/ai/suggest-title、suggest-category、suggest-tags、generate-story 的 HTTP 层。
7. 把结果写入 member_E/E_Test_Log.md；如需要团队知道，再同步 Test.md。

边界：
1. 不要提交 .env 或 API key。
2. 不要修改 rooms、collection room、Profile room 逻辑。
3. 不要修改成员 B 正式表单。
4. 如果真实模型输出不稳定，优先小范围修改 Prompt 或 provider JSON 解析，记录原因。

完成后告诉我：
1. 改了哪些文件。
2. 跑了哪些命令。
3. DeepSeek 真实调用哪些通过、哪些失败。
4. 是否还有 mock 与真实模型行为不一致。
5. 当前 git status。
不要自动提交或 push，除非我明确要求。
```
