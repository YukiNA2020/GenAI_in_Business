# 阶段二·任务五 — AI 建议面板（成员 E 代写，供成员 B 使用）

> **编写人**：成员 E / 成员 5（非成员 B 最终实现责任，仅为提前交付可复用组件）  
> **对应**：成员 E `Member_5_AI_Profile_Test_Detail_Plan.md` 阶段二任务 5；成员 B 阶段三任务 3–5 的前置接入

---

## 1. 交付物

| 文件 | 说明 |
|---|---|
| `frontend/lib/features/collection_form/services/ai_suggestion_service.dart` | 四个 `POST /api/ai/*` 客户端 |
| `frontend/lib/features/collection_form/widgets/ai_suggestion_panel.dart` | UI 面板（独立 loading、失败 SnackBar） |
| `frontend/lib/features/collection_form/models/ai_form_payload.dart` | 请求体 |
| `frontend/lib/features/collection_form/utils/ai_category_mapping.dart` | 中文 category ↔ slug ↔ Add 页 Tag |

**工作区副本**（与上表同源，供成员 B 认领）：

```text
member_B/frontend/lib/features/collection_form/
```

（与 `frontend/lib/features/collection_form/` 保持同步；以 `member_B/` 为归属说明。）

---

## 2. 已接入的 Demo 挂钩

成员 E 在成员 C 的 Add 页增加了**最小挂钩**（须成员 B 后续可重构为正式 `CreateCollectionPage`）：

- 文件：`frontend/lib/features/collection_browse/pages/add_exhibit_design_page.dart`
- 区块：`AiSuggestionPanel`（标注 Member E）
- 行为：
  - 用 **STORY NOTE** 作为 AI 的 `description`
  - 标题建议 → 填入 Title
  - 分类建议 → 映射到 Favorite tag
  - 标签建议 → SnackBar 展示（Add 页暂无多标签字段）
  - 故事建议 → 写入 Story（用户可继续编辑）

---

## 3. 成员 B 接手时建议

1. 将 `collection_form/` 迁入成员 B 正式的 `create_collection_page` / `CollectionForm`。
2. 扩展 `AiFormPayload`（`location`、`dateAcquired`、`imageDescription`）。
3. 标签建议接入 `TagInputField`（阶段一任务 5）。
4. 保存收藏时 `category` 使用 **英文 slug**（`GET /api/categories` 或 `ai_category_mapping.dart`）。

---

## 4. 运行与自测

```bash
cd backend && AI_PROVIDER=mock npm run dev
cd frontend && flutter run -d chrome
```

Add 页 → 先输入 Story note → 点 **Titles / Category / Tags / Story** → 采纳建议 → **Draft** 保存。

---

## 5. 原则（与 AI Contract 一致）

1. AI 失败**不**阻止手动保存。
2. 各 AI 按钮**独立** loading。
3. 不自动覆盖用户已编辑的标题（仅点击建议 chip 时写入）。
