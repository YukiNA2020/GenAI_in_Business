# Collection Journey App 文档状态索引

> 上次更新：2026-05-25
> 负责人：成员 E / 成员 5，由 Codex 协助整理；2026-05-25 由 Codex 同步统一整合完成状态和后 MVP 计划
> 范围：本仓库中的项目 Markdown 文档；不包含 `backend/node_modules/` 下的第三方依赖文档。

本文件是全项目的 Markdown 文档索引。开始任何任务前，先看这里，确认哪些文档是当前依据，哪些只是历史计划、完成记录、测试记录或模块交接文档，避免把旧计划误当成新任务。

当前口径：核心 MVP 已经整合完成并集中在 `codex/integration-prep`。不要求一定合并到 `main` 才算完成；旧分支和旧路线文档保留为开发过程记录。

---

## 1. 文档状态标签

| 标签 | 含义 | 使用方式 |
|---|---|---|
| `当前权威` | 当前产品方向、协作流程、分工、状态或测试结论的主要依据 | 开发前必须阅读；有变化时及时更新 |
| `活跃任务说明` | 仍然有用的成员任务定义、职责边界或验收标准 | 任务完成后也不要删除；实际完成情况以 `Status.md` / `Test.md` 为准 |
| `活跃模块说明` | 当前模块的运行说明、接口说明、交接说明或实现指南 | 保留在对应代码附近，方便联调和测试 |
| `完成记录` | 阶段完成报告、测试记录、Prompt 记录、Demo 交接材料 | 作为审计和汇报依据，不要当成未完成任务列表 |
| `已完成路线` | 曾经用于推进阶段整合或技术路线决策，现在已执行完毕 | 只用于追溯过程；新任务应迁移到当前计划文档 |
| `历史参考` | 早期规划、旧版本路线、立项参考资料 | 只用于理解背景，不作为当前开发依据 |
| `已替代或过时` | 已被新文档或新分支状态替代 | 需要团队确认后再归档或删除 |
| `低优先级内部文件` | Flutter / 平台生成的说明文件或资源说明 | 除非正在改对应平台资源，否则忽略 |

---

## 2. 当前推荐阅读顺序

任何新任务建议按这个顺序阅读：

1. `README.md`
2. `DOCUMENTATION_STATUS.md`
3. `next_detail_plan.md`
4. `Project_intro.md`
5. `Status.md`
6. 如果涉及测试或判断完成度，再读 `Test.md`
7. `API_Contract.md`
8. `Final_Team_Work_Division.md`
9. 对应成员的任务文档
10. 对应模块的 README / handoff / integration 文档
11. 只有需要追溯整合过程时，再读 `INTEGRATION_IMPLEMENTATION_PATH.md`
12. 只有需要追溯历史决策时，再读 `Prompt_library.md`

不要用 `past_doc/` 直接安排当前任务。那些文件是早期“按产品版本拆开发”的规划；当前项目已经改为“按成员分工 + 分支整合”推进。

---

## 3. 根目录文档

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `README.md` | 当前权威 | 项目入口、启动说明、项目构成、测试命令、当前分支口径 | 所有成员和 AI 的第一入口 |
| `next_detail_plan.md` | 当前权威 | MVP 完成后的下一步行动计划 | 旧整合路线中的遗留优化已迁移到这里 |
| `DOCUMENTATION_STATUS.md` | 当前权威 | 全项目 Markdown 文档索引和清理规则 | 新增、移动、删除或重新定位文档时要更新 |
| `INTEGRATION_IMPLEMENTATION_PATH.md` | 已完成路线 | 本轮统一整合的分阶段实施路径和技术审计记录 | 核心 MVP 已按此路线完成；后续不要把其中旧阶段当成新任务 |
| `Project_intro.md` | 当前权威 | 产品方向、目标用户、价值主张、长期路线 | 只决定产品方向；开发中不要随意改写 |
| `Final_Team_Work_Division.md` | 当前权威 | 六人分工、职责边界、合并原则、Demo 验收标准 | 当前团队分工的主要依据 |
| `Status.md` | 当前权威 | 当前项目状态 + 历史进展记录 | 顶部为当前 MVP 完成状态；旧日期备注保留为完成记录 |
| `Test.md` | 当前权威 | 测试结果、Bug、验证状态 | 判断功能是否真的通过测试时优先看这里 |
| `Prompt_library.md` | 完成记录 | 用户要求、AI 行动、关键决策的历史日志 | 不是当前任务清单 |
| `API_Contract.md` | 当前权威 | 当前统一整合基线下的冻结 API 合同 | V2.0 已包含 `roomId`、`/api/rooms`、`/api/ai/*`；2026-05-25 live contract 18/18 |
| `Backend_Setup.md` | 活跃模块说明 | 后端启动、接口使用、排错说明 | 基础启动说明仍可用；rooms / `roomId` 细节以 `API_Contract.md` V2.0 为准 |
| `PictureofProduct/README.md` | 完成记录 | 当前 MVP 产品截图目录说明 | 用于课程展示、产品介绍和成员 6 演示材料 |
| `PictureofProduct/使用指南.md` | 完成记录 | 当前 MVP 中文使用指南 | 和截图一起用于向非开发者介绍产品流程 |

---

## 4. 成员任务文档

这些文档定义成员职责和验收标准。核心 MVP 范围内的成员任务已经完成整合；这些文件现在主要用于追溯分工、验收边界和历史实现依据，不再作为新的待办队列。后续任务以 `next_detail_plan.md` 为准。

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `Member_1_Core_API_Data_Detail_Plan.md` | 活跃任务说明 | 成员 A / 成员 1：后端、数据、核心 API 任务定义 | 很多任务已完成；实际完成情况看 `Status.md` 和 `Test.md` |
| `Member_2_Create_Upload_Integration_Detail_Plan.md` | 活跃任务说明 | 成员 B / 成员 2：创建、编辑、上传、最终整合任务定义 | 当前正式 Create flow 主路径已接入并复测；历史任务边界仍以本文档为准 |
| `Member_3_Collection_Wall_Search_Detail_Plan.md` | 活跃任务说明 | 成员 C / 成员 3：收藏墙、详情、搜索、浏览任务定义 | 当前实现主要在 `frontend/`；运行和测试看前端文档 |
| `Member_4_UI_Visual_Design_Detail_Plan.md` | 活跃任务说明 | 成员 D / 成员 4：UI 视觉和设计支持任务定义 | 实际视觉交付主要在 `design-export/` |
| `member_E/Member_5_AI_Profile_Test_Detail_Plan.md` | 活跃任务说明 | 成员 E / 成员 5：AI、Profile、测试任务定义 | 需要配合 `member_E/docs/E_Current_Status_and_Plan.md` 阅读，避免重复开发已完成内容 |

---

## 5. 前端与设计文档

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `frontend/README.md` | 活跃模块说明 | Flutter 前端运行说明和功能概览 | 当前推荐用于 Web release 演示 |
| `frontend/Browse_Flow_Test_Notes.md` | 活跃模块说明 | 浏览、详情、编辑、Room、Share 等手测路径 | 做 Flutter 手动测试时使用 |
| `frontend/demo-screenshots/README.md` | 完成记录 | 给成员 6 的 Demo 截图清单 | 最终截图变化时再更新 |
| `design-export/collectory-ui-handoff.md` | 活跃模块说明 | UI 风格、Figma handoff、组件规范 | 前端视觉调整的主要参考 |
| `frontend/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | 低优先级内部文件 | Flutter 生成的 iOS 启动图说明 | 除非改 iOS 启动图，否则忽略 |

---

## 6. 成员 B 文档

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `member_B/README.md` | 活跃模块说明 | 成员 B 工作区说明 | 当前说明了只有 AI 面板相关文件被预填 |
| `member_B/docs/Phase2_Task5_AI_Panel_by_Member_E.md` | 活跃模块说明 | 成员 E 写给成员 B 的 AI 建议面板交接 | 把 AI 面板迁入正式创建表单时要读 |
| `member_B/frontend/lib/features/collection_form/README.md` | 活跃模块说明 | collection form AI 面板文件说明 | 较窄的模块说明 |

---

## 7. 成员 E 当前入口文档

做成员 E 相关任务时，优先读这些。

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `member_E/README.md` | 活跃模块说明 | 成员 E 工作区总览 | 当前入口，已修正分支口径 |
| `member_E/TODO_Guide.md` | 活跃模块说明 | 成员 E 下一步任务和依赖判断 | 分支变化后需要保持更新 |
| `member_E/docs/E_Current_Status_and_Plan.md` | 当前权威 | 成员 E 当前基线、下一步计划、整合优先级 | 成员 E 的第一技术入口 |
| `member_E/docs/E_Technical_Route_Map.md` | 当前权威 | 成员 E 全阶段技术路线、代码落点、兼容记录 | 写代码或判断边界时使用 |
| `member_E/E_Status_Log.md` | 完成记录 | 成员 E 局部状态日志 | 重要结论要同步到根目录 `Status.md` |
| `member_E/E_Prompt_Log.md` | 完成记录 | 成员 E 局部 Prompt / 决策日志 | 重要决策要同步到根目录 `Prompt_library.md` |
| `member_E/E_Test_Log.md` | 完成记录 | 成员 E 局部测试记录 | 重要测试结论要同步到根目录 `Test.md` |

---

## 8. 成员 E AI 与整合文档

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `member_E/docs/AI_API_Contract.md` | 活跃模块说明 | 成员 E AI 接口合同 | 补充根目录 `API_Contract.md` 中没有的 AI 细节 |
| `member_E/docs/AI_Provider_Setup.md` | 活跃模块说明 | AI Provider、mock、DeepSeek-compatible 配置说明 | 不包含真实 key |
| `member_E/docs/AI_Routes_Integration.md` | 活跃模块说明 | `/api/ai` 路由挂载和联调说明 | 当前 AI HTTP 端点说明 |
| `member_E/docs/DeepSeek_API_Integration_Test_Plan.md` | 完成记录 | DeepSeek 接入和真实 LLM 测试计划 | 测试已经完成；保留为审计记录，不是未来任务清单 |
| `member_E/docs/Phase5_Demo_Checklist.md` | 活跃模块说明 | 成员 E 相关 Demo 手测清单 | 最终 Demo 回归时使用 |
| `member_E/docs/Member6_Demo_Handoff.md` | 活跃模块说明 | 给成员 6 的 Demo / PPT 交接材料 | 统一整合后需要再更新最终结论 |

---

## 9. 成员 E 完成报告与 Prompt 文档

这些是完成证据或 Prompt 参考，不是未完成任务列表。

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `member_E/docs/Phase_1_Completion_Report.md` | 完成记录 | 成员 E 阶段一完成说明 | 保留 |
| `member_E/docs/Phase_3_Profile_Completion.md` | 完成记录 | Profile 阶段完成说明 | 保留 |
| `member_E/docs/Phase_3_Task5_Member3_Integration.md` | 完成记录 | 与成员 C 的 Profile 联调说明 | 保留 |
| `member_E/docs/Phase_4_Tasks1_5_Completion.md` | 完成记录 | 图片识别与多风格故事完成说明 | 保留 |
| `member_E/docs/Phase_5_Tasks1_5_Completion.md` | 完成记录 | 测试与 Demo 阶段完成说明 | 保留 |
| `member_E/docs/prompts/prompt_title.md` | 完成记录 | 标题生成 Prompt 规格 | Prompt 参考 |
| `member_E/docs/prompts/prompt_category.md` | 完成记录 | 分类建议 Prompt 规格 | Prompt 参考 |
| `member_E/docs/prompts/prompt_tags.md` | 完成记录 | 标签推荐 Prompt 规格 | Prompt 参考 |
| `member_E/docs/prompts/prompt_story.md` | 完成记录 | 故事生成 Prompt 规格 | Prompt 参考 |
| `member_E/docs/prompts/prompt_image.md` | 完成记录 | 图片识别 Prompt 规格 | 当前已切到 GLM Vision 主路径，并保留 `imageDescription` 文本 fallback |
| `member_E/docs/prompts/prompt_story_styles.md` | 完成记录 | 多风格故事 Prompt 规格 | Prompt 参考 |
| `member_E/frontend/lib/features/profile/README.md` | 活跃模块说明 | Profile 模块说明 | 较窄的源码旁说明 |

---

## 10. 历史规划文档

| 文件 | 状态 | 当前用途 | 备注 |
|---|---|---|---|
| `past_doc/Product_v1_detail_plan.md` | 历史参考 | 早期按产品版本拆分的规划 | 不作为当前开发任务依据 |
| `past_doc/Product_v2_detail_plan.md` | 历史参考 | 早期按产品版本拆分的规划 | 不作为当前开发任务依据 |
| `past_doc/Product_v3_detail_plan.md` | 历史参考 | 早期按产品版本拆分的规划 | 不作为当前开发任务依据 |
| `past_doc/Product_v4_detail_plan.md` | 历史参考 | 早期按产品版本拆分的规划 | 不作为当前开发任务依据 |
| `past_doc/Product_v5_detail_plan.md` | 历史参考 | 早期按产品版本拆分的规划 | 不作为当前开发任务依据 |

---

## 11. 后续需要补的文档缺口

| 缺口 | 影响 | 建议处理时间 |
|---|---|---|
| 成员 6 Demo 截图说明尚未整理进交付文档 | 阶段 7 浏览器手测已过，但展示材料需要以最后 UI 截图为准 | 最终提交前更新 `member_E/docs/Member6_Demo_Handoff.md` 和截图说明 |
| `Status.md` 的更早历史备注里仍可能有旧的“待测试”表述 | 读者可能把旧日期记录误认为当前状态 | 优先看顶部项目文件表、统一整合准备分支进展和 `Test.md`；以后碰到相关段落再顺手清 |
| 成员 B 正式创建表单的历史交接文档未完全改写 | 当前主路径已接入 `CreateCollectionPage`，但 `member_B/` 早期交接文档仍保留阶段二口径 | 保留历史交接属性；最终交付前可补一段“已迁入主入口”的说明 |
| 成员 E 图片识别文档仍需最终 Demo 复核 | GLM Vision live、HTTP 回归和 Flutter 单测已通过；最终团队 Demo 仍需 Flutter 手测复核 | 演示前按 `Phase5_Demo_Checklist.md` 再跑一轮 |
| 分支引用容易过期 | 文档可能提到已删除或被替代的远端分支 | 每次清理分支后同步更新本文件、`README.md` 和成员 TODO 文档 |

---

## 12. 清理规则

1. 不要因为成员任务已经完成，就删除成员任务文档。它们是验收合同和职责边界。
2. 不要把 `Prompt_library.md` 当成当前任务列表。它是历史记录。
3. 除非用户明确要看历史产品方案，否则不要用 `past_doc/` 指导当前开发。
4. 项目级状态写进根目录文档；成员内部细节写进成员文件夹。
5. 如果某份文档被替代，先在本文件标明替代关系，再决定是否删除或归档旧文档。
6. 如果某个分支引入新 API，整合时必须更新根目录 `API_Contract.md` 和本文件。
