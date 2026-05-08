# 给未来 AI 的 Prompt

> 本文件是成员 A / 成员 1 的实际开发任务文档。请先阅读 `README.md`、`Project_intro.md`、`Status.md`、`Prompt_library.md` 和 `Final_Team_Work_Division.md`，再按本文档执行。
>
> 成员 A / 成员 1 负责收藏数据与核心 API、数据库、Mock 数据和图片接口。不要随意修改成员 B、成员 C、成员 D、成员 E 或成员 6 的职责文件和模块；如必须改共享接口或字段，请同步记录到 `Status.md`。
>
> 每次完成开发、修复或文档更新后，请在 `Status.md` 和 `Prompt_library.md` 中标明“负责人：成员 A / 成员 1”。`past_doc/` 中的旧版本规划仅供参考，不作为当前任务依据。

---

# 成员 1 开发任务详细文档 - 收藏数据与核心 API，数据生成

> 对应最终分工：成员 1｜收藏数据与核心 API，数据生成  
> 角色类型：全栈 - 数据层  
> 建议 DDL：15-17 号  
> 主要依赖方：成员 2、成员 3、成员 5

---

## 一、角色目标

成员 1 负责 Collection Journey App 的数据层和核心后端能力。该成员的核心目标是先把收藏数据结构、基础 API、搜索筛选、图片接口和 Mock 数据搭好，让其他成员可以基于稳定接口开发页面、AI 功能和测试流程。

一句话概括：

> 成员 1 要保证 App 有稳定的数据来源、统一的接口格式，以及可供前端和 Demo 使用的测试数据。

---

## 二、总体负责范围

成员 1 负责：

1. 数据库表设计。
2. 后端项目基础结构。
3. 收藏 CRUD 接口。
4. 搜索、筛选、分页接口。
5. 图片上传和删除接口。
6. 统一 API 返回格式。
7. 统一错误处理。
8. Mock 数据和 seed 数据。
9. 联调阶段接口 Bug 修复。

成员 1 不主要负责：

1. Flutter 页面具体 UI。
2. AI Prompt 内容设计。
3. PPT、报告、视频制作。
4. 高保真视觉设计。

---

## 三、技术路线总览

| 层级 | 技术方案 | 说明 |
|------|----------|------|
| 后端框架 | Node.js + Express | 轻量、适合课程项目和 MVP |
| 数据库 | SQLite | V1 阶段快速验证，单文件易部署 |
| 数据访问 | Repository + Service 分层 | 避免路由中直接写 SQL |
| 请求校验 | zod 或 joi | 保证字段稳定 |
| 图片上传 | multer + local storage | V1 先本地存储，后续可迁移 S3 / OSS |
| API 测试 | Postman / Supertest | 方便成员 5 做测试 |
| Mock 数据 | seed.js | 给成员 2、3、5 联调使用 |

推荐后端目录：

```text
backend/
├── src/
│   ├── app.js
│   ├── server.js
│   ├── db/
│   │   ├── connection.js
│   │   ├── schema.sql
│   │   └── seed.js
│   ├── routes/
│   │   ├── collections.routes.js
│   │   ├── upload.routes.js
│   │   └── categories.routes.js
│   ├── controllers/
│   │   ├── collections.controller.js
│   │   └── upload.controller.js
│   ├── services/
│   │   └── collections.service.js
│   ├── repositories/
│   │   └── collections.repository.js
│   ├── middlewares/
│   │   ├── error.middleware.js
│   │   └── validate.middleware.js
│   └── utils/
│       └── response.js
└── uploads/
```

---

## 四、阶段一：V1.1 数据库与后端基础搭建

### 阶段目标

完成后端基础工程、数据库 schema 和可运行的服务，为后续 CRUD 和前端联调打底。

### 任务 1：初始化后端项目

具体工作：

1. 创建 `backend/` 目录。
2. 初始化 Node.js 项目。
3. 安装 Express、SQLite、CORS、dotenv 等依赖。
4. 配置 `npm run dev` 和 `npm start`。
5. 确认本地服务可以启动。

技术实现：

```text
Express app -> routes -> controllers -> services -> repositories -> SQLite
```

交付物：

1. `backend/package.json`
2. `backend/src/app.js`
3. `backend/src/server.js`

### 任务 2：设计 collections 表

具体工作：

1. 根据 V1 文档设计收藏基础字段。
2. 支持标题、分类、日期、地点、故事、图片、标签。
3. 增加创建时间和更新时间。

建议 schema：

```sql
CREATE TABLE collections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category TEXT,
  date_acquired TEXT,
  location TEXT,
  story TEXT,
  image_url TEXT,
  tags TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### 任务 3：预留 users 和 categories 表

具体工作：

1. 先建立最小版 `users` 表，方便成员 5 后续扩展用户主页。
2. 先建立最小版 `categories` 表，方便成员 2 动态表单和成员 3 分类筛选。

建议 schema：

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE,
  email TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  fields TEXT,
  display_priority TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### 任务 4：建立数据库连接模块

具体工作：

1. 封装数据库连接。
2. 确保所有 repository 复用同一个连接。
3. 提供初始化数据库脚本。

交付物：

1. `backend/src/db/connection.js`
2. `backend/src/db/schema.sql`

### 任务 5：编写 seed 数据

具体工作：

1. 准备 10-20 条收藏 Mock 数据。
2. 覆盖矿石、水晶、黑胶、明信片、票根、旅行纪念品等类别。
3. 每条数据包含标题、图片 URL 占位、标签、日期、地点、故事。

用途：

1. 成员 3 可以直接开发收藏墙。
2. 成员 5 可以测试 AI 和用户主页统计。
3. 成员 6 可以拿到稳定 Demo 内容。

### 阶段一验收标准

1. 后端服务可以本地启动。
2. SQLite 数据库可以初始化。
3. `collections`、`users`、`categories` 表存在。
4. seed 数据可以成功写入。
5. 其他成员可以拿到基础 API 地址和字段说明。

---

## 五、阶段二：V1.2 收藏 CRUD API 开发

### 阶段目标

完成收藏创建、查询、更新、删除的核心接口。

### 任务 1：实现创建收藏接口

接口：

```text
POST /api/collections
```

请求字段：

```json
{
  "title": "东京小书店的明信片",
  "category": "明信片",
  "dateAcquired": "2025-04-12",
  "location": "Tokyo",
  "story": "这是一张旅行中买到的明信片。",
  "tags": ["旅行", "明信片", "东京"]
}
```

实现重点：

1. `title` 必填。
2. `tags` 前端传数组，后端存 JSON 字符串。
3. 返回创建后的完整收藏对象。

### 任务 2：实现收藏列表接口

接口：

```text
GET /api/collections
```

初版返回：

1. 收藏列表。
2. 总数量。
3. 当前页码。
4. 每页数量。

响应结构：

```json
{
  "success": true,
  "data": {
    "items": [],
    "total": 20,
    "page": 1,
    "pageSize": 20
  }
}
```

### 任务 3：实现收藏详情接口

接口：

```text
GET /api/collections/:id
```

实现重点：

1. 查询不到时返回 404。
2. `tags` 返回数组格式。
3. 字段命名返回 camelCase，避免前端再转换。

### 任务 4：实现更新收藏接口

接口：

```text
PUT /api/collections/:id
```

实现重点：

1. 支持部分字段更新。
2. 更新时刷新 `updated_at`。
3. 查询不到时返回 404。

### 任务 5：实现删除收藏接口

接口：

```text
DELETE /api/collections/:id
```

实现重点：

1. 删除数据库记录。
2. 如果有关联图片，后续阶段同时删除本地图片。
3. 返回删除成功状态。

### 任务 6：统一 API 返回格式

成功响应：

```json
{
  "success": true,
  "data": {},
  "message": ""
}
```

失败响应：

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "title is required"
  }
}
```

### 阶段二验收标准

1. Postman 可以完整跑通收藏 CRUD。
2. 成员 2 可以调用创建和编辑接口。
3. 成员 3 可以调用列表和详情接口。
4. 成员 5 可以把 AI 结果写入收藏字段。

---

## 六、阶段三：V1.3 搜索、筛选、分页与图片接口

### 阶段目标

补齐展示层需要的查询能力和输入流程需要的图片能力。

### 任务 1：关键词搜索

接口：

```text
GET /api/collections?keyword=东京
```

搜索范围：

1. `title`
2. `story`
3. `location`
4. `tags`

技术实现：

```sql
WHERE title LIKE ?
   OR story LIKE ?
   OR location LIKE ?
   OR tags LIKE ?
```

### 任务 2：分类筛选

接口：

```text
GET /api/collections?category=明信片
```

实现重点：

1. 支持单分类筛选。
2. 返回分页结果。
3. 和关键词搜索可以组合使用。

### 任务 3：标签筛选

接口：

```text
GET /api/collections?tag=旅行
```

V1 可先用 `LIKE` 查询 JSON 字符串。V2 如果需要严格查询，再拆成标签关联表。

### 任务 4：分页和排序

接口：

```text
GET /api/collections?page=1&pageSize=20&sort=date_desc
```

支持排序：

1. `created_desc`
2. `created_asc`
3. `date_desc`
4. `date_asc`

### 任务 5：图片上传接口

接口：

```text
POST /api/collections/:id/image
```

技术实现：

1. 使用 `multer` 接收 multipart 文件。
2. 文件保存到 `backend/uploads/collections/`。
3. 数据库写入 `image_url`。
4. 返回图片访问 URL。

### 任务 6：图片删除接口

接口：

```text
DELETE /api/collections/:id/image
```

实现重点：

1. 删除本地图片文件。
2. 清空数据库中的 `image_url`。
3. 如果文件不存在，也要返回可理解的错误。

### 阶段三验收标准

1. 成员 3 可以完成搜索、筛选、分页页面。
2. 成员 2 可以完成图片上传和删除。
3. Mock 数据足够支撑收藏墙效果展示。
4. 接口错误信息清晰，方便成员 5 记录 Bug。

---

## 七、阶段四：V2.1 数据扩展与联调支持

### 阶段目标

为用户主页、动态分类和公开收藏做数据准备。

### 任务 1：扩展 collections 表

新增字段建议：

```sql
ALTER TABLE collections ADD COLUMN user_id INTEGER;
ALTER TABLE collections ADD COLUMN visibility TEXT DEFAULT 'private';
ALTER TABLE collections ADD COLUMN category_template TEXT;
ALTER TABLE collections ADD COLUMN custom_fields TEXT;
```

### 任务 2：完善 categories 接口

接口：

```text
GET /api/categories
GET /api/categories/:id
```

用途：

1. 成员 2 根据类别渲染动态表单。
2. 成员 3 根据类别展示不同信息。
3. 成员 4 根据类别设计专属图标和样式。

### 任务 3：支持用户主页统计

接口：

```text
GET /api/users/:id/stats
```

返回内容：

1. 收藏总数。
2. 分类数量。
3. 最近收藏。
4. 公开收藏数量。

### 任务 4：为成员 5 的 AI 模块预留日志表

建议 schema：

```sql
CREATE TABLE ai_usage_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  feature TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### 阶段四验收标准

1. 用户主页可以显示统计数据。
2. 动态表单可以拿到分类字段配置。
3. 公开/私密字段已经预留。
4. AI 使用记录可以在后续版本扩展。

---

## 八、阶段五：联调、Bug 修复和最终交付

### 阶段目标

在成员 2、3、5 完成页面和 AI 接入后，成员 1 负责后端稳定性和接口问题收尾。

### 任务 1：冻结 API Contract

需要冻结：

1. 收藏字段。
2. 图片字段。
3. AI 写入字段。
4. 用户统计字段。
5. 搜索筛选参数。

### 任务 2：配合成员 2 联调创建流程

重点检查：

1. 创建收藏。
2. 上传图片。
3. 编辑收藏。
4. 删除图片。
5. 表单错误返回。

### 任务 3：配合成员 3 联调浏览流程

重点检查：

1. 列表分页。
2. 搜索关键词。
3. 分类筛选。
4. 标签筛选。
5. 详情页数据完整性。

### 任务 4：配合成员 5 联调 AI 和测试

重点检查：

1. AI 输出能否保存进收藏。
2. AI 失败时是否影响主流程。
3. 测试用例是否能稳定运行。
4. Bug 是否能复现和修复。

### 任务 5：整理后端交付说明

需要写清楚：

1. 如何启动后端。
2. 如何初始化数据库。
3. 如何导入 seed 数据。
4. API 地址列表。
5. 常见错误排查。

### 阶段五验收标准

1. Demo 前核心接口无阻塞 Bug。
2. 后端启动步骤清晰。
3. 成员 2、3、5 都能成功调用接口。
4. 成员 6 可以根据接口和数据说明写报告。

---

## 九、最终交付物清单

| 交付物 | 用途 |
|--------|------|
| `backend/src/db/schema.sql` | 数据库结构 |
| `backend/src/db/seed.js` | Mock 数据生成 |
| `backend/src/routes/collections.routes.js` | 收藏 API |
| `backend/src/routes/upload.routes.js` | 图片上传 API |
| `backend/src/routes/categories.routes.js` | 分类 API |
| `API_Contract.md` | 给其他成员联调用 |
| `Backend_Setup.md` | 后端启动说明 |
| Postman Collection | API 自测和 Demo 验证 |

---

## 十、成员 1 最终汇报重点

成员 1 在汇报中应重点说明：

1. 如何设计收藏数据结构。
2. 如何用 API 支撑创建、展示、搜索和 AI 保存。
3. 如何提供 Mock 数据支持前端开发和 Demo。
4. 如何通过统一错误处理降低联调成本。
5. 后续如何从 SQLite 迁移到 PostgreSQL。
