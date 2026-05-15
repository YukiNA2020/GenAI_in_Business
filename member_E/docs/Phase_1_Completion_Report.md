# 成员 E 阶段一完成说明

负责人：成员 E / 成员 5，由该成员的 AI 工具协助更新  
日期：2026-05-15  
阶段：阶段一 - V1.1 AI Prompt 模板和接口方案

---

## 1. 已完成任务

| 任务 | 状态 | 交付物 |
|---|---|---|
| 任务 1：设计标题生成 Prompt | 已完成 | `docs/prompts/prompt_title.md` |
| 任务 2：设计分类建议 Prompt | 已完成 | `docs/prompts/prompt_category.md` |
| 任务 3：设计标签推荐 Prompt | 已完成 | `docs/prompts/prompt_tags.md` |
| 任务 4：设计故事生成 Prompt | 已完成 | `docs/prompts/prompt_story.md` |
| 任务 5：确定 AI API Contract | 已完成 | `docs/AI_API_Contract.md` |

---

## 2. 额外交付

为方便阶段二接口开发，额外补充了两个轻量 JS 文件：

1. `backend/src/ai/ai.prompts.js`：四类 Prompt builder。
2. `backend/src/ai/ai.schemas.js`：类别、端点、错误码和响应校验函数。

这些文件目前放在 `member_E/` 中，不直接影响根目录后端结构。后续如果成员 A / 成员 1 搭好后端，可以再协商迁移到根目录 `backend/src/ai/`。

---

## 3. 给成员 B / 成员 2 的接入说明

创建收藏页面 AI 建议面板可以优先接入四个接口：

```text
POST /api/ai/suggest-title
POST /api/ai/suggest-category
POST /api/ai/suggest-tags
POST /api/ai/generate-story
```

前端最少需要传 `description`。如果有 `category`、`location`、`dateAcquired`、`title` 或 `imageDescription`，可以一起传给后端提高生成质量。

AI 失败时不要阻止用户保存收藏，只需要提示用户“AI 建议暂时不可用，可以继续手动填写”。

---

## 4. 待独立测试

阶段一开发自检范围：

1. 文件是否创建齐全。
2. Prompt 是否满足稳定 JSON 输出要求。
3. API Contract 是否覆盖输入、输出、错误和 loading。
4. JS 文件是否能被 Node.js 正常解析。

已执行的开发自检：

```text
node --check member_E/backend/src/ai/ai.prompts.js
node --check member_E/backend/src/ai/ai.schemas.js
node -e "...require ai.prompts / ai.schemas and validate sample title response..."
```

自检结果：命令均正常结束，示例 Prompt builder 和标题响应校验函数可用。

仍建议后续由独立测试 AI 按 README 中的测试模板检查，并把结果补充到根目录 `Test.md`。
