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

> 上次更新：2026-05-16  
> 最近更新负责人：成员 A / 成员 1，由该成员的 AI 工具协助更新（阶段五·任务四+五：配合成员 5 联调 AI 和测试 + 后端交付说明）

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
├── backend/                      # 后端项目（成员 1 负责）
│   ├── package.json
│   ├── src/
│   │   ├── app.js                # Express 应用配置
│   │   ├── server.js             # 服务入口
│   │   ├── db/                   # 数据库连接与初始化
│   │   ├── routes/               # 路由
│   │   ├── controllers/          # 控制器
│   │   ├── services/             # 业务逻辑
│   │   ├── repositories/         # 数据访问
│   │   ├── middlewares/          # 中间件
│   │   └── utils/                # 工具函数
│   └── uploads/                  # 图片上传目录
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
| `API_Contract.md` | 已冻结的 API 接口文档（供全体成员联调） | ✅ 完成（成员 1） |
| `backend/package.json` | 后端项目依赖与脚本配置 | ✅ 完成（成员 1） |
| `backend/src/app.js` | Express 应用配置（CORS、JSON、静态文件、错误处理） | ✅ 完成（成员 1） |
| `backend/src/server.js` | 服务入口（端口 3000，dotenv 加载） | ✅ 完成（成员 1） |
| `backend/src/db/schema.sql` | 数据库表结构（collections + users + categories，共 3 表） | ✅ 完成（成员 1） |
| `backend/src/db/connection.js` | 数据库连接模块（sql.js 初始化、建表、持久化） | ✅ 完成（成员 1） |
| `backend/src/db/seed.js` | Mock 数据脚本（1 用户 + 8 分类 + 15 收藏） | ✅ 完成（成员 1） |
| `backend/src/utils/response.js` | 统一 API 响应格式（success, created, error） | ✅ 完成（成员 1） |
| `backend/src/middlewares/validate.middleware.js` | Zod 请求体验证中间件 | ✅ 完成（成员 1） |
| `backend/src/repositories/collections.repository.js` | 收藏数据访问层（insert, findById） | ✅ 完成（成员 1） |
| `backend/src/services/collections.service.js` | 收藏业务逻辑（camelCase ↔ snake_case 转换） | ✅ 完成（成员 1） |
| `backend/src/controllers/collections.controller.js` | 收藏控制器（createCollection） | ✅ 完成（成员 1） |
| `backend/src/routes/collections.routes.js` | 收藏路由（CRUD + 图片上传/删除，zod schema） | ✅ 完成（成员 1） |
| `backend/src/repositories/categories.repository.js` | 分类数据访问层（findAll, findById） | ✅ 完成（成员 1） |
| `backend/src/services/categories.service.js` | 分类业务逻辑（camelCase 转换 + fields JSON 解析） | ✅ 完成（成员 1） |
| `backend/src/controllers/categories.controller.js` | 分类控制器（listCategories + getCategory） | ✅ 完成（成员 1） |
| `backend/src/routes/categories.routes.js` | 分类路由（GET / + GET /:id） | ✅ 完成（成员 1） |
| `backend/src/repositories/users.repository.js` | 用户数据访问层（findById + getStats） | ✅ 完成（成员 1） |
| `backend/src/services/users.service.js` | 用户业务逻辑（stats 数据聚合 + camelCase 转换） | ✅ 完成（成员 1） |
| `backend/src/controllers/users.controller.js` | 用户控制器（getStats） | ✅ 完成（成员 1） |
| `backend/src/routes/users.routes.js` | 用户路由（GET /:id/stats） | ✅ 完成（成员 1） |
| `backend/tests/phase5_task4_test.js` | 阶段五·任务四 AI 集成验证测试脚本（66 项） | ✅ 完成（成员 1） |
| `Backend_Setup.md` | 后端交付说明（启动/数据库/API/排错） | ✅ 完成（成员 1） |

---

## 开发阶段进度

### V1.0 核心价值验证版
- [x] 产品规划
- [x] 技术路线文档
- [ ] 开发实施

### V1.1 最小收藏记录闭环
- [x] 阶段一·任务一：初始化后端项目（成员 1，2026-05-15）
- [x] 阶段一·任务二：设计 collections 表（成员 1，2026-05-15）
- [x] 阶段一·任务三：预留 users 和 categories 表（成员 1，2026-05-15）
- [x] 阶段一·任务四：建立数据库连接模块（成员 1，2026-05-15）
- [x] 阶段一·任务五：编写 seed 数据（成员 1，2026-05-15）
- [x] 阶段二·任务一：实现创建收藏接口 POST /api/collections（成员 1，2026-05-15）
- [x] 阶段二·任务二：实现收藏列表接口 GET /api/collections（成员 1，2026-05-15）
- [x] 阶段二·任务三：实现收藏详情接口 GET /api/collections/:id（成员 1，2026-05-15）
- [x] 阶段二·任务四：实现更新收藏接口 PUT /api/collections/:id（成员 1，2026-05-15）
- [x] 阶段二·任务五：实现删除收藏接口 DELETE /api/collections/:id（成员 1，2026-05-15）
- [x] 阶段二·任务六：统一返回格式（已在任务一中提前完成）
- [x] 阶段三·任务一：关键词搜索 GET /api/collections?keyword=（成员 1，2026-05-15）
- [x] 阶段三·任务二：分类筛选 GET /api/collections?category=（成员 1，2026-05-15）
- [x] 阶段三·任务三：标签筛选 GET /api/collections?tag=（成员 1，2026-05-15）
- [x] 阶段三·任务四：分页排序增强 GET /api/collections?sort=（成员 1，2026-05-15）
- [x] 阶段三·任务五：图片上传接口 POST /api/collections/:id/image（成员 1，2026-05-15）
- [x] 阶段三·任务六：图片删除接口 DELETE /api/collections/:id/image（成员 1，2026-05-15）

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

### V1.4 阶段四进展
- [x] 阶段四·任务一：扩展 collections 表（user_id, visibility, category_template, custom_fields）（成员 1，2026-05-15）
- [x] 阶段四·任务二：完善 categories 接口 GET /api/categories + GET /api/categories/:id（成员 1，2026-05-15）
- [x] 阶段四·任务三：支持用户主页统计 GET /api/users/:id/stats（成员 1，2026-05-15）
- [x] 阶段四·任务四：为成员 5 的 AI 模块预留 ai_usage_logs 表（成员 1，2026-05-15）

### V1.4 阶段五进展
- [x] 阶段五·任务一：冻结 API Contract — 创建 `API_Contract.md`（成员 1，2026-05-15）
- [x] 阶段五·任务二：配合成员 2 联调创建流程 — 增强校验中间件 + 32 项流程测试通过（成员 1，2026-05-15）
- [x] 阶段五·任务三：配合成员 3 联调浏览流程（成员 1，2026-05-16）
- [x] 阶段五·任务四：配合成员 5 联调 AI 和测试（成员 1，2026-05-16）
- [x] 阶段五·任务五：整理后端交付说明 `Backend_Setup.md`（成员 1，2026-05-16）

### V1.4 收藏详情与基础管理
- [ ] 待开发

### V1.5 基础搜索与筛选
- [x] 搜索、筛选、分页与图片接口（阶段三全部 6 个任务已完成，成员 1，2026-05-15）

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

2026-05-09 进一步补充 README 中的”清空上下文后的标准开发流程”：成员可以用固定 Prompt 让开发 AI 阅读仓库文档并完成指定阶段任务，再交给另一个独立测试 AI 测试并更新 `Test.md`。同时明确开发 AI 不负责最终测试结论和 GitHub 提交，测试通过后由成员本人提交。

2026-05-15（成员 A / 成员 1，阶段一·任务一）：初始化后端项目。创建 `backend/` 目录结构，初始化 Node.js 项目，安装 Express、sql.js、CORS、dotenv、multer、zod 等依赖，编写 `app.js`（Express 应用配置）和 `server.js`（服务入口），配置 `npm run dev` 和 `npm start` 脚本。服务已在本地 3000 端口验证启动成功，健康检查 `/api/health` 返回正常。注意：由于当前 Windows 环境缺少 Visual Studio 编译工具，SQLite 选型从 `better-sqlite3`（需原生编译）改为纯 JavaScript 的 `sql.js`，不影响功能，但后续阶段写 repository 时需按 sql.js API 实现。

2026-05-15（成员 A / 成员 1，阶段一·任务二）：设计 collections 表。在 `backend/src/db/schema.sql` 中定义 collections 表，包含 10 个字段：id (INTEGER PK AUTOINCREMENT)、title (TEXT NOT NULL)、category、date_acquired、location、story、image_url、tags (JSON 数组存为字符串)、created_at、updated_at。经 sql.js 验证，建表语法正确。命名遵循 Final_Team_Work_Division.md 中约定的 snake_case 规范。users 和 categories 表将在任务三中补充到同一文件。

2026-05-15（成员 A / 成员 1，阶段一·任务三）：预留 users 和 categories 表。在 schema.sql 中追加 users 表（id, username, email, avatar_url, bio, created_at, updated_at）供成员 5 扩展用户主页和登录占位使用；追加 categories 表（id 使用语义化 slug 作为主键, name, icon, fields JSON, display_priority, created_at）供成员 2 动态表单和成员 3 分类筛选使用。sql.js 验证三张表均创建成功。注意：display_priority 字段类型从文档建议的 TEXT 改为 INTEGER DEFAULT 0，更利于排序查询。

2026-05-15（成员 A / 成员 1，阶段一·任务四）：建立数据库连接模块。编写 `backend/src/db/connection.js`，封装 sql.js 的异步初始化、数据库文件加载/创建、schema 自动建表（IF NOT EXISTS 安全重复执行）、数据持久化（手动 saveDb）。创建 `backend/data/` 目录存放 SQLite 数据库文件 `collections.db`。已验证：初始化建表 → 写入测试数据 → 持久化 → 关闭重载 → 数据依然存在，全流程通过。由于 sql.js 是内存数据库，每次写操作后需调用 saveDb() 同步到磁盘，后续 repository 层需注意这一点。

2026-05-15（成员 A / 成员 1，阶段一·任务五）：编写 seed 数据。创建 `backend/src/db/seed.js`，包含：1 个默认演示用户（collector_demo）、8 个收藏分类（矿石、水晶、黑胶、明信片、票根、旅行纪念品、邮票、其他）、15 条收藏 Mock 数据覆盖全部 7 个有效类别。每条收藏包含标题、分类、日期、地点、标签（JSON 数组）和丰富的中文故事文本。seed 脚本运行 `node src/db/seed.js` 即可，可重复执行（每次先清空旧数据再插入）。数据库文件生成于 `backend/data/collections.db`。成员 3 可直接用这些数据开发收藏墙，成员 5 可用其测试 AI 和统计，成员 6 可用于 Demo 展示。

**阶段一全部 5 个任务已完成。** 后端基础已就绪：Express 服务可启动、3 张数据库表已建、连接模块可用、Mock 数据已填充。下一步进入阶段二（收藏 CRUD API 开发）。

2026-05-15（成员 A / 成员 1，阶段二·任务一）：实现创建收藏接口 POST /api/collections。搭建完整分层架构（utils → middleware → repository → service → controller → route），实现字段校验（zod，title 必填）、camelCase ↔ snake_case 命名转换、统一 JSON 响应格式。4 个测试场景全部通过（全字段创建、最小字段创建、缺标题 400、空标题 400）。**重要发现：sql.js 的 `db.export()`（saveDb 内部调用）会重置 `last_insert_rowid()` 为 0，因此所有写操作必须在 saveDb() 之前获取 last_insert_rowid。后续所有 repository 层的 INSERT/UPDATE/DELETE 操作均需注意此约束。**

2026-05-15（成员 A / 成员 1，阶段二·任务二+三）：实现收藏列表接口和详情接口。列表支持分页参数（page, pageSize），返回 items/total/page/pageSize，默认每页 20 条按 created_at DESC 排序。详情接口支持按 id 查询，不存在返回 404，非法 id 返回 400，tags 返回数组格式。5 个测试场景全部通过（默认列表、分页、详情、不存在 404、非法 ID 400）。**注意：统一返回格式（阶段二任务六）已在阶段二任务一提前完成。**

2026-05-15（成员 A / 成员 1，阶段二·任务四+五）：实现更新收藏接口和删除收藏接口。更新支持部分字段更新（所有字段 optional），自动刷新 updated_at，保留未被修改的字段不变（包括保留已有 image_url）。删除先检查存在性再执行，返回布尔结果区分"不存在"与"删除成功"。9 个测试场景全部通过（全字段更新、部分更新、更新不存在 404、更新非法 ID 400、删除、删除后验证 404、重复删除 404、删除非法 ID 400、列表确认总数 -1）。

**阶段二全部 6 个任务已完成（含任务六统一返回格式已在任务一提前实现）。收藏 CRUD 完整闭环已就绪：POST → GET list → GET detail → PUT → DELETE。** 下一步进入阶段三（搜索、筛选、分页增强与图片接口）。

2026-05-15（成员 A / 成员 1，阶段三·任务一+二+三）：实现关键词搜索、分类筛选和标签筛选。在已有的 GET /api/collections 列表接口上扩展 query 参数支持：`?keyword=` 搜索 title/story/location/tags 四个字段（LIKE %keyword%），`?category=` 精确匹配分类 slug（如 mineral/vinyl/crystal），`?tag=` 在 tags JSON 字符串中模糊匹配（LIKE %tag%，V1 策略，含子串匹配如"旅行"可匹配到"旅行纪念品"）。三个参数可任意组合（AND 逻辑），与已有分页参数 page/pageSize 兼容。Repository 层使用 SQLite 标准单引号转义（`''`）防止 SQL 注入。32 项测试全部通过，包括组合查询、空结果集、分页兼容和 SQL 注入安全验证。**阶段三还剩任务四（排序增强）、任务五（图片上传）和任务六（图片删除）待开发。**

2026-05-15（成员 A / 成员 1，阶段三·任务四+五+六）：实现排序增强、图片上传和图片删除。**任务四**：在列表接口新增 `?sort=` 参数，支持 created_desc（默认）/created_asc/date_desc/date_asc 四种排序，无效值自动回退到默认排序。仅在 repository 层新增 `SORT_MAP` 映射 + 动态 ORDER BY 子句，service/controller 层透传。**任务五**：实现 `POST /api/collections/:id/image`，使用 multer 接收 multipart 图片（限制 jpg/jpeg/png/gif/webp，5MB），文件保存至 `backend/uploads/collections/`（自动创建目录），文件名格式 `collection-{id}-{timestamp}{ext}`。上传时自动删除旧图片文件，更新 DB 的 image_url 为新路径。含完整错误处理：无文件→400 NO_FILE、非法 ID→400 INVALID_ID、不存在→404 NOT_FOUND，且无效 ID 时会清理已上传的临时文件。**任务六**：实现 `DELETE /api/collections/:id/image`，先检查 collection 存在性，再检查是否有 image_url，然后删除本地文件和清空 DB 字段。边界情况：无图片→400 NO_IMAGE、文件不存在于磁盘但仍清空 DB 记录并返回提示。30 项测试全部通过，覆盖上传→验证 DB→覆盖上传→删除→验证 DB→空集合删除→不存在→非法 ID→完整往返。**阶段三全部 6 个任务已完成。成员 1 的后端核心 API 开发（阶段一～阶段三）已全部完成。** 后续进入阶段四（数据扩展与联调支持）和阶段五（联调、Bug 修复和最终交付）。

2026-05-15（成员 A / 成员 1，阶段四·任务一+二）：扩展 collections 表和完成 categories 接口。**任务一**：在 schema.sql 中追加 4 个 ALTER TABLE 语句新增 `user_id INTEGER`、`visibility TEXT DEFAULT 'private'`、`category_template TEXT`、`custom_fields TEXT` 四个字段。改造 connection.js 的 schema 执行逻辑：先移除注释行再按 `;\n` 拆分语句逐条执行，ALTER TABLE 的 "duplicate column name" 错误被静默忽略，确保数据库迁移可安全重复执行。同步更新 repository（insert/update 字段列表）、service（FIELD_MAP 新增 userId/user_id、categoryTemplate/category_template、customFields/custom_fields 映射）和 routes（createSchema/updateSchema 新增四个字段的 zod 校验）。**任务二**：创建 categories 接口的完整分层架构——`categories.repository.js`（findAll 按 display_priority ASC，findById 按语义化 slug）、`categories.service.js`（camelCase 转换 display_priority→displayPriority + fields JSON 字符串→数组解析）、`categories.controller.js`（list + getById with 404）、`categories.routes.js`（GET / 和 GET /:id）。在 app.js 中挂载 `/api/categories` 路由。30 项测试全部通过，覆盖：扩展字段读写/默认值/部分更新/zod 校验、分类列表排序/字段解析/不存在 404/全部 8 个 slug 验证、迁移幂等性验证。

2026-05-15（成员 A / 成员 1，阶段四·任务三+四）：实现用户主页统计接口和 AI 使用日志表。**任务三**：创建 users 接口完整分层架构——`users.repository.js`（findById 查用户存在性 + getStats 聚合查询：收藏总数/去重分类数/最近5条/公开收藏数）、`users.service.js`（FIELD_MAP camelCase 转换 + tags JSON 解析 + 用户不存在返回 null→404）、`users.controller.js`（getStats with 非法 ID→400 + 不存在→404）、`users.routes.js`（GET /:id/stats）。在 app.js 中挂载 `/api/users`。**任务四**：在 schema.sql 中新增 `ai_usage_logs` 表（id, user_id, feature, created_at）供成员 5 后续记录 AI 功能调用。同步更新 seed.js：重置 sqlite_sequence 使每次重新 seed 后用户 ID 固定从 1 开始；捕捉实际 userId 后写入 collections 的 user_id 字段（不再硬编码）；交替设置 visibility 为 public/private（每 3 条中有 1 条公开）。14 项测试全部通过，覆盖：统计字段完整性/camelCase 转换/tags 数组/不存在 404/非法 ID 400/迁移兼容性。

2026-05-15（成员 A / 成员 1，阶段五·任务一+二）：冻结 API Contract 和配合成员 2 联调创建流程。**任务一**：创建 `API_Contract.md` 正式冻结文档，覆盖全部 10 个 API 端点、14 个收藏字段（含 Phase 4 扩展）、图片接口规格、categories/users 字段、AI 可写入字段清单、5 个查询参数（page/pageSize/keyword/category/tag/sort）、7 种错误码、命名约定（API camelCase / DB snake_case）、以及各端点的联调负责人映射。**任务二**：增强 `validate.middleware.js`——在 VALIDATION_ERROR 响应中新增 `fields` 对象（字段名→错误消息映射），方便成员 2 表单直接高亮对应输入框（向后兼容，不破坏现有解析）。修复 createSchema 中 title 字段的 `required_error` 提示，确保字段缺失时返回 "title is required" 而非通用的 "Required"。32 项成员 2 流程测试全部通过，覆盖：创建（全字段+最小字段）、表单校验（缺字段/空值/类型错误/fields 对象）、图片上传（无文件/invalid ID 下的 NO_FILE 优先）、编辑（部分更新/null 清空/updatedAt 刷新/不存在 404）、删除图片（无图片/不存在）、搜索+分类+统计一致性回归。

2026-05-16（成员 A / 成员 1，阶段五·任务三）：配合成员 3 联调浏览流程。从成员 3 五大场景出发进行审查和验证：(1) 列表分页——默认 page=1/pageSize=20，支持 page+pageSize 任意组合，越界页面返回空数组 + 正确 total；(2) 关键词搜索——覆盖 title/story/location/tags 四个字段 LIKE 匹配；(3) 分类筛选——精确匹配 category slug，可与 keyword 组合；(4) 标签筛选——V1 LIKE 子串匹配，支持 keyword+category+tag 三组合；(5) 详情页数据完整性——14 字段全部返回，tags 确保为数组格式。**发现并修复 bug**：`collections.service.js` 和 `users.service.js` 的 `toCamelCase()` 函数中，当数据库 tags 字段为 null 时（创建时不传 tags 导致），`typeof null === 'object'` 跳过了 JSON.parse 逻辑，导致 API 返回 `tags: null` 而非 `tags: []`。成员 3 前端渲染标签组件时会因 null 报错。修复方案：在 JSON.parse 分支后追加 `if (!Array.isArray(result.tags)) { result.tags = []; }` 兜底。53 项成员 3 流程测试全部通过。

2026-05-16（成员 A / 成员 1，阶段五·任务四+五）：配合成员 5 联调 AI 和测试 + 后端交付说明。**任务四**：从成员 5 四大验证点出发进行全面联调验证：(1) AI 输出能否保存进收藏——测试了 AI 全字段创建（title/category/tags/story/location/dateAcquired/customFields/categoryTemplate）、AI 部分更新、AI 字段 null 清空、tags=[] 空数组、不传 tags 默认空数组、长故事/20 标签/Emoji/特殊字符/复杂 JSON customFields 等边缘场景，全部通过；(2) AI 失败时是否影响主流程——确认收藏 CRUD API 无任何 AI 依赖，纯手动创建/仅标题创建均可正常完成，AI 服务故障完全不影响用户手动保存；(3) 测试用例稳定运行——`ai_usage_logs` 表可正常读写（4 个字段 id/user_id/feature/created_at），categories API 提供完整的英文 slug↔中文名称映射表（8 个分类全部验证），user stats 接口返回字段完整（含 14 个 collection camelCase 字段）；(4) Bug 复现和修复——前期 tags null 修复在 AI 集成场景下验证通过。66 项 AI 集成测试全部通过。**关键发现**：成员 5 的 AI 模块（`ai.schemas.js`）使用的 `COLLECTION_CATEGORIES` 为中文名称（矿石/水晶/黑胶唱片/明信片/票根/旅行纪念品/其他），但 collections 表的 `category` 字段存储的是英文 slug（mineral/crystal/vinyl/postcard/ticket/souvenir/stamp/other）。AI 输出写入前需做名称→slug 转换。`GET /api/categories` 已提供 id↔name 完整映射，成员 5 可直接调用。**任务五**：创建 `Backend_Setup.md`——覆盖环境要求（Node.js 18+）、快速启动三步骤（npm install → npm run seed → npm run dev）、完整项目目录结构及分层调用关系、11 个 API 端点速查表（含查询参数默认值和响应格式）、4 张数据库表字段说明、命名约定（DB snake_case/API camelCase/分类英文 slug）、各成员常用 curl 场景（成员 2 创建上传、成员 3 搜索筛选、成员 5 AI 写入和统计）、7 个常见问题排查（端口占用/数据库重置/500 错误/图片上传失败/CORS/错误码速查）、技术说明（sql.js 持久化/Schema 迁移兼容性/AI 可写入字段清单）。**阶段五全部 5 个任务已完成。成员 1 的后端开发（阶段一～阶段五共 21 个任务）已全部交付。**
