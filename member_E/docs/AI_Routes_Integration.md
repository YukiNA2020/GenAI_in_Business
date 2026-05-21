# AI HTTP 接口说明（阶段二·任务 2–4）

负责人：成员 E / 成员 5

---

## 1. 端点

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/ai/suggest-title` | 3 个标题建议 |
| POST | `/api/ai/suggest-category` | 分类 + confidence |
| POST | `/api/ai/suggest-tags` | 3–8 个标签 |
| POST | `/api/ai/generate-story` | 故事草稿 |

请求体字段见 `AI_API_Contract.md` §2；**`description` 必填**。

---

## 2. 与根目录 backend 的集成（跨成员说明）

为使接口可被成员 B 联调，成员 E 在根目录做了**最小挂载**（已记入 `Status.md`）：

| 文件 | 变更 |
|---|---|
| `backend/src/app.js` | 增加 `app.use('/api/ai', require('./routes/ai.routes'))` |
| `backend/src/routes/ai.routes.js` | 适配层：注入 Express / zod / `response.js` 到 `member_E/.../createAiRouter` |

业务逻辑仍在 `member_E/backend/src/ai/`（`ai.service.js`、`ai.routes.js`）。

---

## 3. 启动与 curl 示例

```bash
cd backend
# 可选：在 backend/.env 设置 OPENAI_API_KEY；无 Key 时 AI_PROVIDER=auto 走 mock
AI_PROVIDER=mock npm run dev
```

```bash
curl -s -X POST http://localhost:3000/api/ai/suggest-title \
  -H "Content-Type: application/json" \
  -d '{"category":"明信片","location":"东京","description":"在小书店买的蓝色明信片"}'
```

---

## 4. 分类写入收藏时的 slug 映射

AI 返回的 `category` 为**中文名称**（如「明信片」）。写入 `POST /api/collections` 时需转为英文 slug（如 `postcard`），可调用 `GET /api/categories` 获取 `id` ↔ `name` 映射。
