# GENAI_Group

## Collection Journey App 团队协作说明

本仓库用于开发 **Collection Journey App**：一款面向收藏者和记忆记录者的 AI 收藏档案应用。项目目标是完成一个可演示的 MVP，让用户可以记录收藏、使用 AI 辅助生成内容，并以美观的收藏墙浏览自己的收藏。

本 README 是团队成员和各自 AI 工具进入项目时的第一入口。无论使用 Cursor、ChatGPT、Claude、Codex 或其他 vibe coding 工具，都应先让 AI 阅读本文件，再按下面的文档顺序继续工作。

---

## 1. 当前执行依据

当前项目已经从“按产品版本拆开发过程”调整为“按团队成员分工并行开发”。因此：

1. 实际开发以 `Final_Team_Work_Division.md`、根目录成员任务文档和各成员文件夹中的任务文档为准。
2. `Project_intro.md` 仍然是产品方向和产品价值的核心指导文件。
3. `past_doc/` 里的五份 `Product_v*_detail_plan.md` 暂时不用来直接安排实际任务开发，仅作为项目立项时的一种参考方案。

---

## 2. 文档阅读顺序

每位成员和 AI 工具开始工作前，请按这个顺序阅读：

1. `README.md`  
   了解团队协作方式、GitHub 流程、文档规则和当前真实执行口径。

2. `Project_intro.md`  
   了解产品定位、目标用户、MVP 价值和长期路线。

3. `Status.md`  
   了解项目当前状态、文件结构、待办事项和最近进展。

4. `Prompt_library.md`  
   了解过去和用户/AI 的关键对话记录、重要决策和规则变化。

5. `Final_Team_Work_Division.md`  
   了解六人总分工、每个模块边界、协作原则和最终验收标准。

6. 自己负责的成员文档：

| 成员标识 | 对应文件 | 主要职责 |
|---|---|---|
| 成员 A / 成员 1 | `Member_1_Core_API_Data_Detail_Plan.md` | 数据库、核心 API、Mock 数据、图片接口 |
| 成员 B / 成员 2 | `Member_2_Create_Upload_Integration_Detail_Plan.md` | 创建收藏、编辑收藏、图片上传、最终整合 |
| 成员 C / 成员 3 | `Member_3_Collection_Wall_Search_Detail_Plan.md` | 收藏墙、详情页、搜索筛选、浏览体验 |
| 成员 D / 成员 4 | `Member_4_UI_Visual_Design_Detail_Plan.md` | UI 视觉规范、组件样式、图标和演示素材 |
| 成员 E / 成员 5 | `member_E/Member_5_AI_Profile_Test_Detail_Plan.md` | AI 功能、用户主页、测试和 Bug 跟踪 |
| 成员 6 | `Final_Team_Work_Division.md` 中成员 6 部分 | PPT、报告、视频、Demo 展示材料 |

7. `Test.md`  
   开发完成或联调时记录测试结果、Bug 和验证情况。

8. `past_doc/`  
   仅在需要理解早期产品设想时阅读。暂时不用这些文档进行实际任务开发，仅为项目立项时的一种参考方案。

---

## 3. 给每位成员 AI 工具的统一 Prompt

可以把下面这段话复制给自己的 AI 工具：

```text
你正在参与 Collection Journey App 团队项目。请先阅读 README.md、Project_intro.md、Status.md、Prompt_library.md、Final_Team_Work_Division.md，以及我负责的成员任务文档。

当前项目实际开发以 Final_Team_Work_Division.md、根目录成员任务文档和各成员文件夹中的任务文档为准。成员 E 的任务文档位于 member_E/Member_5_AI_Profile_Test_Detail_Plan.md。past_doc 文件夹中的 Product_v1 到 Product_v5 文档暂时不用来直接安排实际任务开发，仅作为项目立项时的一种参考方案。

请严格按照我的成员身份和职责边界开发，不要随意修改其他成员负责的模块。如果必须改动跨成员接口、字段、目录结构或共享组件，请先在文档中说明原因，并提醒团队确认。

每次完成工作后，请更新 Status.md 和 Prompt_library.md；如果涉及测试，也更新 Test.md。更新时必须标明我是成员 A/B/C/D/E 或成员 6，以便其他人确认哪个人写了哪里。
```

---

## 4. 清空上下文后的标准开发流程

目标是：即使 AI 工具完全没有之前的聊天上下文，只要它能读取本仓库文件，也可以根据 README 和成员任务文档继续开发。

标准流程如下：

1. 成员打开电脑，进入本地项目文件夹，从 GitHub 拉取最新项目状态。
2. 成员打开 Codex、Claude Code、Cursor 或其他 AI 工具，输入自己的成员身份、阶段和任务。
3. 开发 AI 阅读仓库文档，完成对应代码开发和必要的状态同步，然后把结果交给成员本人测试。
4. 成员再打开另一个没有参与开发流程的 AI 工具，要求它测试同一个阶段任务，并把测试结果同步到 `Test.md`。
5. 如果测试通过，成员自己提交到 GitHub，提交信息写清楚成员和任务，例如：`成员A，完成阶段一任务一`。

开发 AI 和测试 AI 的职责必须分开：

| AI 类型 | 主要职责 | 可以修改的内容 | 不应该做的事 |
|---|---|---|---|
| 开发 AI | 根据成员任务文档完成代码开发 | 负责成员范围内的代码、必要文档状态同步 | 不应替用户做最终测试结论，不应擅自提交到 GitHub |
| 测试 AI | 独立检查某个阶段任务是否完成 | `Test.md`，必要时可补充测试脚本或测试说明 | 不应无指令重写开发实现，不应扩大测试范围到其他成员任务 |

如果只输入：

```text
我是成员A，我要你帮我完成阶段一的任务一，然后将结果交给我进行测试。
```

理论上可以执行，但为了避免 AI 误读成员、阶段或边界，推荐使用下面的完整模板。

### 4.1 开发 AI 输入模板

把成员、阶段和任务替换成自己的内容：

```text
我是成员A / 成员1。请你帮我完成我负责文档中的阶段一任务一，然后将结果交给我进行测试。

请你先阅读 README.md、Project_intro.md、Status.md、Prompt_library.md、Final_Team_Work_Division.md，以及 Member_1_Core_API_Data_Detail_Plan.md。

当前开发必须以 Final_Team_Work_Division.md 和我的成员任务文档为准。past_doc 文件夹中的 Product_v1 到 Product_v5 文档暂时不用来进行实际任务开发，仅作为项目立项参考方案。

请严格只做成员A / 成员1、阶段一、任务一范围内的工作。不要随意修改其他成员负责的模块。如果必须改共享接口、字段、目录结构或配置，请先说明原因，并在 Status.md 中记录。

开发完成后，请：
1. 告诉我你改了哪些文件。
2. 告诉我如何运行或检查这个任务。
3. 更新 Status.md 和 Prompt_library.md，并标明负责人是成员A / 成员1，由该成员的 AI 工具协助更新。
4. 不要替我提交 GitHub，也不要把任务标记为测试通过；测试会交给另一个 AI 完成。
```

其他成员使用时，只需要替换身份和文档名：

| 成员 | 开发 Prompt 中的身份 | 对应成员文档 |
|---|---|---|
| 成员 A / 成员 1 | `我是成员A / 成员1` | `Member_1_Core_API_Data_Detail_Plan.md` |
| 成员 B / 成员 2 | `我是成员B / 成员2` | `Member_2_Create_Upload_Integration_Detail_Plan.md` |
| 成员 C / 成员 3 | `我是成员C / 成员3` | `Member_3_Collection_Wall_Search_Detail_Plan.md` |
| 成员 D / 成员 4 | `我是成员D / 成员4` | `Member_4_UI_Visual_Design_Detail_Plan.md` |
| 成员 E / 成员 5 | `我是成员E / 成员5` | `member_E/Member_5_AI_Profile_Test_Detail_Plan.md` |

### 4.2 测试 AI 输入模板

开发完成后，把同一个阶段任务交给另一个 AI 测试：

```text
请你作为一个没有参与开发的新测试 AI，帮我测试成员A / 成员1的阶段一任务一。

请先阅读 README.md、Status.md、Prompt_library.md、Final_Team_Work_Division.md、Member_1_Core_API_Data_Detail_Plan.md 和 Test.md。

请只测试成员A / 成员1、阶段一、任务一是否按文档完成，不要扩大到其他成员任务，也不要重写开发代码，除非我明确要求你修复。

测试完成后，请：
1. 说明测试范围。
2. 说明测试方法和测试结果。
3. 如果失败，写清楚失败原因、复现方式和建议修复方向。
4. 将测试结果同步到 Test.md，并标明负责人是成员A / 成员1，测试由该成员的测试 AI 协助更新。
5. 不要替我提交 GitHub。
```

### 4.3 成员提交 GitHub 的标准动作

测试通过后，由成员本人提交，不由 AI 擅自提交：

```bash
git status
git add README.md
git commit -m "成员A，完成阶段一任务一"
git push origin feature/core-api-data
```

上面的 `git add README.md` 只是示例。实际提交时应添加本次任务真正修改过的文件。多人协作时，建议优先使用明确文件名，不要无脑使用 `git add .`，避免把别人的临时文件或无关改动一起提交。

---

## 5. 团队开发边界

为了减少后期合并冲突，请遵守以下规则：

1. 不要直接把所有功能写在同一个文件里。
2. 优先按照成员任务文档中的建议目录开发。
3. 不要随意重命名其他成员已经约定好的 API 字段、数据库字段、页面路径或组件名称。
4. 如果需要修改共享接口，先在 `Status.md` 的备注中记录，并通知相关成员。
5. 每个成员完成阶段任务后，都要在自己的提交说明和状态文档里写清楚成员标识。
6. `past_doc/` 中的旧版本文档只作为参考，不作为当前分工和排期依据。

---

## 6. GitHub 协作流程

### 6.1 第一次获取项目

如果还没有本地仓库，先克隆：

```bash
git clone https://github.com/YukiNA2020/GenAI_in_Business.git
cd GenAI_in_Business
```

如果仓库已经在本地，请进入项目目录：

```bash
cd GenAI_in_Business
```

### 6.2 每次开始工作前

每次开始写代码或改文档前，都先拿到远端最新分支信息：

```bash
git fetch --all --prune
```

然后切换到自己的功能分支。第一次开发时创建分支：

```bash
git switch -c feature/your-member-task
```

已经有自己的分支时：

```bash
git switch feature/your-member-task
git pull --ff-only origin feature/your-member-task
```

建议分支名：

| 成员 | 分支名 |
|---|---|
| 成员 A / 成员 1 | `feature/core-api-data` |
| 成员 B / 成员 2 | `feature/create-upload-flow` |
| 成员 C / 成员 3 | `feature/collection-wall-search` |
| 成员 D / 成员 4 | `feature/ui-design-assets` |
| 成员 E / 成员 5 | `memberE` |
| 成员 6 | `feature/report-ppt-demo` |

> 注意：当前团队最新工作不一定都已经合并到 `main`。成员 E / 成员 5 后续应优先在自己的 `memberE` 分支工作；`feature/ai-profile-test` 是已有远端协作分支，作为同步来源和必要时的备用工作分支。成员 E 当前结构、下一步计划和技术细节见 `member_E/docs/E_Current_Status_and_Plan.md`。

### 6.3 完成任务后提交

先查看自己改了哪些文件：

```bash
git status
```

确认没有误改别人的文件后，提交：

```bash
git add <本次任务修改过的文件>
git commit -m "成员A，完成阶段一任务一"
```

提交信息请把 `成员A` 和任务名替换成自己的成员标识和实际任务，例如 `成员E，完成阶段三任务四登录注册占位`。

推送到 GitHub：

```bash
git push origin feature/your-member-task
```

然后在 GitHub 上创建 Pull Request，让团队检查后再合并。不要直接把未确认的功能推到 `main`。

成员 E / 成员 5 如果使用 `memberE` 分支，推送命令为：

```bash
git push -u origin memberE
```

---

## 7. 状态同步规则

项目现在采用“两层状态同步”：

1. 成员文件夹内的局部同步：记录本成员日常细节。
2. 根目录主文档同步：记录团队需要共同知道的阶段状态和关键决策。

### 7.1 成员文件夹局部同步

如果某位成员已经建立了自己的成员文件夹，可以先在成员文件夹中维护局部记录。例如成员 E 使用：

| 局部文件 | 对应根目录文件 | 用途 |
|---|---|---|
| `member_E/E_Status_Log.md` | `Status.md` | 成员 E 局部进度、文件变化、待办事项 |
| `member_E/E_Prompt_Log.md` | `Prompt_library.md` | 成员 E 局部用户要求、AI 行动、关键决策 |
| `member_E/E_Test_Log.md` | `Test.md` | 成员 E 局部测试过程、Bug 和测试结论 |

局部记录文件必须带成员标识或后缀，不能直接命名为 `Status.md`、`Prompt_library.md`、`Test.md`，避免和根目录主文档混淆。

### 7.2 根目录主文档同步

每个阶段结束、完成可交付任务、测试通过/失败、或产生跨成员影响时，必须检查以下根目录文件是否需要更新：

1. `Status.md`：记录当前进展、文件变化、待办事项和重要问题。
2. `Prompt_library.md`：记录用户要求、AI 行动和重要决策。
3. `Test.md`：如果执行了测试、发现 Bug 或修复 Bug，需要记录测试结果。

更新这些状态文档时，必须写明操作者身份：

```text
负责人：成员 A / 成员 1
```

如果是 AI 工具代写，也要写成：

```text
负责人：成员 C / 成员 3，由该成员的 AI 工具协助更新
```

这样其他成员可以快速确认哪个人写了哪里，避免后期合并时不知道修改来源。

### 7.3 必须立即同步根目录的情况

以下情况不要只留在成员文件夹内，必须同步根目录主文档：

1. 改动影响其他成员的接口、字段、页面路径、共享组件或测试范围。
2. 阶段状态发生变化，例如从“开发中”变为“待测试”“测试通过”或“测试失败”。
3. 发现会阻塞 Demo 或合并的 Bug。
4. 新增、移动、删除重要文件或目录。
5. 与最终展示、报告或成员 6 交付材料有关的结论。

---

## 8. 当前开发重点

当前 MVP 的核心目标是：

1. 用户可以创建收藏记录。
2. 用户可以上传收藏图片。
3. 用户可以使用 AI 生成标题、分类、标签和故事建议。
4. 用户可以在收藏墙中浏览收藏。
5. 用户可以进入详情页、搜索和筛选收藏。
6. 项目可以稳定演示，并有 PPT、报告和 Demo 流程。

如果出现文档冲突，以优先级判断：

1. `Project_intro.md` 决定产品方向。
2. `Final_Team_Work_Division.md` 决定团队分工。
3. `Member_*.md` 决定个人任务执行。
4. `Status.md` 决定当前状态。
5. `past_doc/` 只作为参考。
