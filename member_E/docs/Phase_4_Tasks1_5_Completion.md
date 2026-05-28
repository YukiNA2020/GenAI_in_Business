# 阶段四·任务 1–5 完成说明（V2.3）

> **负责人**：成员 E / 成员 5

---

## 交付清单

| 任务 | 交付物 |
|---|---|
| 1 图片识别 Prompt | `docs/prompts/prompt_image.md` |
| 2 图片识别接口 | `POST /api/ai/analyze-image`（`ai.service.analyzeImage`） |
| 3 多风格故事 Prompt | `docs/prompts/prompt_story_styles.md` |
| 4 扩展故事接口 | `generate-story` + `style` 参数 |
| 5 与成员 2 联调 | Add 页 Upload → Recognize → 自动填表 |

---

## 自检

```bash
node member_E/scripts/verify_phase4_tasks1_5_api.js
# 服务层 mock：12/12

cd backend && AI_PROVIDER=mock npm run dev
BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase4_tasks1_5_api.js
```

---

## 前端验收（Add Tab）

1. 点 **Upload** → 写入 demo `imageDescription`
2. 点 **Recognize** → 填入标题、Favorite tag、Story note、AI tags 行
3. 选 **Story style** → **Story** → 故事按风格生成

---

## 成员 B 接手

- 源码副本：`member_B/frontend/lib/features/collection_form/`
- 正式创建页接入同样回调：`onImageAnalysisApplied`、`hasImageForAnalysis`
