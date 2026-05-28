# 阶段五·任务 4 — Flutter Demo 手测清单

> **负责人**：成员 E / 成员 5  
> 与 `verify_phase5_demo_e2e.js`（API 层）互补；**至少完整走 2 遍**后可在 `Test.md` 勾选 UI 项。

---

## 前置

```bash
cd backend && AI_PROVIDER=mock npm run dev
cd frontend && flutter run -d chrome
```

---

## Demo 路径（成员 E 验收）

| 步 | 操作 | 预期 | 轮次1 | 轮次2 |
|----|------|------|-------|-------|
| 1 | 打开 App | 四 Tab 可见 | ☐ | ☐ |
| 2 | **Add** → Upload | SnackBar「Demo photo attached」 | ☐ | ☐ |
| 3 | **Recognize** | 标题 / TAG / Story note / AI tags 行更新 | ☐ | ☐ |
| 4 | 选 **Story style** → **Story** | Story note 更新，SnackBar 提示风格 | ☐ | ☐ |
| 5 | **Draft** 保存 | 「Exhibit saved via API」并回到 Gallery | ☐ | ☐ |
| 6 | **Gallery** → Collection wall 搜索标题 | 能找到新卡片 | ☐ | ☐ |
| 7 | 打开详情 | 标题/故事/标签区完整 | ☐ | ☐ |
| 8 | **Profile** | 四列统计 + Recent + 成员 C 区可滚动 | ☐ | ☐ |
| 9 | AI 空 Story note → **Titles** | SnackBar 提示需 description，表单仍可编辑 | ☐ | ☐ |
| 10 | 清空标题 → **Draft** | 「Title is required」，不保存 | ☐ | ☐ |

---

## 记录

- 执行人 / 日期：__________
- 轮次1 通过：__ / 10  
- 轮次2 通过：__ / 10  
- 备注：__________
