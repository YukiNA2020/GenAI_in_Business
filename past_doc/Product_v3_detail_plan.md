# V3.0 分享与增长版 - 开发技术路线

> **历史文档标记**：暂时不用本文档进行实际任务开发，仅为项目立项时的一种参考方案。当前实际开发请以根目录的 `Final_Team_Work_Division.md` 和五份 `Member_*.md` 成员任务文档为准。

## 版本目标

V3.0 的目标是让产品从个人使用走向外部传播和早期社区增长。

---

## V3.1：收藏分享卡片

### 产品功能

- 用户可以生成单个收藏的精美分享卡片
- 分享卡片包含图片、标题、日期、地点和故事摘要
- 支持分享到 Instagram、TikTok、小红书、Pinterest 等平台
- 分享卡片可以带产品水印或链接

### 技术路线

#### 分享卡片设计

**卡片模板系统**：

```json
{
  "templates": [
    {
      "id": "classic",
      "name": "经典白框",
      "ratio": "1:1",
      "layout": {
        "background": "#FFFFFF",
        "image": {"x": 20, "y": 20, "width": "60%", "height": "60%"},
        "title": {"x": 20, "y": 75, "font": "serif", "size": 18},
        "story": {"x": 20, "y": 82, "font": "sans-serif", "size": 12, "maxLines": 3},
        "watermark": {"x": 80, "y": 95, "text": "Collection Journey"}
      }
    },
    {
      "id": "polaroid",
      "name": "宝丽来风",
      "ratio": "1:1.2",
      "layout": {
        "background": "#F5F5F5",
        "image": {"x": 10, "y": 5, "width": 280, "height": 280, "border": "white 8px"},
        "title": {"x": 10, "y": 85, "font": "手写体", "size": 16},
        "date": {"x": 10, "y": 90, "font": "monospace", "size": 10}
      }
    },
    {
      "id": "minimal",
      "name": "极简风",
      "ratio": "4:5",
      "layout": {
        "background": "#1A1A1A",
        "image": {"x": 0, "y": 0, "width": "100%", "height": "75%"},
        "title": {"x": 20, "y": 80, "font": "sans-serif", "color": "#FFFFFF", "size": 20},
        "tags": {"x": 20, "y": 88, "font": "sans-serif", "color": "#888888", "size": 12}
      }
    }
  ]
}
```

#### 分享卡片生成技术

**方案选型**：

1. **前端生成（推荐）**
   - Flutter：`canvas` + `RepaintBoundary` 截图
   - React Native：`react-native-view-shot` 截图
   - 优点：减少服务器负载，用户体验好
   - 缺点：需要针对不同平台适配

2. **后端生成**
   - Node.js：`sharp` + `canvas` 库
   - Python：`Pillow` 库
   - 优点：生成质量稳定
   - 缺点：增加服务器负载

#### 实现流程（前端方案）

```
┌──────────────────────────────────────────────┐
│                  分享流程                      │
├──────────────────────────────────────────────┤
│ 1. 用户点击"分享"按钮                         │
│ 2. 显示卡片模板选择器                         │
│ 3. 用户选择模板，预览效果                     │
│ 4. 用户确认后，使用 Canvas 渲染卡片            │
│ 5. 截图生成图片                              │
│ 6. 调用系统分享组件（share_plus）             │
│ 7. 选择分享到某个平台                         │
└──────────────────────────────────────────────┘
```

#### Flutter 分享实现

```dart
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';

// 生成分享卡片图片
Future<File> generateShareCard(Collection collection, String templateId) async {
  // 1. 创建画布
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(1080, 1080); // 或根据模板变化

  // 2. 绘制背景
  final bgPaint = Paint()..color = Colors.white;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

  // 3. 绘制图片
  // ... 根据模板绘制各个元素

  // 4. 截图保存
  final image = await recorder.endRecording().toImage(1080, 1080);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/share_card_${DateTime.now().millisSinceEpoch}.png');
  await file.writeAsBytes(byteData.buffer.asUint8List());

  return file;
}

// 分享
Future<void> shareCard(File cardImage) async {
  await Share.shareXFiles(
    [XFile(cardImage.path)],
    text: '来看看我的收藏！',
  );
}
```

#### 平台适配

**Instagram/TikTok**：
- 使用系统分享组件，选择对应 App
- 注意：Instagram Stories 需要特定格式（1080x1920）

**小红书**：
- 小红书没有开放分享 API
- 方案：生成分享卡片图片，用户手动保存后上传
- 或接入小红书 SDK（如果有）

**微信/微博**：
- 使用系统分享组件

#### API 设计

```
GET  /api/share/templates        - 获取分享模板列表
POST /api/share/generate          - 后端生成分享图（可选）
GET  /api/share/watermark        - 获取水印配置
```

#### 水印和追踪设计

- 水印：`Collection Journey` 字样 + 小图标
- 链接追踪：分享卡片包含 UTM 参数，追踪分享效果
- 短链：使用短链接服务（如 Branch、Firebase Dynamic Links）

---

## V3.2：公开收藏展示

### 产品功能

- 用户可以把部分收藏设为公开
- 其他用户可以浏览公开收藏
- 平台可以展示精选收藏
- 用户可以从他人的收藏中获得灵感

### 技术路线

#### 隐私权限设计

**收藏可见性**：
- `private`：仅自己可见
- `public`：所有人均可查看
- `unlisted`：链接可见，不在公开页面显示

**用户主页可见性**：
- `public`：所有人可见
- `private`：需要登录
- `hidden`：不在平台内展示

#### 数据库变更

```sql
ALTER TABLE collections ADD COLUMN visibility TEXT DEFAULT 'private';

CREATE TABLE featured_collections (
  id INTEGER PRIMARY KEY,
  collection_id INTEGER,
  featured_at TIMESTAMP,
  featured_by TEXT,  -- 运营人员
  FOREIGN KEY (collection_id) REFERENCES collections(id)
);

CREATE INDEX idx_public_collections ON collections(user_id, visibility) WHERE visibility = 'public';
```

#### 探索/发现页面

```
┌─────────────────────────────────────┐
│  [搜索]         [筛选 ▼]            │
├─────────────────────────────────────┤
│  精选收藏                              │
│  ┌─────┐  ┌─────┐  ┌─────┐         │
│  │     │  │     │  │     │         │
│  │ 🎨  │  │ 🎵  │  │ 💎  │         │
│  │     │  │     │  │     │         │
│  └─────┘  └─────┘  └─────┘         │
│                                     │
│  最近公开                              │
│  ┌─────┐  ┌─────┐  ┌─────┐         │
│  │ ... │  │ ... │  │ ... │         │
│  └─────┘  └─────┘  └─────┘         │
├─────────────────────────────────────┤
│  分类浏览                              │
│  [矿石] [黑胶] [旅行] [票根] ...     │
└─────────────────────────────────────┘
```

#### API 设计

```
GET /api/public/collections              - 获取公开收藏列表（分页）
GET /api/public/collections/:id           - 获取单个公开收藏
GET /api/public/users/:id/collections     - 获取某用户的公开收藏
GET /api/public/featured                 - 获取精选收藏
GET /api/public/categories/:id/collections - 按分类获取公开收藏
GET /api/collections/:id/visibility       - 获取收藏可见性
PUT /api/collections/:id/visibility      - 更新收藏可见性
```

#### 内容审核

- 用户举报功能
- 敏感内容自动过滤（基于关键词）
- 人工审核入口（后台）
- 违规处理机制（警告、隐藏、封禁）

---

## V3.3：基础社交互动

### 产品功能

- 点赞
- 评论
- 收藏
- 关注用户
- 关注收藏类别

### 技术路线

#### 社交功能数据库设计

```sql
-- 点赞
CREATE TABLE likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  collection_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, collection_id)
);

-- 评论
CREATE TABLE comments (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  collection_id INTEGER NOT NULL,
  parent_id INTEGER,  -- 回复功能
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (collection_id) REFERENCES collections(id)
);

-- 收藏（用户收藏他人的收藏）
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  collection_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, collection_id)
);

-- 关注
CREATE TABLE follows (
  id INTEGER PRIMARY KEY,
  follower_id INTEGER NOT NULL,
  following_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(follower_id, following_id)
);

-- 关注类别
CREATE TABLE category_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, category)
);
```

#### 社交功能 API

```
POST /api/social/like/:collectionId      - 点赞
DELETE /api/social/like/:collectionId     - 取消点赞
GET  /api/social/likes/:collectionId     - 获取点赞数

POST /api/social/comment/:collectionId   - 评论
GET  /api/social/comments/:collectionId  - 获取评论列表
DELETE /api/social/comment/:id           - 删除评论

POST /api/social/bookmark/:collectionId  - 收藏
DELETE /api/social/bookmark/:collectionId - 取消收藏
GET  /api/social/bookmarks               - 获取我的收藏列表

POST /api/social/follow/:userId          - 关注用户
DELETE /api/social/follow/:userId        - 取消关注
GET  /api/social/followers/:userId       - 获取粉丝列表
GET  /api/social/following/:userId       - 获取关注列表

POST /api/social/follow-category/:category - 关注类别
DELETE /api/social/follow-category/:category - 取消关注类别
```

#### 通知系统设计

**通知类型**：
- `like`：有人点赞了你的收藏
- `comment`：有人评论了你的收藏
- `follow`：有人关注了你
- `mention`：有人@了你

**通知存储**：
```sql
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  type TEXT NOT NULL,
  from_user_id INTEGER,
  collection_id INTEGER,
  message TEXT,
  is_read INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**实时通知**：
- WebSocket 实现实时推送
- 或使用第三方服务（Firebase Cloud Messaging）

#### 社交页面设计

```
我的收藏墙：
┌─────────────────────────────────────┐
│  👤 我的主页    ❤️ 我的收藏    ✉️ 通知 │
├─────────────────────────────────────┤
│  粉丝 42  |  关注 28  |  收藏 15     │
├─────────────────────────────────────┤
│  我的收藏                              │
│  ┌─────┐  ┌─────┐  ┌─────┐         │
│  │     │  │     │  │     │         │
│  │ 💎  │  │ 🎵  │  │ 🎫  │         │
│  │ 32  │  │ 18  │  │ 12  │         │
│  └─────┘  └─────┘  └─────┘         │
└─────────────────────────────────────┘
```

---

## V3.4：主题活动与社区运营

### 产品功能

- 旅行票根收藏挑战
- 黑胶收藏展示周
- 水晶或矿石收藏活动
- 平台精选收藏展示
- 与 KOC、博主和收藏社群合作

### 技术路线

#### 活动系统设计

**活动类型**：
- `challenge`：挑战赛（参与、完成、评选）
- `exhibition`：主题展览（展示、投票）
- `collaboration`：合作活动（KOC、品牌的联名活动）

**活动数据库**：
```sql
CREATE TABLE events (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  rules TEXT,  -- JSON 格式规则
  cover_image TEXT,
  status TEXT DEFAULT 'draft',  -- draft, active, ended
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_participations (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  collection_id INTEGER NOT NULL,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (event_id) REFERENCES events(id),
  FOREIGN KEY (collection_id) REFERENCES collections(id)
);
```

#### 活动页面设计

```
┌─────────────────────────────────────┐
│  🔥 活动专区                          │
├─────────────────────────────────────┤
│  进行中                              │
│  ┌─────────────────────────────┐    │
│  │ [活动封面图]                 │    │
│  │ 「旅行票根收集挑战」          │    │
│  │ 已参与：128人  剩余：5天      │    │
│  │           [立即参与]         │    │
│  └─────────────────────────────┘    │
│                                     │
│  往期活动                            │
│  「黑胶收藏展示周」已完成            │
└─────────────────────────────────────┘
```

#### API 设计

```
GET  /api/events                   - 获取活动列表
GET  /api/events/:id                - 获取活动详情
POST /api/events/:id/participate    - 参与活动
GET  /api/events/:id/participants   - 获取参与者列表
GET  /api/events/:id/winners        - 获取获奖名单（活动结束后）
```

#### 运营后台（简化版）

- 活动创建和管理
- 精选收藏审核和设置
- KOC 合作管理
- 数据统计（参与人数、互动量等）

---

## V3.0 风险清单

### 🔴 高风险

#### 1. 内容审核压力
- **描述**：公开内容后，用户可能上传不当内容（违规、侵权、敏感信息）
- **影响**：平台合规风险，品牌受损
- **缓解措施**：
  - 建立完善的内容审核机制（AI + 人工）
  - 设置举报功能，快速处理违规内容
  - 制定社区规范，明确禁止内容
  - 定期培训和优化审核流程

#### 2. 社交功能性能压力
- **描述**：点赞、评论、关注等社交功能会产生大量并发请求
- **影响**：数据库压力，响应延迟
- **缓解措施**：
  - 使用 Redis 缓存热门内容
  - 异步处理非关键操作（如更新计数器）
  - 数据库读写分离
  - 实现请求合并（如批量点赞）

### 🟡 中风险

#### 3. 分享卡片生成失败
- **描述**：不同平台格式要求不同，生成可能失败或显示异常
- **影响**：分享功能不可用，影响传播
- **缓解措施**：
  - 提供多种格式选择（1:1、4:5、9:16等）
  - 生成前显示预览，用户确认后再生成
  - 失败后提供备选方案（纯图片分享）
  - 针对主要平台进行测试

#### 4. 用户增长不如预期
- **描述**：社交分享可能没有带来预期的用户增长
- **影响**：投入产出比低
- **缓解措施**：
  - 设置分享追踪，分析各渠道效果
  - 优化分享卡片设计，提高点击率
  - 设计邀请奖励机制
  - 持续迭代 A/B 测试

#### 5. 恶意刷量/刷单
- **描述**：用户可能通过机器人或小号刷点赞、刷收藏
- **影响**：破坏社区公平性，影响真实用户积极性
- **缓解措施**：
  - 绑定手机号才能参与社交功能
  - 行为检测（点赞频率异常检测）
  - 异常账号自动封禁
  - 人工抽查和举报处理

#### 6. 数据隐私泄露
- **描述**：用户公开分享时，可能无意中泄露个人隐私（如位置、时间等）
- **影响**：用户隐私安全受损
- **缓解措施**：
  - 分享前提醒用户检查隐私设置
  - 允许用户模糊化位置信息
  - 提供隐私保护指南

### 🟢 低风险

#### 7. 活动运营成本高
- **描述**：主题活动需要人工运营策划，成本较高
- **影响**：运营团队压力增大
- **缓解措施**：
  - 先做低成本活动（线上分享、话题标签）
  - 探索半自动化活动运营工具
  - 与 KOC 合作分担运营工作

#### 8. 跨平台分享适配
- **描述**：不同社交平台 API 变化，可能导致分享功能失效
- **影响**：用户无法正常分享
- **缓解措施**：
  - 优先使用系统分享组件（稳定性高）
  - 定期测试各平台分享功能
  - 关注平台 API 更新

---

## V3.0 技术选型总结

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 分享生成 | Flutter Canvas / RN ViewShot | 前端生成分享卡片 |
| 即时通讯 | WebSocket / Firebase | 实时通知推送 |
| 缓存 | Redis | 社交数据缓存 |
| 消息队列 | RabbitMQ / Redis Queue | 异步处理社交操作 |
| 内容审核 | 阿里云内容安全 / 腾讯云安全 | 第三方审核服务 |
| 活动管理 | 独立模块 | 数据模型 + 管理后台 |

---

## V3.0 里程碑

1. ✅ 完成分享卡片生成和分享功能
2. ✅ 完成公开收藏展示
3. ✅ 完成探索/发现页面
4. ✅ 完成社交互动（点赞/评论/收藏/关注）
5. ✅ 完成通知系统
6. ✅ 完成活动系统基础功能
7. ✅ 完成运营后台基础功能
8. ✅ 建立内容审核机制
