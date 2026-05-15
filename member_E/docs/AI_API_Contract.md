# AI API Contract - 阶段一

负责人：成员 E / 成员 5  
阶段：阶段一 - 任务 5  
目标：固定 AI 建议面板需要的输入、输出、错误格式和 loading 处理方式，方便成员 B / 成员 2 接入创建收藏页面。

---

## 1. 总体原则

1. V1 阶段先做文字 AI：标题、分类、标签、故事。
2. 所有 AI 返回必须是结构化 JSON。
3. AI 失败不能阻塞用户手动创建收藏。
4. 前端可以分别请求四个接口，也可以后续扩展为一个聚合接口。
5. 真实 Provider 可以是 OpenAI API 或 Claude API，但阶段一只固定合同，不绑定具体供应商。

---

## 2. 通用请求字段

```json
{
  "title": "东京蓝色明信片",
  "category": "明信片",
  "location": "东京",
  "dateAcquired": "2026-05-01",
  "description": "在一家小书店买到的蓝色明信片",
  "imageDescription": "一张蓝色调的城市风景明信片",
  "language": "zh-CN"
}
```

| 字段 | 类型 | 是否必填 | 用途 |
|---|---|---|---|
| `title` | string | 否 | 已有标题，可用于标签和故事生成 |
| `category` | string | 否 | 已选类别，可用于标题、标签和故事生成 |
| `location` | string | 否 | 收藏获得地点 |
| `dateAcquired` | string | 否 | 收藏获得日期 |
| `description` | string | 是 | 用户输入的基础描述 |
| `imageDescription` | string | 否 | 图片描述，V1 可由用户输入，V2 可由图片识别生成 |
| `language` | string | 否 | 默认 `zh-CN` |

---

## 3. 接口清单

### 3.1 标题建议

```text
POST /api/ai/suggest-title
```

请求：

```json
{
  "category": "明信片",
  "location": "东京",
  "dateAcquired": "2026-05-01",
  "description": "在一家小书店买到的蓝色明信片"
}
```

成功响应：

```json
{
  "success": true,
  "data": {
    "suggestions": ["东京蓝色明信片", "小书店的蓝色记忆", "那张蓝色明信片"]
  }
}
```

### 3.2 分类建议

```text
POST /api/ai/suggest-category
```

请求：

```json
{
  "title": "东京蓝色明信片",
  "description": "在一家小书店买到的蓝色明信片",
  "location": "东京",
  "imageDescription": "一张蓝色调的城市风景明信片"
}
```

成功响应：

```json
{
  "success": true,
  "data": {
    "category": "明信片",
    "confidence": 0.82
  }
}
```

### 3.3 标签推荐

```text
POST /api/ai/suggest-tags
```

请求：

```json
{
  "title": "东京蓝色明信片",
  "category": "明信片",
  "location": "东京",
  "description": "在一家小书店买到的蓝色明信片，想留作旅行记忆"
}
```

成功响应：

```json
{
  "success": true,
  "data": {
    "tags": ["东京", "明信片", "旅行", "书店"]
  }
}
```

### 3.4 故事生成

```text
POST /api/ai/generate-story
```

请求：

```json
{
  "title": "东京蓝色明信片",
  "category": "明信片",
  "location": "东京",
  "dateAcquired": "2026-05-01",
  "description": "在一家小书店买到的蓝色明信片，想留作旅行记忆"
}
```

成功响应：

```json
{
  "success": true,
  "data": {
    "story": "这张蓝色明信片是在东京一家小书店买到的。它不算昂贵，却像是把那天的街道、光线和慢慢挑选的心情一起留了下来。以后再看到它时，也许会想起那段安静而轻盈的旅行时间。"
  }
}
```

---

## 4. 错误响应

### 4.1 参数错误

HTTP 状态：`400`

```json
{
  "success": false,
  "error": {
    "code": "AI_VALIDATION_ERROR",
    "message": "description is required"
  }
}
```

### 4.2 AI 服务不可用

HTTP 状态：`502`

```json
{
  "success": false,
  "error": {
    "code": "AI_PROVIDER_UNAVAILABLE",
    "message": "AI suggestion is temporarily unavailable. You can still save manually."
  }
}
```

### 4.3 AI 输出格式错误

HTTP 状态：`502`

```json
{
  "success": false,
  "error": {
    "code": "AI_INVALID_RESPONSE",
    "message": "AI returned an invalid response format."
  }
}
```

---

## 5. 前端 loading 处理建议

成员 B / 成员 2 接入时建议：

1. 每个 AI 按钮单独 loading，例如“生成标题中...”。
2. loading 时只禁用当前 AI 按钮，不禁用整个创建表单。
3. AI 失败时展示轻提示，不阻止用户手动输入和保存。
4. 用户可以选择是否采用 AI 返回内容，不要自动覆盖用户已编辑内容。
5. 如果用户连续点击，前端应防抖或取消上一次请求。

---

## 6. 与成员 B 的联调确认项

| 确认项 | 当前约定 |
|---|---|
| 前端最少传入字段 | `description` |
| 标题建议返回数量 | 3 个 |
| 标签返回数量 | 3-8 个 |
| 分类范围 | 固定 7 类 |
| AI 失败是否影响保存 | 不影响 |
| 是否自动写入表单 | 用户点击采用后写入 |
| 是否支持一次生成全部 | 阶段二可扩展，阶段一先固定单接口 |
