# AI Provider 配置说明

负责人：成员 E / 成员 5  
阶段：阶段二 - 任务 1  
文件：`member_E/backend/src/ai/ai.provider.js`

---

## 1. 职责

`generateJson(prompt, { validate, mockKind })` 负责：

1. 读取环境变量中的 API Key 与 Provider 配置。
2. 调用 OpenAI Chat Completions（`response_format: json_object`）。
3. 使用 `AI_TIMEOUT_MS` 控制超时。
4. 捕获网络/供应商错误并映射为 `AI_PROVIDER_UNAVAILABLE`。
5. 解析模型输出并通过 `validate` 校验后返回结构化 JSON。

---

## 2. 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `OPENAI_API_KEY` | — | OpenAI API Key（也可用 `AI_API_KEY`） |
| `AI_PROVIDER` | `auto` | `auto` / `openai` / `mock` |
| `AI_MODEL` | `gpt-4o-mini` | Chat 模型名称 |
| `AI_TIMEOUT_MS` | `15000` | 请求超时（毫秒） |
| `AI_BASE_URL` | `https://api.openai.com/v1` | 兼容 OpenAI 协议的 Base URL |

### DeepSeek 配置示例

DeepSeek 可按 OpenAI-compatible provider 方式接入。不要提交真实 key。

> **⚠️ 不要把真实 API Key 写入文档或测试日志。Key 只能出现在 `backend/.env` 中，且 `.env` 必须添加到 `.gitignore`。**

```env
AI_PROVIDER=openai
AI_API_KEY=YOUR_DEEPSEEK_API_KEY_HERE
AI_BASE_URL=https://api.deepseek.com
AI_MODEL=deepseek-v4-flash
AI_TIMEOUT_MS=30000
```

**配置步骤：**

1. 复制 `member_E/.env.example` 为 `backend/.env`（如果还没有）。
2. 在 `backend/.env` 中取消 DeepSeek 相关注释，填入真实 key。
3. 在 `backend/` 目录启动后端：`npm run dev`。如果 `.env` 中没有写 `AI_PROVIDER=openai`，也可以临时用 `AI_PROVIDER=openai npm run dev`。

**冒烟测试（不需要启动 backend）：**

```bash
export AI_API_KEY=YOUR_DEEPSEEK_API_KEY_HERE
AI_PROVIDER=openai \
AI_BASE_URL=https://api.deepseek.com \
AI_MODEL=deepseek-v4-flash \
AI_TIMEOUT_MS=30000 \
node member_E/scripts/verify_deepseek_provider_live.js
```

**DeepSeek live 验证脚本：**

```bash
node member_E/scripts/verify_deepseek_provider_live.js
```

该脚本会依次调用 `suggestTitle`、`suggestCategory`、`suggestTags`、`generateStory(concise)`、`generateStory(travel)`，并用现有 schema 做结构校验。不会打印 API Key。

详细执行步骤见 `member_E/docs/DeepSeek_API_Integration_Test_Plan.md`。

**2026-05-22 实测结果：**

| 范围 | 结果 | 备注 |
|---|---|---|
| DeepSeek service live | ✅ 5/5 | 标题、分类、标签、concise story、travel story |
| DeepSeek HTTP live | ✅ 5/5 | `suggest-title`、`suggest-category`、`suggest-tags`、`generate-story`、`analyze-image` |
| 成员 E 自动化回归 | ✅ 55/55 | 阶段一 15、阶段二 Provider 11、阶段二 HTTP 14、阶段四 15 |
| 阶段五 Demo E2E | ✅ 11/11 | 真实 DeepSeek 后端下写入 collection id=32 |
| Flutter 单测 | ✅ 1/1 | `flutter test` |

结论：当前 DeepSeek 配置可用，现有文字 provider 不需要额外改代码。`analyze-image` 的真实图片理解由独立的 GLM Vision provider 负责，见下方配置。

### GLM Vision 配置示例

GLM Vision 只用于 `POST /api/ai/analyze-image` 的真实图片理解；标题、分类、标签、故事生成仍走 DeepSeek 文字链路。不要提交真实 key。

```env
VISION_PROVIDER=glm
ZHIPU_API_KEY=YOUR_ZHIPU_API_KEY_HERE
ZHIPU_API_BASE_URL=https://open.bigmodel.cn/api/paas/v4
ZHIPU_VISION_MODEL=glm-4v-flash
ZHIPU_VISION_TIMEOUT_MS=45000
ZHIPU_VISION_MAX_IMAGE_BYTES=20971520
```

**2026-05-24 实测判断：**

| 范围 | 结果 | 备注 |
|---|---|---|
| GLM `glm-4v-flash` imageDataUrl | ✅ 可用 | 同一张本地 PNG 截图可被正确识别 |
| GLM `glm-4.6v-flash` | ⚠️ 暂不默认使用 | 实测返回 429“访问量过大” |
| `verify_glm_vision_live.js` | ✅ 可执行 | 使用本地图片转 data URL，不打印 key / base64 |

运行：

```bash
node member_E/scripts/verify_glm_vision_live.js frontend/assets/screens/add_exhibit.png
```

### 模式说明

- **auto**：有 Key 时走 OpenAI，无 Key 时走 mock（本地开发/Demo 推荐）。
- **openai**：强制真实 API；无 Key 时抛出 `AI_PROVIDER_UNAVAILABLE`。
- **mock**：不调用外部 API，返回符合 Contract 的示例 JSON。

---

## 3. 本地自检

```bash
# 默认 mock（无需 API Key）
node member_E/scripts/verify_phase2_task1_provider.js

# 使用真实 OpenAI（需自行 export OPENAI_API_KEY）
export AI_PROVIDER=openai
export OPENAI_API_KEY=YOUR_OPENAI_API_KEY
node -e "
const p=require('./member_E/backend/src/ai/ai.provider');
const b=require('./member_E/backend/src/ai/ai.prompts');
const s=require('./member_E/backend/src/ai/ai.schemas');
p.generateJson(b.buildTitlePrompt({description:'测试明信片'}),{validate:s.validateTitleResponse})
  .then(console.log).catch(console.error);
"
```

---

## 4. 与阶段二后续任务的关系

任务 2–4 的 Express 路由（`ai.routes.js` / `ai.service.js`）将调用本文件的 `generateJson()`，不在任务 1 范围内。合并到根目录 `backend/src/ai/` 前需与成员 A 确认目录与挂载路径。
