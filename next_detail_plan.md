# Collection Journey App 后 MVP 下一步行动计划

> 上次更新：2026-05-25
> 当前口径：核心 MVP 已经整合到 `codex/integration-prep`，不强制要求合并到 `main` 才算完成。
> 本文件用途：替代 `INTEGRATION_IMPLEMENTATION_PATH.md` 作为后续行动计划。旧整合路线文档保留为完成记录和技术审计材料。

---

## 1. 当前结论

当前项目已经达到 MVP 完成标准：

- 后端、前端、AI、Profile、Room、Create/Edit、Share Preview 都在同一个工作分支中可运行。
- 阶段 3、阶段 4、阶段 6、阶段 7 已按集成路径完成复测。
- 后端 API、AI API、Flutter test/analyze/build、浏览器主路径均已通过。
- 不要求立即合并到 `main`。只要交付时继续使用 `codex/integration-prep` 或基于它整理出的提交分支，就可以视为 MVP 已完成整合。

需要注意：

- 当前仓库仍保留历史分支和历史文档，这是开发过程记录，不代表产品仍分散。
- 如果后续要提交、展示或部署，应先整理当前工作树，确认 `git status` 中没有误带的临时文件。
- 后续开发不应再从旧阶段路线中重新执行已经完成的内容。

---

## 2. 从旧整合路线迁移过来的遗留项

以下事项来自 `INTEGRATION_IMPLEMENTATION_PATH.md` 的“合并前遗留”和后续测试反馈。它们不阻塞 MVP，但适合作为下一阶段计划。

| 事项 | 当前状态 | 下一步处理方式 |
|---|---|---|
| 最终分支整理 | MVP 已在 `codex/integration-prep` 集中完成 | 按团队需要决定：保留当前分支交付，或整理提交后再合并到 `main` |
| 成员 6 Demo 材料 | 功能路径已可截图，阶段 7 截图位于 `/private/tmp/phase7-*.png` | 演示前补最终截图、PPT、视频脚本和讲稿 |
| 成员 B / 成员 C / 成员 E 历史文档口径 | 功能已整合，但部分文档仍有旧阶段表达 | 在 `DOCUMENTATION_STATUS.md` 中标记为完成记录或历史参考，不再当作任务清单 |
| 编辑页 AI 故事辅助 | Create 页主路径可用；编辑页仍可进一步增强 | 可将 `AiSuggestionService.generateStory()` 接入 Edit flow，作为 P1 优化 |
| 全局离线体验 | 主要页面有 fallback 或错误态；尚未做统一离线 banner | 作为 UX polish，提高 Demo 稳定感 |
| 分享链接生产化 | Share Preview 可演示；真实公开链接/权限不是 MVP 范围 | 后续加入服务端 share token、visibility 权限与公开详情页 |
| 自动化测试体系 | 阶段脚本和 Flutter build 已通过；还不是 CI | 建议整理成一键测试脚本，并接入 GitHub Actions 或本地 release checklist |
| 线上部署 | 本地 Demo 已可运行；未部署生产环境 | 后续选择部署平台、数据库持久化和图片存储方案 |

---

## 3. 下一阶段建议优先级

### P0：交付前整理

目标：把已经完成的 MVP 变成可稳定交付的分支状态。

任务：

1. 检查当前分支和工作树。
2. 完整保留当前已经验证可运行的 MVP 基线，包括代码、数据库、seed 图片、演示截图、文档和测试脚本。
3. 只排除明确不应上传的内容，例如真实密钥、`.env`、依赖缓存、构建缓存、系统临时文件和与项目无关的本机产物。
4. 按功能或阶段整理提交记录。
5. 决定交付策略：继续使用 `codex/integration-prep`，或从它创建最终交付分支。

验收标准：

- `git status` 可解释；新增内容如果属于 MVP 运行、测试或展示材料，应随分支一起保留。
- README、Status、Test、API Contract、Documentation Status 都能反映当前 MVP 状态。
- 新成员从 README 启动项目不会依赖聊天上下文。

### P1：演示材料与成员 6 交付

目标：把可运行产品变成可展示材料。

任务：

1. 用 release build 重跑 Demo。
2. 截取最终页面：Home、Gallery、Room、Detail、Create/Edit、AI panel、Profile、Share Preview，并统一放入 `PictureofProduct/`。
3. 更新成员 6 handoff、PPT 文案和演示讲稿。
4. 录制一条 2-4 分钟 Demo 视频。
5. 准备故障备用方案：后端健康检查、seed 重置、无真实 AI key 时的 fallback 说法。

验收标准：

- PPT 和视频中展示的是当前整合分支，不是旧设计稿或旧分支截图。
- Demo 前可用 5 分钟 checklist 完整跑通。
- AI 真实调用失败时，也能解释 fallback 行为并继续演示核心流程。

### P1：编辑页 AI 增强

目标：让 Edit flow 与 Create flow 的 AI 体验更一致。

任务：

1. 在编辑页接入 AI 故事生成入口。
2. 复用 `AiSuggestionService.generateStory()`，避免新增后端合同。
3. 让 AI 失败保持非阻塞，保留用户手动编辑内容。
4. 补充编辑页手测记录。

验收标准：

- 编辑收藏时可重新生成故事。
- 不影响已有标题、分类、标签、图片和房间字段。
- 后端不需要新增 API。

### P2：体验打磨

目标：提高产品质感和演示稳定性。

任务：

1. 增加统一的后端离线提示或顶部状态提示。
2. 优化空状态，尤其是空房间、空搜索结果、空主页。
3. 补充加载骨架和错误重试入口。
4. 检查移动端小屏是否有按钮或文本溢出。
5. 统一 Room / Profile / Share Preview 的数据来源说明和 fallback 行为。

验收标准：

- 后端断开时，页面不会出现不可理解的错误栈或空白页。
- 所有核心页面在 390px 宽度下无明显文字重叠。
- 用户可以从错误态恢复或回到可用页面。

### P2：测试与 CI

目标：减少后续修改破坏 MVP 的风险。

任务：

1. 把现有阶段脚本整理成一个根目录测试入口。
2. 为后端 API 增加更稳定的自动化测试集合。
3. 为 Flutter 关键 provider 和表单逻辑补单元测试。
4. 选定至少一条 Playwright 或浏览器自动化路径：Create -> Gallery -> Detail -> Edit -> Profile。
5. 将测试命令接入 GitHub Actions 或本地交付 checklist。

验收标准：

- 一条命令可以完成核心 API 回归。
- Flutter test/analyze/build 的通过条件清楚。
- 测试失败时能定位到模块，而不是只靠人工浏览器手测。

### P3：生产化能力

目标：从课程/团队 Demo 走向真实可用产品。

任务：

1. 选择部署方式。
2. 替换本地 sql.js demo 数据库为可持久化数据库。
3. 替换本地 uploads 为对象存储。
4. 加入真实用户登录、用户数据隔离和权限控制。
5. 为公开分享加入 share token、访问统计和撤销能力。
6. 为 AI 调用加入成本控制、超时重试和内容安全策略。

验收标准：

- 刷新部署环境不会丢数据。
- 不同用户看不到彼此私密收藏。
- 公开分享可以被撤销或过期。
- AI key 不暴露给前端。

---

## 4. 建议的下一次工作顺序

如果继续由当前项目推进，建议按这个顺序：

1. 完成 P0 分支和提交整理。
2. 完成 P1 成员 6 Demo 材料。
3. 演示前只做低风险 bug 修复，不再大改数据结构。
4. 演示后再进入 P1/P2 的体验优化和测试体系建设。
5. 如果目标转为真实上线，再进入 P3 生产化计划。

---

## 5. 已完成路线的处理方式

以下文档不再作为“待完成任务清单”使用：

- `INTEGRATION_IMPLEMENTATION_PATH.md`
- `Status.md` 中早期阶段日志
- `Test.md` 中旧阶段测试表
- `member_E/docs/*Completion*.md`
- `past_doc/Product_v*_detail_plan.md`

它们的用途改为：

- 证明每个阶段做过什么。
- 解释为什么当前实现采用这些技术路线。
- 为回归测试和汇报提供上下文。

新任务请优先从本文件领取，除非团队明确重新打开某个历史阶段。
