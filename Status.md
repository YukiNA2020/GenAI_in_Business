# 给未来 AI 的 Prompt

> **重要**：
> 每当你完成任何开发工作后（包括但不限于：完成某个功能、修复 bug、创建文件、修改文件），都必须更新本文件的以下部分：
> - 上次更新时间
> - 项目文件列表（如有新文件）
> - 开发阶段进度（如有进展）
> - 待办事项（如有新任务或完成的任务）
> - 备注（如有重要的进展或问题）
>
> 更新时必须写明本次修改负责人是成员 A/B/C/D/E 或成员 6；如果是 AI 工具协助完成，也要写明“由该成员的 AI 工具协助更新”。这样其他成员能确认哪个人写了哪里。
>
> 当前实际开发以 `Final_Team_Work_Division.md`、根目录成员任务文档和各成员文件夹中的任务文档为准；成员 E 的任务文档位于 `member_E/Member_5_AI_Profile_Test_Detail_Plan.md`。`past_doc/` 文件夹中的五份 `Product_v*_detail_plan.md` 暂时不用来进行实际任务开发，仅作为项目立项时的一种参考方案。
>
> 保持 Status.md 是最新状态，让未来的 AI 和开发者能快速了解项目当前情况。

---

# Collection Journey App - 项目状态

> 上次更新：2026-05-15  
> 最近更新负责人：成员 E / 成员 5，由该成员的 AI 工具协助更新

---

## 项目结构

```
GENAI_Group/
├── README.md                    # 团队协作入口、GitHub 流程和 AI 工具使用说明
├── Project_intro.md              # 产品介绍与开发路线（核心指导文件）
├── Status.md                     # 项目状态（本文档）
├── Prompt_library.md             # Prompt 记录库
├── Test.md                       # 测试情况记录
├── Final_Team_Work_Division.md    # 最终 6 人分工方案
├── Member_1_Core_API_Data_Detail_Plan.md # 成员 1 开发任务详细文档
├── Member_2_Create_Upload_Integration_Detail_Plan.md # 成员 2 开发任务详细文档
├── Member_3_Collection_Wall_Search_Detail_Plan.md # 成员 3 开发任务详细文档
├── Member_4_UI_Visual_Design_Detail_Plan.md # 成员 4 设计与开发支持详细文档
├── member_E/
│   ├── README.md                 # 成员 E 工作区说明
│   ├── Member_5_AI_Profile_Test_Detail_Plan.md # 成员 5 开发任务详细文档
│   ├── E_Status_Log.md           # 成员 E 局部状态记录
│   ├── E_Prompt_Log.md           # 成员 E 局部 Prompt 和决策记录
│   ├── E_Test_Log.md             # 成员 E 局部测试记录
│   ├── docs/
│   │   ├── AI_API_Contract.md    # 阶段一 AI API Contract
│   │   ├── Phase_1_Completion_Report.md # 成员 E 阶段一完成说明
│   │   └── prompts/              # 阶段一四类 AI Prompt 文档
│   └── backend/src/ai/           # 阶段一轻量 Prompt 和 Schema 代码
├── past_doc/
│   ├── Product_v1_detail_plan.md # 立项参考方案，暂不作为实际开发任务依据
│   ├── Product_v2_detail_plan.md # 立项参考方案，暂不作为实际开发任务依据
│   ├── Product_v3_detail_plan.md # 立项参考方案，暂不作为实际开发任务依据
│   ├── Product_v4_detail_plan.md # 立项参考方案，暂不作为实际开发任务依据
│   └── Product_v5_detail_plan.md # 立项参考方案，暂不作为实际开发任务依据
└── business-model-canvas+Grp_I.pdf  # 商业模式画布（原始资料）
```

---

## 项目文件

| 文件 | 说明 | 状态 |
|------|------|------|
| `README.md` | 团队协作入口、GitHub 流程、AI 工具使用说明 | ✅ 完成 |
| `Project_intro.md` | 产品介绍与开发路线规划 | ✅ 完成 |
| `business-model-canvas+Grp_I.pdf` | 商业模式画布（原始资料） | ✅ 完成 |
| `past_doc/Product_v1_detail_plan.md` | V1.0 早期技术规划，立项参考方案 | 🟡 参考，不直接用于实际开发 |
| `past_doc/Product_v2_detail_plan.md` | V2.0 早期技术规划，立项参考方案 | 🟡 参考，不直接用于实际开发 |
| `past_doc/Product_v3_detail_plan.md` | V3.0 早期技术规划，立项参考方案 | 🟡 参考，不直接用于实际开发 |
| `past_doc/Product_v4_detail_plan.md` | V4.0 早期技术规划，立项参考方案 | 🟡 参考，不直接用于实际开发 |
| `past_doc/Product_v5_detail_plan.md` | V5.0 早期技术规划，立项参考方案 | 🟡 参考，不直接用于实际开发 |
| `Final_Team_Work_Division.md` | 最终 6 人分工方案 | ✅ 完成 |
| `Member_1_Core_API_Data_Detail_Plan.md` | 成员 1 收藏数据与核心 API 详细任务 | ✅ 完成 |
| `Member_2_Create_Upload_Integration_Detail_Plan.md` | 成员 2 创建收藏、图片上传与整合详细任务 | ✅ 完成 |
| `Member_3_Collection_Wall_Search_Detail_Plan.md` | 成员 3 收藏墙、浏览与搜索详细任务 | ✅ 完成 |
| `Member_4_UI_Visual_Design_Detail_Plan.md` | 成员 4 UI 视觉设计与功能逻辑详细任务 | ✅ 完成 |
| `member_E/Member_5_AI_Profile_Test_Detail_Plan.md` | 成员 5 AI、用户主页与测试详细任务 | ✅ 已移入成员 E 工作区 |
| `member_E/E_Status_Log.md` | 成员 E 局部状态记录，用于阶段结束后同步根目录 Status | ✅ 完成 |
| `member_E/E_Prompt_Log.md` | 成员 E 局部 Prompt 和决策记录，用于阶段结束后同步根目录 Prompt_library | ✅ 完成 |
| `member_E/E_Test_Log.md` | 成员 E 局部测试记录，用于阶段结束后同步根目录 Test | ✅ 完成 |
| `member_E/docs/prompts/prompt_title.md` | 成员 E 阶段一标题生成 Prompt | ✅ 完成，待独立测试 |
| `member_E/docs/prompts/prompt_category.md` | 成员 E 阶段一分类建议 Prompt | ✅ 完成，待独立测试 |
| `member_E/docs/prompts/prompt_tags.md` | 成员 E 阶段一标签推荐 Prompt | ✅ 完成，待独立测试 |
| `member_E/docs/prompts/prompt_story.md` | 成员 E 阶段一故事生成 Prompt | ✅ 完成，待独立测试 |
| `member_E/docs/AI_API_Contract.md` | 成员 E 阶段一 AI API 输入输出和错误合同 | ✅ 完成，待独立测试 |
| `member_E/backend/src/ai/ai.prompts.js` | 成员 E 阶段一 Prompt builder | ✅ 完成，待独立测试 |
| `member_E/backend/src/ai/ai.schemas.js` | 成员 E 阶段一 Schema、类别、错误码和校验函数 | ✅ 完成，待独立测试 |
| `Prompt_library.md` | Prompt 记录库 | ✅ 完成 |
| `Status.md` | 项目状态文档 | ✅ 完成 |
| `Test.md` | 测试记录、Bug 跟踪和测试报告文档 | ✅ 完成 |

---

## 开发阶段进度

### V1.0 核心价值验证版
- [x] 产品规划
- [x] 技术路线文档
- [ ] 开发实施

### V1.1 最小收藏记录闭环
- [ ] 待开发

### 成员 E 阶段一：V1.1 AI Prompt 模板和接口方案
- [x] 任务 1：设计标题生成 Prompt
- [x] 任务 2：设计分类建议 Prompt
- [x] 任务 3：设计标签推荐 Prompt
- [x] 任务 4：设计故事生成 Prompt
- [x] 任务 5：确定 AI API Contract
- [x] 独立测试 AI 验证阶段一交付物（开发自检 6/6 通过；待独立测试 AI 进一步验证）

### V1.2 AI 辅助记录
- [ ] 待开发

### V1.3 美观收藏卡片墙
- [ ] 待开发

### V1.4 收藏详情与基础管理
- [ ] 待开发

### V1.5 基础搜索与筛选
- [ ] 待开发

### V2.0 收藏体验强化版
- [ ] 待开发

### V3.0 分享与增长版
- [ ] 待开发

### V4.0 个性化与付费价值版
- [ ] 待开发

### V5.0 商业生态扩展版
- [ ] 待开发

---

## 技术栈（计划）

| 层级 | 技术选型 |
|------|----------|
| 前端 | Flutter / React Native |
| 后端 | Node.js + Express |
| 数据库 | SQLite → PostgreSQL |
| AI 能力 | OpenAI API / Claude API |
| 图片存储 | 本地存储 → S3/OSS |

---

## 待办事项

- [x] 补充 README 团队协作说明、GitHub 流程和 AI 工具使用规则
- [x] 补充清空上下文后的开发 AI / 测试 AI 标准 Prompt 和交接流程
- [x] 创建 `member_E/` 工作区并移入成员 E 技术路线文件
- [x] 为成员 E 建立局部状态、Prompt 和测试记录文件
- [x] 完善成员文件夹局部记录到根目录主文档的同步规则
- [x] 完成成员 E 阶段一 AI Prompt 模板和 API Contract
- [x] 由独立测试 AI 测试成员 E 阶段一交付物并更新 `Test.md`
- [x] 在核心状态同步文档中增加成员 A-E / 成员 6 身份标记规则
- [x] 将 `past_doc/` 中旧版本规划标记为立项参考方案，不直接用于实际开发
- [ ] 确定技术选型（前端框架、是否需要后端等）
- [x] 根据 `Final_Team_Work_Division.md` 确认最终 6 人分工，其中前 5 人负责开发，第 6 人负责 PPT、报告、视频和 Demo 展示材料
- [x] 为 5 位开发成员分别创建详细开发任务文档
- [ ] 搭建开发环境
- [ ] MVP 开发（V1.1 ~ V1.3）
- [ ] 产品 Demo 制作

---

## 备注

项目尚处于规划阶段，尚未开始实际开发。2026-05-08 已根据 `Final_Team_Work_Division.md` 重新确认最终分工：成员 1-5 负责开发相关工作，成员 6 负责 PPT、报告、视频和 Demo 展示材料。已新增 5 份成员开发任务详细文档，分别对应数据/API、创建上传、收藏墙搜索、UI 视觉设计、AI/主页/测试。

2026-05-09 已补充团队协作入口与文档兼容规则：实际开发以 `Final_Team_Work_Division.md` 和五份成员任务文档为准；`past_doc/` 中五份旧版 `Product_v*_detail_plan.md` 暂时不用来进行实际任务开发，仅为项目立项时的一种参考方案。之后所有状态同步、Prompt 记录和测试记录都必须标明负责人是成员 A/B/C/D/E 或成员 6。

2026-05-09 进一步补充 README 中的“清空上下文后的标准开发流程”：成员可以用固定 Prompt 让开发 AI 阅读仓库文档并完成指定阶段任务，再交给另一个独立测试 AI 测试并更新 `Test.md`。同时明确开发 AI 不负责最终测试结论和 GitHub 提交，测试通过后由成员本人提交。

2026-05-15 成员 E / 成员 5 已建立 `member_E/` 工作区，并将 `Member_5_AI_Profile_Test_Detail_Plan.md` 移入该文件夹。已完成成员 E 阶段一的四类 AI Prompt 文档、AI API Contract、轻量 Prompt builder 和 Schema 校验文件。开发自检 6/6 通过，待独立测试 AI 进一步验证。

2026-05-15 已为成员 E 增加三个局部记录文件：`E_Status_Log.md`、`E_Prompt_Log.md`、`E_Test_Log.md`。之后成员 E 日常开发可先在 `member_E/` 内记录局部状态；每个阶段结束、测试结论变化、或出现跨成员影响时，再将摘要同步到根目录 `Status.md`、`Prompt_library.md` 和 `Test.md`。

2026-05-15 开发自检完成：Node.js 语法检查通过，两个 JS 文件功能抽样 10/10 通过，四类 Prompt 文档与 API Contract 一致性核对通过。更新 `E_Test_Log.md` 和根目录 `Test.md`，测试结论标记为"开发自检通过"，待独立测试 AI 验证。
