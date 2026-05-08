# V2.0 收藏体验强化版 - 开发技术路线

> **历史文档标记**：暂时不用本文档进行实际任务开发，仅为项目立项时的一种参考方案。当前实际开发请以根目录的 `Final_Team_Work_Division.md` 和五份 `Member_*.md` 成员任务文档为准。

## 版本目标

V2.0 的目标是提高用户留存，让用户不只是试用一次，而是愿意长期使用。

V1.0 回答的问题是：这个产品有没有用？
V2.0 回答的问题是：用户会不会持续使用？

---

## V2.1：个人收藏主页

### 产品功能

- 每个用户拥有个人收藏主页
- 展示收藏数量
- 展示主要收藏类别
- 展示最近记录
- 支持头像、昵称和个人简介

### 技术路线

#### 用户系统设计

**注册/登录方案**：
- 方案A：手机号 + 验证码登录（国内常用）
- 方案B：邮箱登录
- 方案C：微信/Google/Apple 一键登录（推荐，用户体验最佳）

#### 数据库扩展

**新增 users 表**：
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**关联收藏表**：
```sql
ALTER TABLE collections ADD COLUMN user_id INTEGER;
ALTER TABLE collections ADD COLUMN is_public INTEGER DEFAULT 0;
```

#### API 设计

```
POST   /api/auth/register        - 用户注册
POST   /api/auth/login           - 用户登录
GET    /api/auth/me              - 获取当前用户信息
PUT    /api/users/profile         - 更新个人资料
GET    /api/users/:id/profile     - 获取用户公开主页
GET    /api/users/:id/collections - 获取用户收藏列表
```

#### 前端页面

```
┌─────────────────────────────────────┐
│  ← 返回                              │
├─────────────────────────────────────┤
│         ┌───────┐                   │
│         │ Avatar│      [编辑资料]   │
│         └───────┘                   │
│         Username                    │
│         "收藏不只是物品，是记忆"     │
├─────────────────────────────────────┤
│  📦 收藏数    📂 类别    📅 年份     │
│    42         8        3           │
├─────────────────────────────────────┤
│  [矿石收藏]  [水晶收藏]  [旅行]       │
│  ┌─────┐  ┌─────┐  ┌─────┐        │
│  │ ... │  │ ... │  │ ... │        │
│  └─────┘  └─────┘  └─────┘        │
├─────────────────────────────────────┤
│  最近收藏：                          │
│  ┌─────┐  ┌─────┐  ┌─────┐        │
│  └─────┘  └─────┘  └─────┘        │
└─────────────────────────────────────┘
```

---

## V2.2：收藏分类体验优化

### 产品功能

- 优化矿石和水晶收藏体验
- 优化票根和旅行纪念品收藏体验
- 优化黑胶和音乐收藏体验
- 优化明信片、邮票和小物件收藏体验
- 不同收藏类别可以有不同的展示重点

### 技术路线

#### 收藏类别模板系统

**类别定义**：

```json
{
  "categories": [
    {
      "id": "minerals",
      "name": "矿石收藏",
      "icon": "💎",
      "fields": [
        {"name": "产地", "type": "text"},
        {"name": "成分", "type": "text"},
        {"name": "重量", "type": "number"},
        {"name": "收藏等级", "type": "select", "options": ["普通", "稀有", "珍品"]}
      ],
      "display_priority": ["image", "title", "产地", "收藏等级"]
    },
    {
      "id": "vinyl",
      "name": "黑胶唱片",
      "icon": "🎵",
      "fields": [
        {"name": "艺术家", "type": "text"},
        {"name": "专辑名称", "type": "text"},
        {"name": "发行年份", "type": "year"},
        {"name": "唱片公司", "type": "text"}
      ],
      "display_priority": ["image", "title", "艺术家", "发行年份"]
    },
    {
      "id": "tickets",
      "name": "票根收藏",
      "icon": "🎫",
      "fields": [
        {"name": "活动名称", "type": "text"},
        {"name": "活动类型", "type": "select", "options": ["演唱会", "展览", "电影", "体育", "其他"]},
        {"name": "举办地点", "type": "text"},
        {"name": "参与人数", "type": "number"}
      ],
      "display_priority": ["image", "title", "活动名称", "地点"]
    }
  ]
}
```

#### 动态表单渲染

- 前端根据类别定义动态渲染表单字段
- 不同类别显示不同的输入组件（文本、选择、数字、日期等）
- 详情页根据 display_priority 决定展示顺序

#### 数据库扩展

```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  fields TEXT,  -- JSON 格式存储字段定义
  display_priority TEXT,  -- JSON 格式
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE collections ADD COLUMN category_template TEXT;
ALTER TABLE collections ADD COLUMN custom_fields TEXT;  -- 存储自定义字段值
```

#### API 设计

```
GET    /api/categories              - 获取所有类别模板
GET    /api/categories/:id          - 获取类别详情
POST   /api/categories              - 创建自定义类别（未来）
GET    /api/collections?category=xxx - 按类别筛选收藏
```

---

## V2.3：AI 图片识别增强

### 产品功能

- AI 根据图片识别可能的物品类型
- AI 根据图片推荐标题
- AI 根据图片推荐类别
- AI 根据图片推荐标签
- AI 根据图片生成简短说明

### 技术路线

#### 图片识别技术选型

**方案A：云服务（推荐）**
- **Google Cloud Vision API**：物体识别、标签提取成熟
- **AWS Rekognition**：Amazon生态，识别准确
- **阿里云视觉智能**：国内服务，响应快
- **腾讯云视觉**：国内服务，中文识别好

**方案B：本地模型**
- **TensorFlow Lite**：可集成到 App，但精度有限
- **MLKit（Google）**：移动端优化，iOS/Android 都支持
- **Core ML + 自训练模型**：Apple 生态，效果好但需要标注数据

**方案C：AI API（与 V1.2 统一）**
- **OpenAI Vision API（GPT-4V）**：可识别图片并生成描述
- **Claude Vision**：Anthropic 最新模型

#### 推荐架构：OpenAI Vision

```python
# Python 后端示例
import openai

def analyze_collection_image(image_url):
    response = openai.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": """你是一个收藏品识别助手。
                    请分析这张图片，识别可能的收藏品类型，
                    并给出标题建议、类别建议、标签建议和简短描述。"""},
                    {"type": "image_url", "image_url": {"url": image_url}}
                ]
            }
        ]
    )
    return parse_response(response)
```

#### 响应格式设计

```json
{
  "suggested_title": " vintage 1970s 黑胶唱片",
  "suggested_category": "黑胶唱片",
  "suggested_tags": ["复古", "1970s", "摇滚", "黑胶", "收藏级"],
  "ai_description": "这是一张1970年代的黑胶唱片，保存状态良好..."
}
```

#### 技术实现流程

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 用户上传 │───▶│ 图片存储 │───▶│ 调用 AI │───▶│ 返回建议 │
│   图片   │    │  (S3)   │    │  识别   │    │  给用户  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                     │                           │
                     └───────────────────────────┘
                          图片 URL 传给 AI
```

#### 优化策略

1. **图片预处理**：压缩到 1MB 以内，减少传输时间
2. **异步处理**：图片识别用队列异步处理，不阻塞 UI
3. **结果缓存**：相同图片的识别结果缓存，避免重复调用
4. **降级方案**：AI 不可用时跳过图片识别，用户手动填写

#### API 设计

```
POST /api/ai/analyze-image
  - 输入：图片文件或图片 URL
  - 输出：标题、类别、标签、描述建议
  - 限制：需要鉴权，免费用户每天 N 次
```

---

## V2.4：记忆和故事增强

### 产品功能

- AI 生成更有情感的收藏故事
- 支持不同写作风格
- 支持简洁风、手账风、旅行日记风、复古风等
- AI 可以生成月度或年度收藏回顾

### 技术路线

#### 风格化故事生成

**提示词模板系统**：

```json
{
  "styles": {
    "concise": {
      "name": "简洁风",
      "description": "简洁有力的短句",
      "word_limit": 50,
      "prompt_template": "用简洁有力的短句描述这件收藏品，控制在50字以内..."
    },
    "scrapbook": {
      "name": "手账风",
      "description": "温暖细腻的手账风格",
      "word_limit": 150,
      "prompt_template": "用温暖细腻的手账风格描述这件收藏品的来历和情感..."
    },
    "travel": {
      "name": "旅行日记风",
      "description": "如旅行日记般记录",
      "word_limit": 200,
      "prompt_template": "像写旅行日记一样，记录这件旅行纪念品的获得过程和回忆..."
    },
    "vintage": {
      "name": "复古风",
      "description": "带有年代感和怀旧感",
      "word_limit": 180,
      "prompt_template": "用复古怀旧的语气，讲述这件收藏品的故事，仿佛时光倒流..."
    }
  }
}
```

#### 年度收藏回顾生成

**年度回顾功能**：

```
输入：用户一年内的所有收藏
输出：年度收藏故事 + 数据统计

AI 处理流程：
1. 统计：收藏数量、各类别分布、获得地点、旅行记录等
2. 故事：为每类收藏生成代表性故事片段
3. 总结：生成年度收藏总结和感悟
4. 设计：配合视觉模板输出回顾页面
```

#### API 设计

```
POST /api/ai/generate-story
  - 输入：收藏信息 + 风格选择
  - 输出：生成的故事文本

POST /api/ai/generate-yearly-review
  - 输入：用户 ID + 年份
  - 输出：年度回顾内容（故事 + 数据）

GET  /api/ai/story-styles
  - 输出：支持的写作风格列表
```

#### 年度回顾数据结构

```json
{
  "year": 2024,
  "total_collections": 42,
  "category_summary": {
    "矿石": 15,
    "旅行纪念品": 12,
    "黑胶唱片": 8,
    "其他": 7
  },
  "locations": ["云南", "日本", "上海", "北京"],
  "top_tags": ["收藏", "旅行", "音乐", "自然"],
  "highlight_collection": { ... },
  "yearly_story": "2024年，你一共收藏了42件珍贵的记忆...",
  "generated_at": "2024-12-31"
}
```

---

## V2.0 风险清单

### 🔴 高风险

#### 1. 多 AI 服务集成复杂度
- **描述**：V2.0 涉及多个 AI 能力（图片识别 + 风格化故事 + 年度回顾），需要集成多个 API 或服务
- **影响**：开发和维护成本增加，多个故障点
- **缓解措施**：
  - 建立统一的 AI 服务抽象层
  - 制定标准接口，所有 AI 能力通过同一层调用
  - 实现熔断器模式，单个 AI 故障不影响整体

#### 2. 用户数据隐私合规
- **描述**：年度回顾需要分析用户所有收藏数据，涉及个人隐私
- **影响**：可能违反数据保护法规（如 GDPR、个人信息保护法）
- **缓解措施**：
  - 用户明确授权后才进行数据分析
  - 数据处理透明化，告知用户数据用途
  - 支持数据导出和删除功能

### 🟡 中风险

#### 3. 图片识别准确性不足
- **描述**：AI 图片识别可能出错，尤其是细分品类（如特定矿石种类、具体艺术家等）
- **影响**：用户需要大量修正，降低使用体验
- **缓解措施**：
  - 图片识别结果作为建议，用户可修改
  - 细分领域提供用户反馈机制，持续优化模型
  - 复杂物品建议用户手动补充信息

#### 4. 年度回顾生成质量不稳定
- **描述**：年度回顾涉及大量数据处理，生成的故事可能不够个性化
- **影响**：用户可能觉得回顾内容"敷衍"
- **缓解措施**：
  - 提供多个版本供选择
  - 结合具体数据（地点、日期、标签）生成个性化内容
  - 支持用户编辑和补充

#### 5. 用户认证系统安全
- **描述**：引入用户系统后，需要处理登录、token、敏感信息等安全问题
- **影响**：账号被盗、数据泄露等安全风险
- **缓解措施**：
  - 使用 OAuth2/JWT 实现安全认证
  - 敏感数据加密存储
  - 实现登录异常检测和告警

#### 6. 跨平台数据同步
- **描述**：用户可能在多设备使用，数据需要同步
- **影响**：多设备数据不一致、冲突等问题
- **缓解措施**：
  - 建立统一数据后端
  - 实现增量同步机制
  - 设计冲突解决策略（最后写入优先 or 用户选择）

### 🟢 低风险

#### 7. 年度回顾生成耗时
- **描述**：年度回顾涉及大量数据分析和生成，可能需要较长时间
- **影响**：用户等待体验差
- **缓解措施**：
  - 异步生成，后台处理，完成后通知
  - 生成过程中显示进度
  - 支持生成中途取消

#### 8. 自定义类别字段扩展
- **描述**：未来用户可能需要自定义字段，系统需要灵活扩展
- **影响**：数据库 schema 可能需要频繁变更
- **缓解措施**：
  - 使用 JSON 字段存储自定义字段，不改表结构
  - 预留字段扩展接口

---

## V2.0 技术选型总结

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 用户认证 | JWT + OAuth2 | 安全标准的认证方案 |
| AI 服务层 | 统一抽象层 | 解耦 AI 提供商，便于切换 |
| 图片识别 | OpenAI Vision / Google Vision | 云服务方案成熟 |
| 数据分析 | Python + Pandas | 年度回顾数据处理 |
| 存储 | PostgreSQL | 替代 SQLite，支持复杂查询 |
| 文件存储 | S3 / OSS | 云存储，可扩展 |

---

## V2.0 里程碑

1. ✅ 完成用户注册/登录/个人主页
2. ✅ 完成收藏类别模板系统
3. ✅ 完成 AI 图片识别功能
4. ✅ 完成风格化故事生成
5. ✅ 完成年度收藏回顾功能
6. ✅ 完成数据分析和可视化
7. ✅ 完成多设备同步机制
