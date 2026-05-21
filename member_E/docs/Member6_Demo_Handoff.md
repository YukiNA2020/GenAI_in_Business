# 成员 6 — Demo 与测试材料交接

> **负责人**：成员 E / 成员 5  
> **阶段**：阶段五·任务 5  
> **日期**：2026-05-21

---

## 1. 功能完成情况（可放 PPT）

| 模块 | 状态 | 说明 |
|------|------|------|
| AI 文字建议 | ✅ | 标题 / 分类 / 标签 / 故事（四按钮独立 loading） |
| AI 图片识别 | ✅ | `POST /api/ai/analyze-image` + Add 页 Recognize 填表 |
| 多风格故事 | ✅ | concise / scrapbook / travel / vintage |
| 用户主页 | ✅ | Profile + 成员 C 博物馆区单页嵌入 |
| 全链路 API | ✅ | 创建 / 搜索 / 详情 / stats（脚本 11/11 ×2） |

---

## 2. AI 示例输出（Demo 话术）

**图片识别（票根）**

```json
{
  "suggestedTitle": "复古展览票根",
  "suggestedCategory": "票根",
  "suggestedTags": ["展览", "票根", "复古"],
  "description": "这看起来像一张展览或活动票根。"
}
```

**多风格故事（travel）** — mock 示例：

> 路途上遇见它时，街道、光线和脚步都挤在同一张照片里。带回家后，它像一小段未完的旅程，提醒我曾经到过那里。

---

## 3. 推荐 Demo 流程（约 3 分钟）

```text
打开 App (Chrome :8090)
  → Add Tab：Upload → Recognize（自动填标题/分类/Story）
  → 选 Story style → Story → Draft 保存
  → Gallery：Collection wall 搜索刚保存标题
  → 点开详情
  → Profile：统计 + Recent + 成员 C 博物馆区
```

**前置**：`cd backend && AI_PROVIDER=mock npm run dev`

---

## 4. 已知问题与规避

| 问题 | 规避 |
|------|------|
| `analyze-image` 404 | 重启 backend，确保加载最新 `/api/ai` 路由 |
| AI 分类为中文名 | 写入 API 前用 `GET /api/categories` 映射 slug（Add 页已映射 Favorite tag） |
| AI 标签未进正式 Tag 字段 | Demo 用 SnackBar + 行内 `AI tags:` 展示；成员 B 正式页接 `TagInputField` |
| 无真实 Vision | Demo 用 Upload 写入 `imageDescription` 模拟 |
| Profile 用户名 Tong | 硬编码展示名；统计与 Recent 已接 API |

---

## 5. 测试结论（PPT  bullet）

- 阶段一～四成员 E 交付：**自动化专项通过**（见 `Test.md` 成员 E 各阶段表）。
- 阶段五全链路：**API Demo 脚本 11/11，连续 2 轮通过**（`verify_phase5_demo_e2e.js`）。
- Flutter UI 全路径：建议演示前按 `member_E/docs/Phase5_Demo_Checklist.md` 手测 1 遍。
- **结论**：Collectory AI 辅助记录与 Profile 联调 **可稳定 Demo**；AI 失败不阻塞手动保存。

---

## 6. 附件路径

| 材料 | 路径 |
|------|------|
| 测试计划与用例 | 根目录 `Test.md` § 成员 E 阶段五 |
| Bug 表 | `Test.md` § 成员 E Bug 记录 |
| Prompt 样例 | `member_E/docs/prompts/` |
| API 合同 | `member_E/docs/AI_API_Contract.md` |
| Demo 手测清单 | `member_E/docs/Phase5_Demo_Checklist.md` |
