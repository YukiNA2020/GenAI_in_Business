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
export OPENAI_API_KEY=sk-...
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
