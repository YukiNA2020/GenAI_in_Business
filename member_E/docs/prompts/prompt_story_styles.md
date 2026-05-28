# 多风格故事生成 Prompt

负责人：成员 E / 成员 5  
阶段：阶段四 - 任务 3  
用途：在阶段一故事 Prompt 基础上，按 `style` 生成不同语气的收藏故事。

---

## 1. 支持风格

| style | 名称 | 写作特征 |
|---|---|---|
| `concise` | 简洁风 | 克制、短句，100–120 字，少修辞 |
| `scrapbook` | 手账风 | 像手账旁注，可带「今天」「后来」等时间感 |
| `travel` | 旅行日记风 | 强调路途、场景与遇见，地点感更强 |
| `vintage` | 复古风 | 略带旧物与岁月感，语气舒缓 |

无效或未传 `style` 时默认 `concise`。

---

## 2. 请求示例

```json
{
  "title": "东京蓝色明信片",
  "category": "明信片",
  "location": "东京",
  "dateAcquired": "2026-05-01",
  "description": "在一家小书店买到的蓝色明信片",
  "style": "scrapbook"
}
```

---

## 3. 输出

与阶段一相同，仅返回：

```json
{
  "story": "生成的故事文本"
}
```

字数建议：100–150 个中文字符（`concise` 可略短）。

---

## 4. 与接口关系

- 端点：`POST /api/ai/generate-story`
- 新增可选字段：`style`（`concise` | `scrapbook` | `travel` | `vintage`）
- 实现：`buildStoryPrompt(input)` 根据 `style` 注入风格段落
