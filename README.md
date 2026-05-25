# Collection Journey App

Collection Journey App 是一个面向收藏者和记忆记录者的 AI 收藏档案 MVP。当前产品已经完成核心整合：用户可以浏览收藏墙、进入月度房间、查看详情、创建/编辑收藏、上传图片、使用 AI 生成标题/分类/标签/故事/图片理解结果，并查看个人主页与分享预览。

> 当前状态：核心 MVP 已经集中在当前工作分支 `codex/integration-prep`，可按“整合完成”处理。项目不要求一定先合并到 `main` 才算完成；但如果后续要交付、提交或开 PR，仍建议先检查 `git status` 并把当前分支整理成清晰提交。

---

## 1. MVP 能力范围

当前 MVP 已通过阶段 7 回归测试，主要能力包括：

| 模块 | 当前能力 |
|---|---|
| 后端 API | Express + sql.js，支持 collections / rooms / users / categories / AI 路由 |
| 收藏管理 | 创建、编辑、删除、详情、列表、搜索、分类、标签、排序、分页 |
| 图片能力 | 本地上传、图片 URL、图片展示、AI 图片理解输入 |
| 房间能力 | `/api/rooms` 月度房间列表与房间详情，前端按真实 `roomId` 展示 |
| AI 能力 | 标题、分类、标签、故事生成；GLM Vision 图片理解；失败时不阻塞手动保存 |
| 前端体验 | Flutter Web/App Shell、Gallery、Room、Detail、Create/Edit、Profile、Share Preview |
| 演示能力 | 可启动本地后端 + Flutter Web release 进行完整 Demo |

仍不属于当前 MVP 的内容：

- 真实账号体系、多人数据隔离和权限系统。
- 线上部署、生产数据库、对象存储、备份策略。
- 公开分享链接的真实服务端权限控制。
- 完整 CI/CD 和跨浏览器自动化测试。

后续计划见 [next_detail_plan.md](next_detail_plan.md)。

---

## 2. 项目构成

```text
GenAI_in_Business/
├── README.md                         # 当前项目入口、启动说明、结构说明
├── next_detail_plan.md               # MVP 完成后的下一步行动计划
├── DOCUMENTATION_STATUS.md           # Markdown 文档索引，区分当前依据/完成记录/历史参考
├── INTEGRATION_IMPLEMENTATION_PATH.md # 已完成的分阶段整合路线，保留作技术审计记录
├── Status.md                         # 项目状态与历史进展
├── Test.md                           # 测试结果、Bug 记录和回归结论
├── API_Contract.md                   # 当前冻结 API 合同
├── Project_intro.md                  # 产品方向、目标用户和长期路线
├── Final_Team_Work_Division.md       # 团队分工与职责边界
├── backend/                          # Express + sql.js 后端
├── frontend/                         # Flutter 前端主应用
├── member_E/                         # AI / Profile / 测试脚本与成员 E 文档
├── member_B/                         # 成员 B 历史交接与表单相关材料
├── PictureofProduct/                 # 当前 MVP 产品截图与中文使用指南
├── design-export/                    # UI handoff、设计导出与视觉参考
└── past_doc/                         # 早期产品路线，仅作历史参考
```

### 2.1 后端结构

```text
backend/
├── package.json
├── data/collections.db               # sql.js demo 数据库，npm run seed 会重置
├── src/
│   ├── app.js                        # Express app、CORS、body limit、路由挂载
│   ├── server.js                     # 服务入口，默认端口 3000
│   ├── db/                           # schema、seed、数据库连接
│   ├── routes/                       # collections / rooms / users / categories / ai
│   ├── controllers/                  # HTTP 控制器
│   ├── services/                     # 业务逻辑
│   ├── repositories/                 # 数据访问
│   └── middlewares/                  # zod 校验与错误处理
└── uploads/                          # 本地上传图片目录
```

当前主要端点：

| 端点 | 用途 |
|---|---|
| `GET /api/health` | 健康检查 |
| `GET /api/collections` | 收藏列表、搜索、筛选、排序、分页 |
| `POST /api/collections` | 创建收藏 |
| `GET /api/collections/:id` | 收藏详情 |
| `PUT /api/collections/:id` | 更新收藏 |
| `DELETE /api/collections/:id` | 删除收藏 |
| `POST /api/collections/:id/image` | 上传收藏图片 |
| `GET /api/rooms` | 月度房间列表 |
| `GET /api/rooms/:id` | 房间详情与展品 |
| `GET /api/users/:id/stats` | 用户统计与最近收藏 |
| `GET /api/categories` | 分类与动态字段 |
| `POST /api/ai/*` | AI 标题、分类、标签、故事、图片理解 |

完整字段合同以 [API_Contract.md](API_Contract.md) 为准。

### 2.2 前端结构

```text
frontend/
├── pubspec.yaml
├── assets/
│   ├── design_tokens.json
│   └── fonts/                        # 本地 Inter 字体，支持无 CDN Web build
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── layout/                   # 手机壳、状态栏、底部导航外壳
    │   ├── motion/                   # 动效参数
    │   └── theme/                    # Collectory 主题与 tokens
    └── features/
        ├── collection_browse/        # Home / Gallery / Room / Detail / Share
        ├── collection_form/          # Create / Edit / AI panel / Image picker
        └── profile/                  # Profile / Edit profile / 登录注册占位
```

前端默认 API 地址：

- Web / macOS / iOS simulator：`http://localhost:3000`
- Android emulator：`http://10.0.2.2:3000`
- 可通过 `--dart-define=API_BASE_URL=http://host:port` 覆盖。

### 2.3 AI 模块结构

```text
member_E/
├── .env.example                      # AI Provider 环境变量示例
├── backend/src/ai/                   # prompts、schemas、provider、routes、vision provider
├── docs/                             # AI 合同、Provider 设置、完成报告
└── scripts/                          # 阶段验证脚本和 Demo E2E 脚本
```

AI 路由通过 `backend/src/routes/ai.routes.js` 挂载到主后端。文本生成走 OpenAI-compatible provider，可用于 DeepSeek；图片理解走 GLM Vision provider，并保留文本 fallback。

---

## 3. 本地启动

### 3.1 环境要求

- Node.js 18+。
- Flutter SDK，项目 `pubspec.yaml` 要求 Dart SDK `>=3.3.0 <4.0.0`。
- Python 3，可选，用于快速启动 Flutter Web release 静态服务。
- 如需真实 AI 调用，需要配置 API key；不配置真实 key 时仍可使用 mock/fallback 路径完成核心 Demo。

### 3.2 启动后端

```bash
cd backend
npm install
npm run seed
npm start
```

说明：

- `npm run seed` 会重置 `backend/data/collections.db` 为 demo 数据。测试前推荐执行；如果你刚手工创建了重要数据，不要直接运行 seed。
- `npm start` 默认启动 `http://localhost:3000`。
- 开发时也可以使用 `npm run dev`。

健康检查：

```bash
curl http://localhost:3000/api/health
```

期望返回：

```json
{"success":true,"message":"Collection Journey API is running"}
```

### 3.3 配置真实 AI Provider（可选）

如果要测试真实 DeepSeek-compatible 文本生成或 GLM Vision 图片理解，在 `backend/.env` 中配置。可以参考 `member_E/.env.example`。

```bash
AI_PROVIDER=openai
AI_API_KEY=YOUR_DEEPSEEK_API_KEY
AI_BASE_URL=https://api.deepseek.com
AI_MODEL=deepseek-v4-flash
AI_TIMEOUT_MS=30000

VISION_PROVIDER=glm
ZHIPU_API_KEY=YOUR_ZHIPU_API_KEY
ZHIPU_API_BASE_URL=https://open.bigmodel.cn/api/paas/v4
ZHIPU_VISION_MODEL=glm-4v-flash
ZHIPU_VISION_TIMEOUT_MS=45000
```

不要提交包含真实密钥的 `.env` 文件。

### 3.4 启动前端开发模式

后端保持运行后：

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

如果使用 Flutter web-server：

```bash
cd frontend
flutter run -d web-server --web-port=8088 --dart-define=API_BASE_URL=http://localhost:3000
```

然后打开 Flutter 输出的本地地址。

### 3.5 启动前端 release 演示

推荐用于最终 Demo，因为当前项目已经支持无 CDN Web build：

```bash
cd frontend
flutter build web --release --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:3000
cd build/web
python3 -m http.server 8091
```

浏览器打开：

```text
http://127.0.0.1:8091
```

---

## 4. 常用测试命令

### 4.1 后端与 AI 回归

先启动后端，再从项目根目录运行：

```bash
node member_E/scripts/verify_phase1_task1_title.js
node member_E/scripts/verify_phase2_task1_provider.js
node member_E/scripts/verify_phase2_tasks2_4_api.js
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_phase5_demo_e2e.js
```

如果要跑 GLM Vision live 测试，需要先配置真实 `ZHIPU_API_KEY`：

```bash
node member_E/scripts/verify_glm_vision_live.js
```

### 4.2 Flutter 静态检查与构建

```bash
cd frontend
flutter test --no-pub
flutter analyze --no-pub --no-fatal-infos
flutter build web --release --no-pub --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:3000
```

当前阶段 7 复测结论：

- 后端 API 主路径通过。
- AI 阶段脚本通过。
- Flutter test / analyze / web release build 通过。
- 浏览器手测路径 Home / Gallery / Room / Detail / Create / Edit / Profile / Share Preview 通过。

完整测试记录见 [Test.md](Test.md)。

### 4.3 产品截图材料

`PictureofProduct/` 保存当前 MVP 的产品截图和中文使用指南，可用于向同学、老师或评审介绍产品。

```text
PictureofProduct/
├── README.md
├── 使用指南.md
├── 01-museum-home.png
├── 02-gallery-may.png
├── 03-gallery-jun.png
├── 04-gallery-jul.png
├── 05-collection-detail.png
├── 06-add-exhibit.png
├── 07-profile.png
├── 08-share-settings.png
├── 09-edit-collection.png
└── 10-public-browse.png
```

---

## 5. 文档阅读顺序

当前建议阅读顺序：

1. [README.md](README.md)
2. [next_detail_plan.md](next_detail_plan.md)
3. [DOCUMENTATION_STATUS.md](DOCUMENTATION_STATUS.md)
4. [Status.md](Status.md)
5. [Test.md](Test.md)
6. [API_Contract.md](API_Contract.md)
7. [Project_intro.md](Project_intro.md)
8. 对应成员或模块文档。

`INTEGRATION_IMPLEMENTATION_PATH.md` 已经从“待执行路线”转为“已完成的整合记录”。如果要继续开发，请不要从旧阶段清单里重新领任务，而是看 [next_detail_plan.md](next_detail_plan.md)。

---

## 6. Git 与分支口径

截至 2026-05-25：

- 当前 MVP 集中在 `codex/integration-prep`。
- 这已经满足本项目“整合完成”的定义：MVP 产品能力在同一个分支/工作树内可启动、可测试、可演示。
- 不强制要求先 merge 到 `main`。
- 仓库中仍可能保留历史分支，例如 `feature/ai-profile-test`、`feature/member-1-task`、`20260522-version`、`memberE` 等。这些分支是开发过程记录，不代表 MVP 仍分散在多个分支。

继续开发前建议：

```bash
git branch --show-current
git status
```

如果准备交付或提交，建议把当前分支整理成一次或几次清晰提交，再按团队需要决定是否合并到 `main` 或保留当前分支作为交付分支。
