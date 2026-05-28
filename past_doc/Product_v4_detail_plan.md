# V4.0 个性化与付费价值版 - 开发技术路线

> **历史文档标记**：暂时不用本文档进行实际任务开发，仅为项目立项时的一种参考方案。当前实际开发请以根目录的 `Final_Team_Work_Division.md` 和五份 `Member_*.md` 成员任务文档为准。

## 版本目标

V4.0 的目标是测试用户是否愿意为更高级的个性化体验和 AI 能力付费。

这并不代表马上大规模商业化，而是先验证哪些功能具有付费潜力。

---

## V4.1：高级主题和模板

### 产品功能

- 高级收藏展示模板
- 手账风模板
- 复古风模板
- 极简风模板
- 旅行档案模板
- 黑胶收藏模板
- 矿石或水晶收藏模板

### 技术路线

#### 模板系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                      模板系统架构                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ 免费基础模板 │    │ 付费高级模板 │    │ 限定活动模板 │     │
│  │   (3-5个)   │    │   (10+个)   │    │   (节日)    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                  │                   │          │
│         └──────────────────┼───────────────────┘          │
│                            ▼                              │
│                 ┌─────────────────────┐                  │
│                 │    模板渲染引擎      │                  │
│                 │  (Template Engine)  │                  │
│                 └─────────────────────┘                  │
│                            │                              │
│         ┌──────────────────┼──────────────────┐          │
│         ▼                  ▼                  ▼          │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐         │
│  │ 收藏卡片   │    │  分享卡片  │    │  年度回顾  │         │
│  │ (List/Grid)│    │ (Share)   │    │ (Review)  │         │
│  └───────────┘    └───────────┘    └───────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 模板定义格式

```json
{
  "template_id": "scrapbook_vintage",
  "name": "复古手账风",
  "description": "温暖的复古手账风格，适合记录有年代感的收藏品",
  "category": "付费",
  "price": 12,
  "thumbnail": "https://cdn.example.com/templates/scrapbook_vintage.png",
  "styles": {
    "primary_font": "Ma Shan Zheng",
    "secondary_font": "ZCOOL XiaoWei",
    "colors": {
      "background": "#FDF6E3",
      "accent": "#8B4513",
      "text": "#5D4037",
      "card_bg": "#FFFEF0"
    },
    "effects": ["paper_texture", "slight_shadow", "tape_corners"]
  },
  "layout": {
    "card": {
      "image_ratio": 1,
      "border_radius": 8,
      "border_style": "dashed",
      "border_color": "#D4C4A8"
    },
    "typography": {
      "title_size": 18,
      "title_weight": "bold",
      "body_size": 13,
      "line_height": 1.6
    }
  },
  "components": {
    "image": {"position": "top", "aspect_ratio": "1:1"},
    "title": {"position": "below_image", "font": "primary"},
    "tags": {"position": "below_title", "style": "chip"},
    "date": {"position": "bottom", "font": "secondary", "prefix": "📅"},
    "location": {"position": "bottom", "font": "secondary", "prefix": "📍"}
  }
}
```

#### 模板渲染引擎

**Flutter 实现**：
```dart
class TemplateEngine {
  final Template template;

  Widget render(Collection collection) {
    return Container(
      decoration: BoxDecoration(
        color: template.styles.colors.background,
        // 应用纹理效果
      ),
      child: Column(
        children: [
          // 图片区域
          if (template.components.image != null)
            _renderImage(collection),

          // 标题
          if (template.components.title != null)
            _renderTitle(collection),

          // 标签
          if (template.components.tags != null)
            _renderTags(collection),

          // 日期和地点
          if (template.components.date != null)
            _renderDate(collection),
        ],
      ),
    );
  }
}
```

#### 订阅/购买系统

**方案设计**：
1. **单次购买**：每个模板单独定价（如 ¥12/个）
2. **订阅制**：月度/年度会员解锁全部模板
3. **混合**：基础模板免费，高级模板需订阅

**数据结构**：
```sql
-- 模板表
CREATE TABLE templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,  -- '免费' | '付费' | '限定'
  price DECIMAL(10, 2),
  thumbnail_url TEXT,
  template_json TEXT,  -- 完整模板定义 JSON
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP
);

-- 用户已购模板
CREATE TABLE user_templates (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  template_id TEXT NOT NULL,
  purchase_type TEXT,  -- '单次购买' | '订阅解锁'
  purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP  -- 订阅的过期时间
);
```

#### API 设计

```
GET  /api/templates                    - 获取模板列表（免费/付费分开）
GET  /api/templates/:id                - 获取模板详情
POST /api/templates/purchase           - 购买/订阅模板
GET  /api/user/templates               - 获取用户已购模板
POST /api/user/templates/apply/:collectionId - 应用模板到收藏
```

#### 模板预览功能

- 模板列表页显示缩略图预览
- 点击模板显示大图预览
- 支持"应用到此收藏"预览
- 免费用户可试用付费模板（带水印）3次/天

---

## V4.2：高级 AI 功能

### 产品功能

- 更多 AI 生成次数
- 批量图片识别
- 批量收藏整理
- 自动生成收藏系列
- 自动生成年度收藏回顾
- AI 辅助长期收藏档案整理

### 技术路线

#### AI 订阅分层

**免费用户限制**：
- AI 标题生成：10次/天
- AI 故事生成：5次/天
- AI 图片识别：5次/天
- 年度回顾：1次/年

**付费用户（Pro）**：
- 无限制 AI 标题生成
- 无限制 AI 故事生成
- 无限制 AI 图片识别
- 批量处理：每月 500 张图片
- 自动收藏系列生成
- 每月 1 次年度回顾（可生成多个）
- 高级 AI 风格（复古风、文豪风等）

**付费用户（Pro Max）**：
- 所有 Pro 功能
- 批量处理无限制
- 多次年度回顾
- AI 档案整理助手

#### 批量处理架构

```
┌─────────────────────────────────────────────────────────────┐
│                      批量处理架构                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  用户触发批量处理                                           │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────────┐                                        │
│  │  任务队列        │  ← RabbitMQ / Redis Queue             │
│  │  (batch_tasks)  │                                        │
│  └────────┬────────┘                                        │
│           │                                                │
│           ▼                                                │
│  ┌─────────────────┐     ┌─────────────────┐               │
│  │  Worker Pool    │────▶│   AI 服务        │               │
│  │  (多个并发处理)  │     │ (限流控制)       │               │
│  └─────────────────┘     └─────────────────┘               │
│           │                                                │
│           ▼                                                │
│  ┌─────────────────┐                                        │
│  │  结果存储        │                                        │
│  │  + 通知用户      │                                        │
│  └─────────────────┘                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 批量任务表

```sql
CREATE TABLE batch_tasks (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  task_type TEXT NOT NULL,  -- 'image_recognition' | 'series_generate' | 'yearly_review'
  input_data TEXT,  -- JSON，存储任务参数
  status TEXT DEFAULT 'pending',  -- pending, processing, completed, failed
  progress INTEGER DEFAULT 0,  -- 进度百分比
  result_data TEXT,  -- JSON，处理结果
  error_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);
```

#### 自动收藏系列生成

**功能说明**：
用户有多个相关收藏时（如同一旅行的多张票根），AI 自动建议归为一个"系列"

**实现流程**：
1. 定期扫描用户收藏
2. AI 分析收藏之间的关联（时间、地点、主题）
3. 生成系列建议（如"2024日本之旅"）
4. 用户确认后将收藏归入系列

**系列数据结构**：
```json
{
  "series_id": "series_xxx",
  "title": "2024日本之旅",
  "description": "包含了来自日本的旅行纪念品",
  "cover_image": "https://...",
  "collections": ["id1", "id2", "id3"],
  "ai_confidence": 0.85,
  "created_by": "ai",  // or "user"
  "created_at": "2024-03-15"
}
```

#### API 设计

```
POST /api/ai/batch-process          - 创建批量处理任务
GET  /api/ai/batch-tasks            - 获取用户批量任务列表
GET  /api/ai/batch-tasks/:id        - 获取任务详情/进度

POST /api/ai/generate-series        - AI 生成系列建议
GET  /api/ai/series-suggestions     - 获取系列建议列表
POST /api/ai/series/:id/accept     - 接受系列建议
POST /api/ai/series/:id/reject     - 拒绝系列建议

GET  /api/ai/usage                  - 获取 AI 使用量统计
```

---

## V4.3：存储扩展

### 产品功能

- 免费用户拥有基础存储空间
- 付费用户可以购买更多存储空间
- 支持更多收藏数量
- 支持更高清图片

### 技术路线

#### 存储配额设计

| 方案 | 存储空间 | 图片数量 | 价格 |
|------|----------|----------|------|
| 免费版 | 1 GB | 500 张 | 免费 |
| Pro | 10 GB | 5000 张 | ¥30/月 |
| Pro Max | 50 GB | 无限制 | ¥80/月 |

**超出配额处理**：
- 用户收到提醒
- 无法上传新图片（直到购买额外空间或删除旧内容）
- 提供云端备份下载

#### 存储使用追踪

```sql
-- 用户存储统计
CREATE TABLE user_storage (
  user_id INTEGER PRIMARY KEY,
  used_bytes BIGINT DEFAULT 0,
  total_bytes BIGINT DEFAULT 1073741824,  -- 默认 1GB
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 每次上传/删除时更新
UPDATE user_storage
SET used_bytes = used_bytes + :file_size,
    last_updated = CURRENT_TIMESTAMP
WHERE user_id = :user_id;
```

#### 存储监控和告警

```python
# 存储空间检查
def check_storage_quota(user_id, file_size):
    user_storage = db.query(
        "SELECT used_bytes, total_bytes FROM user_storage WHERE user_id = ?",
        user_id
    )

    if user_storage.used_bytes + file_size > user_storage.total_bytes:
        raise StorageQuotaExceededError(
            f"存储空间不足。当前使用 {user_storage.used_bytes / 1073741824:.2f} GB / {user_storage.total_bytes / 1073741824:.2f} GB"
        )

    # 检查单次上传大小限制
    if file_size > 50 * 1024 * 1024:  # 50MB
        raise FileTooLargeError("单张图片不能超过 50MB")
```

#### 存储类型分级

**标准存储（标准访问）**：
- 常规收藏图片
- 访问频率高
- 价格：¥0.12/GB/月

**低频存储（冷数据）**：
- 超过1年未访问的收藏
- 价格：¥0.05/GB/月

**归档存储**：
- 用户主动归档的收藏
- 价格：¥0.015/GB/月

#### 存储扩展购买

**购买流程**：
```
用户点击"扩展存储"
       │
       ▼
显示存储包选项（10GB/50GB/100GB）
       │
       ▼
选择支付方式
       │
       ▼
支付成功后更新配额
       │
       ▼
发送确认邮件/通知
```

**存储包数据结构**：
```sql
CREATE TABLE storage_packages (
  id TEXT PRIMARY KEY,
  name TEXT,
  size_bytes BIGINT,
  price DECIMAL(10, 2),
  is_active BOOLEAN DEFAULT true
);

CREATE TABLE user_storage_purchases (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  package_id TEXT,
  purchased_bytes BIGINT,
  purchased_at TIMESTAMP
);
```

#### API 设计

```
GET  /api/user/storage              - 获取存储使用情况
GET  /api/storage/packages          - 获取存储包列表
POST /api/storage/purchase          - 购买存储扩展

DELETE /api/collections/:id        - 删除收藏时释放空间
POST /api/collections/:id/image     - 上传前检查配额
```

---

## V4.0 风险清单

### 🔴 高风险

#### 1. 支付系统集成复杂性
- **描述**：需要集成多种支付方式（微信、支付宝、Apple Pay），涉及资金安全、合规等问题
- **影响**：支付失败、延迟到账、退款纠纷等
- **缓解措施**：
  - 使用成熟的支付聚合服务（如 Ping++、Stripe）
  - 支付链路完整日志记录
  - 建立退款和售后处理流程
  - 定期对账和财务审计

#### 2. 订阅用户留存挑战
- **描述**：用户可能订阅一个月后取消，难以建立长期付费习惯
- **影响**：收入不稳定，流失率高
- **缓解措施**：
  - 持续提供付费用户专属价值（新模板、新功能）
  - 设计年度订阅优惠（引导长期承诺）
  - 订阅即将到期提醒，给予额外优惠
  - 建立会员专属社区，增加归属感

#### 3. AI 使用成本超过付费收入
- **描述**：高级 AI 功能调用频繁，成本可能超过用户付费金额
- **影响**：每增加一个付费用户反而亏损
- **缓解措施**：
  - 设定 AI 调用上限（超过后降级或收费）
  - 批量处理时使用更经济的 AI 模型
  - 监控 AI 成本占比，持续优化

### 🟡 中风险

#### 4. 付费功能感知价值不足
- **描述**：用户不觉得付费功能值这个价
- **影响**：付费转化率低
- **缓解措施**：
  - 提供免费试用期（7天 Pro 功能）
  - 设计"免费 vs 付费"对比展示
  - 收集付费用户评价，展示使用场景
  - 限制免费版功能，引导体验付费价值

#### 5. 存储成本随用户增长
- **描述**：用户存储总量随用户数线性增长，存储成本成为主要支出
- **影响**：规模越大，亏损越多
- **缓解措施**：
  - 差异化定价，确保存储费用被覆盖
  - 实现存储分级（冷热数据分离）
  - 定期清理废弃账号，释放空间
  - 探索企业级大客户方案

#### 6. 模板系统性能瓶颈
- **描述**：高级模板可能有复杂渲染逻辑，影响页面加载速度
- **影响**：用户感知卡顿，体验差
- **缓解措施**：
  - 模板组件懒加载
  - 图片预加载和缓存
  - 简化复杂模板的渲染逻辑
  - 在低端设备上提供简化版模板

### 🟢 低风险

#### 7. 盗版和账号共享
- **描述**：用户可能共享账号，多人使用付费功能
- **影响**：收入损失
- **缓解措施**：
  - 限制同时在线设备数（如最多3台）
  - 异常登录检测和告警
  - 订阅只能在一个账号使用

#### 8. 退款纠纷
- **描述**：用户要求退款，可能产生纠纷
- **影响**：口碑受损，客服压力
- **缓解措施**：
  - 明确退款政策（如7天内无条件）
  - 简化退款流程
  - 自动处理过期订阅退款

---

## V4.0 技术选型总结

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 支付集成 | Ping++ / Stripe | 聚合多个支付渠道 |
| 订阅管理 | Stripe Billing | 订阅周期、续费管理 |
| 任务队列 | Redis Queue | 批量 AI 处理 |
| 存储服务 | S3 / OSS + Cloudflare | CDN 加速 |
| 监控告警 | Prometheus + Grafana | 系统和业务监控 |
| 日志 | ELK Stack | 支付链路日志 |

---

## V4.0 里程碑

1. ✅ 完成高级模板系统（付费模板）
2. ✅ 完成模板购买/订阅系统
3. ✅ 完成支付系统集成
4. ✅ 完成 AI 订阅分层和配额系统
5. ✅ 完成批量处理功能
6. ✅ 完成存储配额和扩展购买
7. ✅ 完成订阅管理后台
8. ✅ 验证付费转化和留存
