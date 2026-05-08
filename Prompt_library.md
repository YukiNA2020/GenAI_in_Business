# 给未来 AI 的 Prompt

> 当你与用户对话时，必须在对话结束后将以下内容记录到 `Prompt_library.md` 中：
> 1. **用户的要求**：用简短的语言总结用户的意图（不需要原封不动地记录，说清楚意思即可）
> 2. **你的行动**：你具体做了什么、创建了什么文件、给出了什么建议
> 3. **其他重要内容**：AI 在行动中认为值得记录的关键信息，如风险点、技术选型决策、产品方向等
> 4. **负责人标识**：必须标明本次工作对应成员 A/B/C/D/E 或成员 6；如果是 AI 工具协助，也要写明“由该成员的 AI 工具协助更新”
>
> 格式示例：
> ```
> ## [日期] 对话记录
>
> - **负责人**：成员 A / 成员 1，由该成员的 AI 工具协助更新
> - **用户要求**：创建文件专门记录 Prompt
> - **AI 行动**：创建了 Prompt_library.md，并在顶部编写了给未来 AI 的 Prompt
> - **重要内容**：记录了对话中涉及的文件创建内容和技术细节
> ```

---

# Prompt 记录库

## 2026-05-09 对话记录 2

- **负责人**：团队开发与测试 AI 分工流程整理，由 AI 协助更新
- **用户要求**：确认在清空上下文后，只给 AI 输入“我是成员A，请帮我完成阶段一任务一并交给我测试”这类 Prompt，AI 是否能够阅读文档后完成开发；如果不够稳妥，就在 README 中补充更清晰的多人协作开发流程、开发 AI Prompt、测试 AI Prompt 和 GitHub 提交流程。
- **AI 行动**：
  - 阅读了现有 `README.md`、`Prompt_library.md` 和 `Status.md`。
  - 在 `README.md` 中新增“清空上下文后的标准开发流程”，把成员拉取仓库、开发 AI 编码、测试 AI 独立测试、成员本人提交 GitHub 的流程写成固定步骤。
  - 在 `README.md` 中新增开发 AI 输入模板和测试 AI 输入模板，要求 AI 先阅读指定文档、只处理对应成员和阶段任务、不要擅自修改其他成员模块、不要替成员提交 GitHub。
  - 在 `README.md` 中明确五位开发成员的身份、Prompt 写法和对应成员文档。
  - 更新 `Status.md`，记录本次 README 协作流程补充。
- **重要内容**：
  - 清空上下文后，AI 只要能读取仓库文件，理论上可以根据 README 和成员文档继续开发。
  - 为了减少误读，推荐不要只输入一句短 Prompt，而是使用 README 中的开发 AI 模板。
  - 开发 AI 和测试 AI 要分工：开发 AI 负责编码和必要状态同步；测试 AI 独立测试并更新 `Test.md`；成员本人负责最终 GitHub 提交。

## 2026-05-09 对话记录

- **负责人**：团队文档协作规则整理，由 AI 协助更新
- **用户要求**：阅读过往文档，解决五份成员分工文档和旧版开发路线文档之间的不兼容问题；在 README 中说明团队如何用 GitHub 和 AI 工具协作；在状态同步文档中增加“开发完成后必须标明自己是成员 A-E 或成员 6”的规则；给 `past_doc` 中五份旧文档加标记，说明暂时不用这些文档进行实际任务开发，仅作为项目立项参考方案。
- **AI 行动**：
  - 阅读了 `Project_intro.md`、`Status.md`、`Prompt_library.md`、`Test.md`、`Final_Team_Work_Division.md`、五份 `Member_*.md` 成员任务文档，以及 `past_doc/` 中五份旧版产品规划文档。
  - 重写并补充 `README.md`，使其成为团队成员和各自 AI 工具进入项目时的第一入口。
  - 更新 `Project_intro.md` 顶部“给未来 AI 的 Prompt”，加入 README、最终分工、五份成员任务文档和 `past_doc` 的阅读说明。
  - 更新 `Status.md`、`Prompt_library.md` 和 `Test.md` 的状态同步规则，要求每次更新必须标明负责人身份。
  - 给 `past_doc/Product_v1_detail_plan.md` 到 `past_doc/Product_v5_detail_plan.md` 增加醒目标记，说明这些文档仅为立项参考，不作为当前实际任务开发依据。
- **重要内容**：
  - 当前实际开发依据是 `Final_Team_Work_Division.md` 和五份成员任务文档。
  - 成员 A-E 分别对应成员 1-5，成员 6 负责 PPT、报告、视频和 Demo 展示材料。
  - 所有成员开始工作前应先从 GitHub 拉取最新代码，完成任务后通过自己的功能分支提交并发起 Pull Request。
  - 所有状态同步文档必须记录“负责人标识”，避免多人协作后无法确认修改来源。

## 2026-05-06 对话记录

- **用户要求**：创建文件专门记录 Prompt
- **AI 行动**：
  - 阅读了 Project_intro.md（产品介绍文档）和 business-model-canvas+Grp_I.pdf（PDF课件）
  - 确认了 md 文件前 12 节产品介绍与 PDF 描述一致
  - 评估了开发路径的可行性，指出了风险点和优化建议
  - 创建了 Product_v1_detail_plan.md、Product_v2_detail_plan.md、Product_v3_detail_plan.md、Product_v4_detail_plan.md、Product_v5_detail_plan.md 五个版本详细技术规划文档
  - 创建了 Prompt_library.md 用于记录所有对话
- **重要内容**：
  - V1.0 是核心，需要完成：收藏记录闭环 + AI 辅助记录 + 美观收藏墙
  - MVP 建议优先完成 V1.1 + V1.2 + V1.3
  - 主要风险：AI API 成本不可控、图片存储成本、AI 生成质量不稳定、首次使用体验复杂
  - 商业模式：Freemium + 高级模板 + 存储扩展 + 高级 AI 功能 + 实体纪念册 + 广告品牌合作
  - V2.3 AI 图片识别复杂度较高，建议 V1.2 先做文字 AI，V2.3 再做图片识别

---

## 2026-05-06 对话记录 2

- **用户要求**：创建 Status.md 记录项目当前状态
- **AI 行动**：创建了 Status.md，记录了项目概述、文件列表、开发阶段进度、技术栈计划、待办事项
- **重要内容**：项目目前处于规划阶段，尚未开始实际开发

---

## 2026-05-06 对话记录 3

- **用户要求**：在 Project_intro.md 顶部添加给未来 AI 的 Prompt
- **AI 行动**：重写了 Project_intro.md，在文件最顶部添加了给未来 AI 的 Prompt，包含两部分内容：（1）本文件是不可变更的项目指导文件；（2）指导未来 AI 如何快速了解项目——按顺序阅读 Status.md、Prompt_library.md、对应版本的 Product_v*_detail_plan.md
- **重要内容**：Project_intro.md 现在是项目的核心指导文件，所有开发工作必须以其为准

---

## 2026-05-06 对话记录 4

- **用户要求**：更新 Status.md 添加项目结构模块；创建 Test.md 用于测试记录
- **AI 行动**：
  - 更新了 Status.md，在顶部添加了给未来 AI 的 Prompt（提醒每次工作后更新状态），并新增了"项目结构"模块
  - 创建了 Test.md，用于记录测试情况，顶部包含给未来测试 AI 的 Prompt
- **重要内容**：
  - Status.md 现在包含：Prompt、项目结构、项目文件、开发阶段进度、技术栈、待办事项、备注
  - Test.md 包含：测试概览、测试用例表、Bug 记录表、测试报告
  - 两个文件都会随项目进展由负责的 AI 持续更新

---

## 2026-05-06 对话记录 5

- **用户要求**：把项目文件夹推送到 GitHub 仓库
- **AI 行动**：
  - 在 Group_Ass 文件夹中初始化了 git 仓库
  - 添加了所有文件并提交
  - 远程仓库设置为 https://github.com/YukiNA2020/GENAI_Group.git
  - 由于远程仓库已有 README.md，先 pull 合并，再 push 上去
  - 成功将项目文件推送到 GitHub
- **重要内容**：仓库链接 https://github.com/YukiNA2020/GENAI_Group.git

---

## 2026-05-08 对话记录

- **用户要求**：阅读已有项目文档，重新给出一个更平均的六人开发拆分方式，并写成 Markdown 文档，明确每个人具体做什么以及对应技术路线如何实现
- **AI 行动**：
  - 阅读了 `Project_intro.md`、`Status.md`、`Prompt_library.md`、`Team_Assignment.md`、`Test.md` 和 V1-V5 技术规划文档
  - 判断 PDF 原始资料不是本次任务重点，因此根据用户确认停止继续解析 PDF
  - 创建了 `Six_Person_Development_Split.md`
  - 在新文档中将原先纯职能式分工调整为六条端到端产品功能线：
    1. 收藏数据与核心 API
    2. 创建与图片上传流程
    3. 收藏墙与浏览体验
    4. AI 辅助记录
    5. 用户主页与分享增长
    6. 测试部署与商业化支撑
  - 更新了 `Status.md`，加入新文档文件列表、待办事项和备注
- **重要内容**：
  - 新分工不再按单一前端/后端/AI/基础设施拆分，而是按产品价值链拆分，便于六位成员并行推进
  - 每位成员都有 V1 MVP 必做任务、V2-V5 延伸任务、技术实现路线、建议目录结构、交付物和验收标准
  - V1 MVP 的优先级仍然是：收藏 CRUD -> 创建和图片上传 -> AI 辅助记录 -> 收藏墙展示 -> 详情页 -> 搜索筛选 -> 用户主页 -> 分享功能

---

## 2026-05-08 对话记录 2

- **用户要求**：团队重新商讨后决定以 `Final_Team_Work_Division.md` 为最终分工，其中第 6 人只负责 PPT、报告、视频和 Demo，不参与开发；需要仿照 V1-V5 细节开发流程，为前 5 位开发成员分别创建详细 Markdown 任务文档，拆到“阶段 - 任务”层级
- **AI 行动**：
  - 阅读了 `Final_Team_Work_Division.md`，确认最终 6 人分工和前 5 位开发成员的职责边界
  - 创建了 5 份成员级详细任务文档：
    1. `Member_1_Core_API_Data_Detail_Plan.md`
    2. `Member_2_Create_Upload_Integration_Detail_Plan.md`
    3. `Member_3_Collection_Wall_Search_Detail_Plan.md`
    4. `Member_4_UI_Visual_Design_Detail_Plan.md`
    5. `Member_5_AI_Profile_Test_Detail_Plan.md`
  - 每份文档都按角色目标、负责范围、技术路线、阶段任务、交付物和验收标准展开
  - 更新了 `Status.md`，将项目文件列表和待办事项调整为最终分工版本
- **重要内容**：
  - 实际开发由成员 1-5 承担，成员 6 负责课程交付材料，不再单独编写开发任务文档
  - 五份新文档分别覆盖：数据/API、创建上传与整合、收藏墙浏览搜索、UI 视觉设计与功能逻辑、AI/用户主页/测试
  - 开发文档使用“阶段 - 任务”拆分方式，方便每位成员直接按阶段执行和汇报
