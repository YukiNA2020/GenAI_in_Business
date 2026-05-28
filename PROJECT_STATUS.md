# Project Status — Collection Journey App

> 当前分支：`codex/integration-prep`
> 最后更新：2026-05-28
> MVP 状态：✅ 已完成整合

---

## 1. MVP 已完成

核心功能已在 `codex/integration-prep` 验证通过：
- 后端 API + AI API + Flutter build/test/analyze ✅
- Create → Gallery → Detail → Edit → Profile 主路径 ✅
- Share Preview / Room / Categories / Stats ✅
- 不要求合并到 `main`，当前分支可作为交付基准

---

## 2. 已知问题一览

| # | 问题 | 优先级 | 状态 |
|---|------|--------|------|
| 8 | 英文化 AI 合同迁移（schema / prompt / mock / 前端映射 / 测试脚本） | 🔴 P0 | ✅ 已验证完成（2026-05-27） |
| 5 | AI 故事风格切换时内容追加而非替换 | 🔴 高 | ✅ 已修复（2026-05-28） |
| 6 | Profile "Favorite tags" 筛选逻辑与 Gallery/Room 不一致 | 🟡 中 | ❌ 未处理 |
| 7 | AI Suggestions 面板"（Member E）"标注应移除 | 🟢 低 | ✅ 已处理（2026-05-27） |
| 1 | Room Reflection Redo 按钮无功能 | 🟡 中 | ✅ 已完成（2026-05-28） |
| 3 | Room 月份不一致（前端硬编码 vs 后端 API） | 🟡 中 | ❌ 未处理 |
| 4 | RoomSelectorRow 字符长度不一致导致排版问题 | 🟢 低 | ✅ 已验证完成（2026-05-28） |
| 2 | AI 空输入时灵活度不足 | 🟢 低 | ❌ 未处理 |

**✅ 已处理**：`0990e6e` 引入的英文 category schema 已与 AI prompt/mock、Vision prompt、前端 `ai_category_mapping.dart`、Create/Add 调用点、成员 B 交接副本和验证脚本完成同步。2026-05-27 回归验证已通过：Phase 1 / Phase 2 provider / Phase 2 HTTP / Phase 4 HTTP / Phase 5 demo E2E / Flutter test / Flutter analyze。

---

## 3. 下一步计划（来自 `next_detail_plan.md`）

| 优先级 | 任务 | 说明 |
|--------|------|------|
| P0 | 分支和提交整理 | 整理 MVP 为可交付状态 |
| P1 | 成员 6 Demo 材料 | 截图 / PPT / 视频 / 讲稿 |
| P1 | 编辑页 AI 故事辅助接入 | 复用 `generateStory()` |
| P2 | 体验打磨（离线 banner / 空状态 / 骨架屏） | 提高演示稳定性 |
| P2 | 测试与 CI | 一键测试脚本 + GitHub Actions |

---

## 4. 最近提交记录

| Commit | 作者 | 说明 |
|--------|------|------|
| `698e288` | YukiNA | docs: 记录问题5—AI故事风格切换时内容追加而非替换 |
| `0990e6e` | huangxiangrong45-ux | backend\data里数据全改为英文了 |
| `ce63d11` | YukiNA | 记录 Post-MVP 问题：新文档 + 移除过期 BUG-ME-006 |
| `3364f1a` | YukiNA | 完成MVP整合并更新交付文档 |

---

## 5. 领取任务方法

1. 从 `codex/integration-prep` 拉取最新
2. 从上方"已知问题一览"选一个任务
3. 完成后更新本文档对应状态列
4. 推送后通知其他成员

> 不要从旧阶段文档（`INTEGRATION_IMPLEMENTATION_PATH.md` 等）领取已完成的任务。

---

## 6. 文档索引

| 文档 | 用途 |
|------|------|
| `Post_MVP_Issues.md` | 已发现问题的详细记录（根因 / 解决方案 / 涉及代码） |
| `next_detail_plan.md` | P0-P3 下一步行动计划 |
| `Test.md` | 历史测试记录，已不再作为任务清单 |
| `DOCUMENTATION_STATUS.md` | 全项目文档索引 |
