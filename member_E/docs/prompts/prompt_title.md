# 标题生成 Prompt

负责人：成员 E / 成员 5  
阶段：阶段一 - 任务 1  
用途：根据用户输入生成 3 个收藏标题建议，供成员 B / 成员 2 的创建收藏页面接入。

---

## 1. 目标

根据用户输入的收藏类别、地点、日期和简短描述，生成 3 个中文标题建议。

要求：

1. 每个标题不超过 20 个中文字符。
2. 有情感，但不过度夸张。
3. 不编造用户没有提供的信息。
4. 不使用营销口吻。
5. 输出必须是稳定 JSON，不要输出 Markdown、解释文字或多余字段。

---

## 2. 输入字段

```json
{
  "category": "明信片",
  "location": "东京",
  "dateAcquired": "2026-05-01",
  "description": "在一家小书店买到的蓝色明信片"
}
```

字段说明：

| 字段 | 类型 | 是否必填 | 说明 |
|---|---|---|---|
| `category` | string | 否 | 用户选择或输入的收藏类别 |
| `location` | string | 否 | 收藏获得地点 |
| `dateAcquired` | string | 否 | 收藏获得日期 |
| `description` | string | 是 | 用户输入的收藏描述 |

---

## 3. Prompt 模板

```text
你是 Collection Journey App 的 AI 收藏记录助手。请根据用户提供的信息，为这件收藏品生成 3 个中文标题建议。

生成规则：
1. 每个标题不超过 20 个中文字符。
2. 标题要温暖、有个人记忆感，但不要夸张。
3. 不要编造用户没有提供的事实、品牌、地点、人物或事件。
4. 如果信息不足，请使用更中性的标题。
5. 只输出 JSON，不要输出 Markdown 或解释文字。

用户输入：
- 类别：{{category}}
- 地点：{{location}}
- 日期：{{dateAcquired}}
- 描述：{{description}}

请严格按照以下 JSON 格式输出：
{
  "suggestions": ["标题1", "标题2", "标题3"]
}
```

---

## 4. 输出格式

```json
{
  "suggestions": ["东京蓝色明信片", "小书店的蓝色记忆", "那张蓝色明信片"]
}
```

---

## 5. 异常处理建议

如果用户输入太少，仍然返回 3 个保守标题：

```json
{
  "suggestions": ["我的收藏记忆", "一件小小收藏", "值得保存的瞬间"]
}
```

---

## 6. 代码复用与自检

| 文件 | 说明 |
|---|---|
| `member_E/backend/src/ai/ai.prompts.js` | `buildTitlePrompt(input)` 将本节模板参数化，供阶段二 AI Provider 调用 |
| `member_E/backend/src/ai/ai.schemas.js` | `hasRequiredDescription()`、`validateTitleResponse()` 校验请求与响应 |
| `member_E/scripts/verify_phase1_task1_title.js` | 任务一本地自检（不调用真实 AI） |

自检命令（在项目根目录执行）：

```bash
node member_E/scripts/verify_phase1_task1_title.js
```

阶段二实现 `POST /api/ai/suggest-title` 时，成功响应的 `data` 结构须与本节输出格式一致，详见 `member_E/docs/AI_API_Contract.md` §3.1。
