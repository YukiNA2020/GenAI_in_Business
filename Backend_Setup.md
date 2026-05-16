# Collection Journey App — 后端交付说明

> **版本**：V1.0  
> **日期**：2026-05-16  
> **负责人**：成员 A / 成员 1，由该成员的 AI 工具协助更新  
> **用途**：供成员 2、3、5 启动后端、联调接口和排查问题使用；成员 6 撰写报告参考。

---

## 一、环境要求

| 依赖 | 版本要求 | 说明 |
|------|----------|------|
| Node.js | >= 18.x | 推荐 20.x LTS |
| npm | >= 9.x | 随 Node.js 自带 |
| 操作系统 | Windows / macOS / Linux | 无平台限制 |

> 后端使用纯 JavaScript 的 `sql.js`（SQLite WASM 版本），无需安装任何原生编译工具或数据库引擎。

---

## 二、快速启动

### 2.1 安装依赖

```bash
cd backend
npm install
```

### 2.2 初始化数据库 + 导入 Mock 数据

```bash
npm run seed
```

执行后会：
1. 自动创建 `backend/data/collections.db` 数据库文件
2. 执行 `schema.sql` 建表（collections / users / categories / ai_usage_logs）
3. 插入 1 个演示用户 + 8 个分类 + 15 条收藏数据

> seed 脚本可重复执行，每次会清空旧数据再重新插入，ID 从 1 开始。

### 2.3 启动服务

```bash
# 开发模式（文件变更自动重启）
npm run dev

# 生产模式
npm start
```

默认端口：**3000**

### 2.4 验证启动

```bash
curl http://localhost:3000/api/health
```

预期返回：

```json
{"success":true,"message":"Collection Journey API is running"}
```

---

## 三、项目结构

```
backend/
├── package.json              # 项目依赖与脚本
├── src/
│   ├── server.js             # 服务入口（端口 3000）
│   ├── app.js                # Express 应用配置（CORS/JSON/静态文件/路由挂载）
│   ├── db/
│   │   ├── connection.js     # 数据库连接模块（sql.js 初始化/持久化）
│   │   ├── schema.sql        # 数据库表结构（4 张表）
│   │   └── seed.js           # Mock 数据生成脚本
│   ├── routes/               # 路由层（URL 映射 + Zod Schema 定义）
│   ├── controllers/          # 控制器层（请求解析/响应构建/ID 校验）
│   ├── services/             # 服务层（业务逻辑/camelCase↔snake_case 转换）
│   ├── repositories/         # 仓库层（SQL 查询/数据持久化）
│   ├── middlewares/          # 中间件（Zod 校验/错误处理）
│   └── utils/                # 工具函数（统一响应格式）
├── uploads/
│   └── collections/          # 收藏图片上传目录（自动创建）
├── data/
│   └── collections.db        # SQLite 数据库文件（seed 后自动生成）
└── tests/                    # 测试脚本
```

### 分层调用关系

```
routes → validate middleware → controller → service → repository → sql.js → collections.db
                                              ↑
                                         FIELD_MAP
                                   (camelCase ↔ snake_case)
```

---

## 四、API 端点汇总

| 方法 | 路径 | 说明 | 联调方 |
|------|------|------|--------|
| `GET` | `/api/health` | 健康检查 | 全体 |
| `POST` | `/api/collections` | 创建收藏 | 成员 2、5 |
| `GET` | `/api/collections` | 收藏列表（搜索/筛选/分页/排序） | 成员 3 |
| `GET` | `/api/collections/:id` | 收藏详情 | 成员 3 |
| `PUT` | `/api/collections/:id` | 更新收藏（部分更新） | 成员 2、5 |
| `DELETE` | `/api/collections/:id` | 删除收藏 | 成员 2 |
| `POST` | `/api/collections/:id/image` | 上传图片（multipart/form-data） | 成员 2 |
| `DELETE` | `/api/collections/:id/image` | 删除图片 | 成员 2 |
| `GET` | `/api/categories` | 分类列表 | 成员 2、3、5 |
| `GET` | `/api/categories/:id` | 分类详情（slug 查询） | 成员 2、3 |
| `GET` | `/api/users/:id/stats` | 用户收藏统计 | 成员 5 |

### 查询参数（列表接口）

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `page` | number | `1` | 页码 |
| `pageSize` | number | `20` | 每页数量 |
| `keyword` | string | — | 搜索 title/story/location/tags |
| `category` | string | — | 精确匹配英文 slug |
| `tag` | string | — | 标签子串匹配 |
| `sort` | string | `created_desc` | created_desc / created_asc / date_desc / date_asc |

### 响应格式

**成功**：`{ success: true, data: ..., message: "" }`
- 创建返回 `201`，其余返回 `200`
- 删除成功 `data` 为 `null`

**失败**：`{ success: false, error: { code, message, fields? } }`
- `fields` 仅在 `VALIDATION_ERROR` 时出现，映射字段名→错误提示

---

## 五、数据库表说明

### 5.1 collections（收藏表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INTEGER PK | 自增主键 |
| `title` | TEXT NOT NULL | 收藏标题 |
| `category` | TEXT | 分类英文 slug（如 mineral/crystal/vinyl） |
| `date_acquired` | TEXT | 获取日期 |
| `location` | TEXT | 获取地点 |
| `story` | TEXT | 收藏故事/备注 |
| `image_url` | TEXT | 图片路径 |
| `tags` | TEXT | JSON 数组字符串（如 `'["旅行","明信片"]'`） |
| `created_at` | TEXT | 创建时间 |
| `updated_at` | TEXT | 更新时间 |
| `user_id` | INTEGER | 关联用户 ID |
| `visibility` | TEXT | `"public"` 或 `"private"` |
| `category_template` | TEXT | 创建时使用的分类模板 slug |
| `custom_fields` | TEXT | 分类自定义字段（JSON 字符串） |

### 5.2 users（用户表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INTEGER PK | 自增主键 |
| `username` | TEXT UNIQUE | 用户名 |
| `email` | TEXT UNIQUE | 邮箱 |
| `avatar_url` | TEXT | 头像路径 |
| `bio` | TEXT | 个人简介 |
| `created_at` | TEXT | 创建时间 |
| `updated_at` | TEXT | 更新时间 |

### 5.3 categories（分类表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT PK | 语义化英文 slug（mineral/crystal/vinyl...） |
| `name` | TEXT NOT NULL | 中文名称 |
| `icon` | TEXT | Material Icon 名称 |
| `fields` | TEXT | JSON 数组（该类别特有表单字段配置） |
| `display_priority` | INTEGER | 排序优先级（越小越靠前） |
| `created_at` | TEXT | 创建时间 |

### 5.4 ai_usage_logs（AI 使用日志表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INTEGER PK | 自增主键 |
| `user_id` | INTEGER | 关联用户 ID |
| `feature` | TEXT | AI 功能名称（如 title_generation） |
| `created_at` | TEXT | 调用时间 |

---

## 六、命名约定

| 层级 | 命名方式 | 示例 |
|------|----------|------|
| 数据库字段 | snake_case | `image_url`, `created_at`, `user_id` |
| API 请求/响应 | camelCase | `imageUrl`, `createdAt`, `userId` |
| 分类 ID | 英文 slug | `mineral`, `vinyl`, `postcard` |
| API 路径 | kebab-case 或 camelCase | `/api/collections`, `/api/users/:id/stats` |

**重要**：`category` 字段在数据库中存储的是英文 slug（如 `postcard`），不是中文名称（如 `明信片`）。成员 5 的 AI 模块如需将中文分类名转换为 slug，可调用 `GET /api/categories` 获取 id↔name 映射表。

---

## 七、各成员常用场景

### 7.1 成员 2（创建/编辑/上传）

```bash
# 创建收藏
curl -X POST http://localhost:3000/api/collections \
  -H "Content-Type: application/json" \
  -d '{"title":"新收藏","category":"postcard","tags":["旅行"]}'

# 上传图片
curl -X POST http://localhost:3000/api/collections/1/image \
  -F "image=@/path/to/photo.jpg"

# 更新收藏（部分字段）
curl -X PUT http://localhost:3000/api/collections/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"修改标题","visibility":"public"}'
```

### 7.2 成员 3（浏览/搜索/筛选）

```bash
# 收藏列表（默认分页）
curl http://localhost:3000/api/collections

# 关键词搜索
curl "http://localhost:3000/api/collections?keyword=东京"

# 分类筛选
curl "http://localhost:3000/api/collections?category=postcard"

# 标签筛选
curl "http://localhost:3000/api/collections?tag=旅行"

# 组合查询
curl "http://localhost:3000/api/collections?keyword=水晶&category=crystal&sort=date_desc"

# 收藏详情
curl http://localhost:3000/api/collections/1

# 分类列表（获取全部 8 个分类及图标）
curl http://localhost:3000/api/categories
```

### 7.3 成员 5（AI/用户主页/测试）

```bash
# 用户统计
curl http://localhost:3000/api/users/1/stats

# 分类列表（获取英文slug↔中文名称映射，用于AI分类结果转换）
curl http://localhost:3000/api/categories

# 写入 AI 生成内容（与普通创建相同）
curl -X POST http://localhost:3000/api/collections \
  -H "Content-Type: application/json" \
  -d '{
    "title":"AI生成的标题",
    "category":"postcard",
    "tags":["AI标签","旅行"],
    "story":"AI生成的故事文本",
    "customFields":"{\"ai_generated\":true}"
  }'
```

---

## 八、常见问题排查

### 8.1 端口被占用

```
Error: listen EADDRINUSE :::3000
```

解决方法：
```bash
# Windows: 查找并结束占用进程
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -i :3000
kill -9 <PID>
```

### 8.2 数据库状态异常

如果怀疑数据库损坏或数据不一致，重新初始化：

```bash
# 删除数据库文件并重新 seed
rm backend/data/collections.db   # macOS/Linux
del backend\data\collections.db  # Windows

npm run seed
```

### 8.3 接口返回 500 错误

1. 检查终端日志，通常有具体错误信息
2. 最常见原因：数据库未初始化 → 执行 `npm run seed`
3. 检查 `backend/data/` 目录是否存在且可写

### 8.4 图片上传失败

1. 确认图片格式：仅支持 jpg/jpeg/png/gif/webp
2. 确认图片大小：不超过 5 MB
3. 确认表单字段名为 `image`（不是 `file` 或 `photo`）
4. 确认 Content-Type 为 `multipart/form-data`

### 8.5 CORS 错误（前端调用时）

后端已配置 `cors()` 允许所有来源。如果仍报错：
1. 确认后端已正常启动
2. 确认请求的 Base URL 是 `http://localhost:3000`
3. 不要在前端设置非标准的请求头

### 8.6 错误码速查

| 错误码 | HTTP 状态 | 含义 |
|--------|-----------|------|
| `VALIDATION_ERROR` | 400 | 字段校验失败，查看 `fields` 了解具体字段 |
| `INVALID_ID` | 400 | ID 参数不是合法数字 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `NO_FILE` | 400 | 图片上传时未提供文件 |
| `NO_IMAGE` | 400 | 删除图片时该收藏无图片 |
| `FILE_NOT_FOUND` | 404 | 图片文件在磁盘上不存在 |
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |

---

## 九、技术说明

### 9.1 sql.js 注意事项

- sql.js 是基于 Emscripten 编译的纯 JavaScript SQLite 实现，无需原生依赖
- 数据库在内存中运行，写操作后需调用 `saveDb()` 持久化到磁盘
- 数据库文件路径：`backend/data/collections.db`
- 生产环境建议迁移到 `better-sqlite3` 或 PostgreSQL

### 9.2 Schema 迁移兼容性

- `connection.js` 启动时自动执行 `schema.sql` 中的新语句
- `CREATE TABLE IF NOT EXISTS` 和 `ALTER TABLE ADD COLUMN` 的重复执行是安全的
- 如果已在旧数据库上运行，重复的 `ALTER TABLE` 会被静默跳过
- 新增表或字段只需追加到 `schema.sql`，无需编写单独迁移脚本

### 9.3 AI 可写入字段

以下 collections 字段可由成员 5 的 AI 模块写入：

| 字段 | AI 角色 |
|------|---------|
| `title` | AI 标题生成 |
| `category` | AI 分类建议（需转为英文 slug） |
| `tags` | AI 标签生成 |
| `story` | AI 故事生成 |
| `location` | AI 图片识别地点 |
| `dateAcquired` | AI 推断日期 |
| `customFields` | AI 填充分类专属字段 |

---

## 十、与其他成员的接口合同

完整的 API 字段定义、请求格式、响应格式和错误码已冻结在 `API_Contract.md`。后端实现以该文档为准。

如有接口需求变更，请先与成员 1 确认，并在 `Status.md` 中记录。
