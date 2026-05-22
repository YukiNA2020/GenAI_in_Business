# Collection Journey App — API Contract (Frozen)

> **版本**：V1.0  
> **冻结日期**：2026-05-15  
> **负责人**：成员 A / 成员 1，由该成员的 AI 工具协助更新  
> **用途**：供成员 2、3、5 联调使用；成员 6 撰写报告参考。  
> **重要**：本文档中所有字段、参数和响应格式已冻结。后续修改需在团队中确认并更新本文档。

---

## 一、基础信息

| 项目 | 值 |
|------|-----|
| Base URL | `http://localhost:3000` |
| 请求格式 | `application/json`（图片上传使用 `multipart/form-data`） |
| 响应格式 | `{ success: boolean, data?: any, message?: string, error?: { code, message, fields? } }` |
| 命名约定 | API 使用 camelCase；数据库使用 snake_case |

---

## 二、统一响应格式

### 成功响应

```json
{
  "success": true,
  "data": { ... },
  "message": ""
}
```

- 创建成功返回 `201 Created`，其余返回 `200 OK`
- 删除成功时 `data` 为 `null`

### 失败响应

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description",
    "fields": { "fieldName": "Error message" }
  }
}
```

- `fields` 仅在 `VALIDATION_ERROR` 时出现，将表单字段名映射到错误提示，方便前端高亮对应输入框

---

## 三、Collections 收藏接口

### 3.1 收藏字段定义（已冻结）

| API 字段 (camelCase) | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | number | — | 自增主键，创建时不需要传 |
| `title` | string | **是** | 收藏标题，不能为空 |
| `category` | string | 否 | 分类 slug，如 `"mineral"`、`"vinyl"`、`"postcard"` |
| `dateAcquired` | string | 否 | 获取日期，格式 `"YYYY-MM-DD"` |
| `location` | string | 否 | 获取地点 |
| `story` | string | 否 | 收藏故事/备注 |
| `imageUrl` | string | 否 | 图片路径，由上传接口自动填充 |
| `tags` | string[] | 否 | 标签数组，如 `["旅行", "明信片"]` |
| `createdAt` | string | — | 创建时间（自动生成） |
| `updatedAt` | string | — | 更新时间（自动刷新） |
| `userId` | number | 否 | 关联用户 ID |
| `visibility` | string | 否 | `"public"` 或 `"private"`，默认 `"private"` |
| `categoryTemplate` | string | 否 | 创建时使用的分类模板 slug |
| `customFields` | string | 否 | 分类自定义字段，JSON 字符串 |

### 3.2 创建收藏

```
POST /api/collections
Content-Type: application/json
```

**请求体（最小）**：
```json
{ "title": "我的收藏" }
```

**请求体（完整）**：
```json
{
  "title": "紫水晶晶簇 — 阿根廷",
  "category": "crystal",
  "dateAcquired": "2024-11-15",
  "location": "Buenos Aires, Argentina",
  "story": "在阿根廷旅行时发现的紫水晶...",
  "tags": ["水晶", "紫水晶", "阿根廷"],
  "userId": 1,
  "visibility": "private",
  "categoryTemplate": "crystal",
  "customFields": "{\"type\":\"amethyst\",\"color\":\"purple\"}"
}
```

**成功响应 (201)**：
```json
{
  "success": true,
  "data": {
    "id": 16,
    "title": "紫水晶晶簇 — 阿根廷",
    "category": "crystal",
    "dateAcquired": "2024-11-15",
    "location": "Buenos Aires, Argentina",
    "story": "在阿根廷旅行时发现的紫水晶...",
    "imageUrl": null,
    "tags": ["水晶", "紫水晶", "阿根廷"],
    "createdAt": "2026-05-15 08:00:00",
    "updatedAt": "2026-05-15 08:00:00",
    "userId": 1,
    "visibility": "private",
    "categoryTemplate": "crystal",
    "customFields": "{\"type\":\"amethyst\",\"color\":\"purple\"}"
  },
  "message": "Collection created"
}
```

**失败响应 (400)**：
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "title: title is required",
    "fields": { "title": "title is required" }
  }
}
```

### 3.3 收藏列表

```
GET /api/collections?page=1&pageSize=20&keyword=&category=&tag=&sort=created_desc
```

**查询参数（已冻结）**：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `page` | number | `1` | 页码 |
| `pageSize` | number | `20` | 每页数量 |
| `keyword` | string | — | 在 title/story/location/tags 中模糊搜索 |
| `category` | string | — | 精确匹配分类 slug |
| `tag` | string | — | 在 tags 中模糊匹配（V1 含子串匹配） |
| `sort` | string | `created_desc` | 排序：`created_desc` / `created_asc` / `date_desc` / `date_asc` |

> 多个筛选参数可组合使用（AND 逻辑）

**成功响应**：
```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "total": 15,
    "page": 1,
    "pageSize": 20
  }
}
```

### 3.4 收藏详情

```
GET /api/collections/:id
```

**成功响应**：返回完整 collection 对象
**失败 (404)**：`{ "success": false, "error": { "code": "NOT_FOUND", "message": "Collection not found" } }`  
**失败 (400)**：`{ "success": false, "error": { "code": "INVALID_ID", "message": "Collection id must be a number" } }`

### 3.5 更新收藏

```
PUT /api/collections/:id
Content-Type: application/json
```

- 支持部分更新：只需传要改的字段，未传字段保留原值
- 所有字段均为 optional / nullable
- 传 `null` 可清空字段值
- 自动刷新 `updatedAt`

**请求体示例**：
```json
{ "title": "修改后的标题", "visibility": "public" }
```

**成功响应**：返回更新后的完整 collection 对象
**失败 (404)**：collection 不存在
**失败 (400)**：非法 ID

### 3.6 删除收藏

```
DELETE /api/collections/:id
```

**成功响应**：
```json
{ "success": true, "data": null, "message": "Collection deleted" }
```

---

## 四、图片接口

### 4.1 上传图片

```
POST /api/collections/:id/image
Content-Type: multipart/form-data
```

| 字段 | 说明 |
|------|------|
| `image` | 图片文件（**必填**），表单字段名须为 `image` |

**文件限制**：

| 限制 | 值 |
|------|-----|
| 允许格式 | jpg, jpeg, png, gif, webp |
| 最大大小 | 5 MB |
| 存储位置 | `backend/uploads/collections/` |
| 文件名格式 | `collection-{id}-{timestamp}{ext}` |

**成功响应**：返回更新后的完整 collection 对象（`imageUrl` 已填充）
**失败 (400)**：无文件 → `NO_FILE`；非法 ID → `INVALID_ID`
**失败 (404)**：collection 不存在

> 上传新图片时会自动删除该 collection 的旧图片文件

### 4.2 删除图片

```
DELETE /api/collections/:id/image
```

**成功响应**：
```json
{ "success": true, "data": null, "message": "Image deleted" }
```

**失败 (400)**：`NO_IMAGE`（collection 无图片可删）
**失败 (404)**：collection 不存在或文件已丢失

---

## 五、Categories 分类接口

### 5.1 分类字段定义（已冻结）

| API 字段 (camelCase) | 类型 | 说明 |
|------|------|------|
| `id` | string | 语义化 slug，如 `"mineral"` |
| `name` | string | 中文名称 |
| `icon` | string | Material Icon 名称 |
| `fields` | string[] | 该类别特有表单字段配置 |
| `displayPriority` | number | 排序优先级（越小越靠前） |
| `createdAt` | string | 创建时间 |

### 5.2 分类列表

```
GET /api/categories
```

按 `displayPriority` ASC 排序，`fields` 已解析为数组。

### 5.3 分类详情

```
GET /api/categories/:id
```

- `:id` 为语义化 slug（如 `"mineral"`、`"vinyl"`）
- 不存在返回 404

---

## 六、Users 用户接口

### 6.1 用户统计

```
GET /api/users/:id/stats
```

**响应字段（已冻结）**：

| 字段 (camelCase) | 类型 | 说明 |
|------|------|------|
| `totalCollections` | number | 该用户收藏总数 |
| `categoryCount` | number | 去重后的分类数量 |
| `publicCollections` | number | 公开收藏数量 |
| `recentCollections` | array | 最近 5 条收藏，每条为完整 collection 对象 |

**失败 (404)**：用户不存在
**失败 (400)**：非法 ID

---

## 七、AI 可写入字段

以下 collections 字段可由成员 5 的 AI 模块写入：

| 字段 | AI 角色 |
|------|---------|
| `title` | AI 标题生成 |
| `category` | AI 分类建议 |
| `tags` | AI 标签生成 |
| `story` | AI 故事生成 |
| `location` | AI 图片识别地点 |
| `dateAcquired` | AI 推断日期 |
| `customFields` | AI 填充分类专属字段 |

---

## 八、错误码汇总（已冻结）

| 错误码 | HTTP 状态 | 说明 |
|------|------|------|
| `VALIDATION_ERROR` | 400 | 字段校验失败，`fields` 中含逐字段错误 |
| `INVALID_ID` | 400 | ID 参数不是合法数字 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `NO_FILE` | 400 | 图片上传时未提供文件或格式不支持 |
| `NO_IMAGE` | 400 | 删除图片时该 collection 无图片 |
| `FILE_NOT_FOUND` | 404 | 图片文件在磁盘上不存在 |
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |

---

## 九、API 端点汇总

| 方法 | 路径 | 说明 | 联调方 |
|------|------|------|--------|
| `GET` | `/api/health` | 健康检查 | 全体 |
| `POST` | `/api/collections` | 创建收藏 | 成员 2、5 |
| `GET` | `/api/collections` | 收藏列表（搜索/筛选/分页/排序） | 成员 3 |
| `GET` | `/api/collections/:id` | 收藏详情 | 成员 3 |
| `PUT` | `/api/collections/:id` | 更新收藏 | 成员 2、5 |
| `DELETE` | `/api/collections/:id` | 删除收藏 | 成员 2 |
| `POST` | `/api/collections/:id/image` | 上传图片 | 成员 2 |
| `DELETE` | `/api/collections/:id/image` | 删除图片 | 成员 2 |
| `GET` | `/api/categories` | 分类列表 | 成员 2、3、4 |
| `GET` | `/api/categories/:id` | 分类详情 | 成员 2、3 |
| `GET` | `/api/users/:id/stats` | 用户统计 | 成员 5 |

---

## 十、命名规则总结

| 层级 | 命名方式 | 示例 |
|------|------|------|
| 数据库字段 | snake_case | `image_url`, `created_at`, `user_id` |
| API 请求/响应字段 | camelCase | `imageUrl`, `createdAt`, `userId` |
| 分类 ID | 英文 slug | `mineral`, `vinyl`, `postcard` |
| API 路径 | kebab-case 或 camelCase | `/api/collections`, `/api/users/:id/stats` |
