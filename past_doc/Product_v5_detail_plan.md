# V5.0 商业生态扩展版 - 开发技术路线

> **历史文档标记**：暂时不用本文档进行实际任务开发，仅为项目立项时的一种参考方案。当前实际开发请以根目录的 `Final_Team_Work_Division.md` 和五份 `Member_*.md` 成员任务文档为准。

## 版本目标

V5.0 是长期商业化阶段，应该在产品拥有足够用户、内容和稳定使用频率之后再考虑。

---

## V5.1：实体收藏册和可打印日记导出

### 产品功能

- 导出收藏记录为 PDF
- 生成 printable journal
- 制作实体 scrapbook
- 制作旅行记忆册
- 制作年度收藏册
- 用户可以选择封面、模板和排版

### 技术路线

#### PDF 导出系统

**导出选项**：
- 单本收藏册（按时间/类别）
- 年度收藏回顾册
- 旅行纪念册（按地点）
- 精选收藏册（用户自选）

**模板类型**：
```
┌─────────────────────────────────────────────────────────┐
│                    实体册模板类型                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📖 经典精装本                                           │
│     - 硬皮封面，多色可选                                  │
│     - 铜版纸内页                                         │
│     - 32-100页可选                                       │
│                                                         │
│  📓 手账风格                                             │
│     - 线圈装订，可平铺                                    │
│     - 米白纸/点阵纸                                      │
│     - 包含手账元素（贴纸区域等）                          │
│                                                         │
│  📒 旅行日记                                             │
│     - 折叠式展开                                         │
│     - 包含地图页、景点打卡页                              │
│     - 票据收纳袋                                          │
│                                                         │
│  💿 唱片收藏册                                           │
│     - 黑胶唱片尺寸定制                                    │
│     - 专辑信息页+歌词页                                   │
│     - 播放列表设计                                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### PDF 生成技术

**方案选型**：
1. **前端生成**（适合简单排版）
   - Flutter：`pdf` 包
   - React Native：无合适方案

2. **后端生成**（推荐，适合复杂排版）
   - Node.js：`puppeteer` + `handlebars`
   - Python：`reportlab` / `weasyprint`
   - 专业PDF服务：`DocRaptor`, `Prince XML`

**推荐方案**：后端 `puppeteer` + `handlebars`

```javascript
// PDF 生成服务
const puppeteer = require('puppeteer');
const handlebars = require('handlebars');
const fs = require('fs');

async function generateCollectionBook(collections, template) {
  // 1. 加载 HTML 模板
  const templateHtml = fs.readFileSync(`templates/${template}.hbs`, 'utf8');
  const compiledTemplate = handlebars.compile(templateHtml);

  // 2. 准备数据
  const data = {
    title: '我的收藏册',
    collections: collections.map(c => ({
      image: c.image_url,
      title: c.title,
      date: c.date_acquired,
      location: c.location,
      story: c.story
    })),
    stats: {
      totalItems: collections.length,
      categories: [...new Set(collections.map(c => c.category))]
    }
  };

  // 3. 渲染 HTML
  const html = compiledTemplate(data);

  // 4. 生成 PDF
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setContent(html);
  await page.pdf({
    format: 'A4',
    printBackground: true,
    margin: { top: '20mm', bottom: '20mm', left: '15mm', right: '15mm' }
  });

  await browser.close();
  return pdfBuffer;
}
```

#### 打印服务集成

**合作方案**：
1. **自营打印**：自己采购打印机和装订设备
   - 优点：控制质量，利润更高
   - 缺点：库存、物流、客服压力大

2. **第三方印刷厂合作**（推荐）
   - 国内：`印铺`、`分子集`、`格致书」
   - 国际：`Shutterfly`, `Snapfish`, `Artifact Uprising`
   - 优点：无需库存，物流由合作方处理
   - 缺点：每单需要分成给合作方

**印刷文件要求**：
```json
{
  "format": "PDF",
  "color_mode": "CMYK",
  "resolution": "300 DPI",
  "bleed": "3mm",
  "trim": "3mm",
  "safe_area": "5mm",
  "max_pages": 200
}
```

#### 订单处理系统

```sql
CREATE TABLE print_orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  order_type TEXT NOT NULL,  -- 'single_book' | 'annual_review' | 'travel_journal'
  template_id TEXT,
  collection_ids TEXT,  -- JSON，关联的收藏 ID 列表
  status TEXT DEFAULT 'pending',  -- pending, designing, printing, shipped, delivered, cancelled
  shipping_address TEXT,  -- JSON，收货地址
  tracking_number TEXT,
  price DECIMAL(10, 2),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE print_templates (
  id TEXT PRIMARY KEY,
  name TEXT,
  description TEXT,
  cover_options TEXT,  -- JSON，可选封面
  page_range TEXT,  -- 可选页数
  base_price DECIMAL(10, 2),
  thumbnail_url TEXT
);
```

#### 物流和配送

**物流方案**：
- 初期：人工联系印刷厂代发
- 中期：接入快递API（顺丰、京东、中通）
- 后期：自建仓储或与仓储公司合作

**物流追踪**：
```sql
ALTER TABLE print_orders ADD COLUMN logistics_partner TEXT;
ALTER TABLE print_orders ADD COLUMN shipped_at TIMESTAMP;
ALTER TABLE print_orders ADD COLUMN delivered_at TIMESTAMP;
```

#### API 设计

```
GET  /api/print/templates             - 获取印刷模板列表
GET  /api/print/templates/:id        - 获取模板详情（封面、页数等）

POST /api/print/preview              - 生成预览 PDF（低分辨率）
POST /api/print/order                - 创建印刷订单
GET  /api/print/orders               - 获取订单列表
GET  /api/print/orders/:id          - 获取订单详情
PUT  /api/print/orders/:id/cancel    - 取消订单

GET  /api/print/shipping-tracking    - 物流追踪（对接快递 API）
```

---

## V5.2：品牌合作

### 产品功能

- 与文创品牌合作
- 与旅行品牌合作
- 与手账和文具品牌合作
- 与黑胶店合作
- 与矿石或水晶商家合作
- 与博物馆、展览、演唱会相关方合作
- 推出联名活动或主题项目

### 技术路线

#### 品牌合作类型

**类型一：联名内容**
- 联名模板（如与某博物馆合作推出"印象派画家"收藏模板）
- 联名周边（收藏卡、贴纸等）

**类型二：商业活动**
- 品牌赞助的收藏挑战
- 品牌专属分类（如"A品牌收藏家"徽章）
- 线下活动合作

**类型三：广告合作**
- 品牌展示位（用户可选择关闭广告）
- 内容推荐（融入用户内容流）
- 品牌主页（类似微博品牌专区）

#### 合作品牌管理后台

```sql
CREATE TABLE brands (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  logo_url TEXT,
  website TEXT,
  contact_email TEXT,
  contract_info TEXT,  -- JSON，合作条款
  tier TEXT,  -- 'national' | 'regional' | 'niche'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brand_campaigns (
  id INTEGER PRIMARY KEY,
  brand_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT,  -- 'collab_template' | 'challenge' | 'ad'
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  budget DECIMAL(10, 2),
  target_metrics TEXT,  -- JSON
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 联名模板系统

```json
{
  "collab_template": {
    "id": "van_gogh_collection",
    "name": "梵高收藏系列",
    "brand_id": "van_gogh_museum",
    "description": "与梵高博物馆合作的限定模板",
    "template": {
      "colors": ["#FFD700", "#1E3A5F", "#F5F5DC"],
      "fonts": ["Vincent van Gogh 风格字体"],
      "decorations": ["星空元素", "向日葵边框"]
    },
    "price": 0,  // 联名模板可能免费
    "valid_from": "2024-06-01",
    "valid_until": "2024-12-31",
    "require_follow_brand": true  // 是否需要关注品牌账号
  }
}
```

#### 品牌广告位

**广告位设计**：
- 首页 Banner（轮播）
- 收藏夹推荐位
- 分享卡片嵌入品牌元素
- 品牌专属标签（#某某品牌收藏#）

**广告计价方式**：
- CPM（每千次展示）
- CPC（每次点击）
- CPA（每次行动，如下载、注册）

#### 合作结算系统

```sql
CREATE TABLE brand_settlements (
  id INTEGER PRIMARY KEY,
  brand_id INTEGER NOT NULL,
  campaign_id INTEGER,
  settlement_type TEXT,  -- 'cpm' | 'cpc' | 'cpa' | 'fixed'
  amount DECIMAL(10, 2),
  metrics TEXT,  -- JSON，实际数据
  status TEXT DEFAULT 'pending',  -- pending, confirmed, paid
  created_at TIMESTAMP,
  paid_at TIMESTAMP
);
```

#### API 设计

```
# 品牌端（Brand Portal）
POST /api/brand/register             - 品牌注册
POST /api/brand/login                - 品牌登录
GET  /api/brand/campaigns            - 查看合作活动
POST /api/brand/campaigns            - 创建活动
GET  /api/brand/analytics            - 查看数据报表

# 用户端
GET  /api/collab/templates           - 获取联名模板
GET  /api/brand/:id                  - 获取品牌主页
GET  /api/challenges/:id/brand       - 获取合作品牌挑战

# 广告（内部）
GET  /api/ads/inventory              - 获取广告库存
POST /api/ads/request                - 申请投放广告
```

---

## V5.3：广告和商业推广

### 产品功能

- 精选广告位
- 相关品牌推荐
- 活动推广
- 商家合作内容
- 广告网络变现

### 技术路线

#### 广告系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                      广告系统架构                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  广告主（Brand/Agency）                                     │
│       │                                                      │
│       ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              广告投放平台（Ad Platform）            │    │
│  │  - 创建广告计划                                      │    │
│  │  - 设置定向（用户画像、兴趣、行为）                  │    │
│  │  - 设置预算和出价                                    │    │
│  │  - 查看数据报表                                      │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                │
│                            ▼                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           广告竞价系统（Ad Server）                   │    │
│  │  - 实时竞价（RTB）                                    │    │
│  │  - 广告优先级排序                                    │    │
│  │  - 频次控制（避免用户看到同一广告太多次）            │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                │
│                            ▼                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           广告渲染和展示（Ad Renderer）              │    │
│  │  - 多种广告形式（Banner、信息流、开屏）              │    │
│  │  - 本地化处理                                       │    │
│  │  - 曝光和点击追踪                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 广告形式

| 广告形式 | 描述 | 适用场景 |
|----------|------|----------|
| 开屏广告 | 启动时展示 3-5 秒 | 品牌曝光 |
| Banner | 固定位置横幅 | 首页/探索页 |
| 信息流广告 | 融入内容列表 | 收藏列表、发现页 |
| 激励视频 | 用户主动观看 | AI 功能奖励 |
| 推送广告 | 通知栏推广 | 唤醒用户 |

#### 广告定向

```json
{
  "targeting": {
    "demographics": {
      "age_range": "18-35",
      "gender": "all"
    },
    "interests": ["收藏", "旅行", "音乐", "手账"],
    "behavior": {
      "min_collections": 10,
      "has_shared": true
    },
    "location": {
      "country": "中国",
      "cities": ["北京", "上海", "广州", "深圳"]
    }
  }
}
```

#### 广告数据模型

```sql
-- 广告计划
CREATE TABLE ad_campaigns (
  id TEXT PRIMARY KEY,
  advertiser_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- 'banner' | 'feed' | 'video' | 'interstitial'
  targeting TEXT,  -- JSON 定向条件
  budget DECIMAL(10, 2),
  daily_budget DECIMAL(10, 2),
  bid_amount DECIMAL(10, 2),  -- 每次点击/展示出价
  status TEXT DEFAULT 'draft',
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  created_at TIMESTAMP
);

-- 广告素材
CREATE TABLE ad_creatives (
  id TEXT PRIMARY KEY,
  campaign_id TEXT NOT NULL,
  title TEXT,
  description TEXT,
  image_url TEXT,
  click_url TEXT,
  impressions INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  created_at TIMESTAMP
);

-- 广告曝光和点击日志
CREATE TABLE ad_impressions (
  id BIGINT PRIMARY KEY,
  creative_id TEXT NOT NULL,
  user_id INTEGER,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address TEXT,
  device_type TEXT,
  country TEXT,
  city TEXT
);

CREATE TABLE ad_clicks (
  id BIGINT PRIMARY KEY,
  creative_id TEXT NOT NULL,
  user_id INTEGER,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address TEXT
);
```

#### 广告平台（自建 or 接入）

**自建广告平台**（适合平台有一定规模）：
- 自建广告投放后台
- 支持广告主自助下单
- 数据报表和优化工具

**接入广告联盟**（快速变现）：
- Google AdMob：适合移动 App
- 穿山甲（ByteDance）：国内流量大
- 腾讯优量汇：微信生态
- 阿里妈妈：淘宝/支付宝生态

**推荐方案**：
- 初期：接入广告联盟（快速变现）
- 后期：自建广告平台（更高利润）

#### 隐私合规

**注意**：
- 中国：《个人信息保护法》《数据安全法》
- 需要用户同意才可追踪行为
- 广告定向不能过于精准（避免"用户被歧视"）
- 数据保留期限限制

**合规措施**：
```javascript
// 广告追踪同意检查
function shouldShowAds(userId) {
  const user = getUser(userId);
  if (!user.consent_for_ads) {
    return false;  // 用户未同意，不展示广告
  }
  return true;
}

// 匿名化处理
function anonymizeAdData(impressionData) {
  return {
    country: impressionData.country,  // 保留国家
    city: null,  // 不保留城市
    device_type: impressionData.device_type,
    // 不记录 IP 地址
  };
}
```

---

## V5.0 风险清单

### 🔴 高风险

#### 1. 印刷品质量和售后
- **描述**：印刷品是实物，质量问题（色彩偏差、装订错误）会导致用户投诉
- **影响**：口碑受损，退货退款成本高
- **缓解措施**：
  - 选择可靠的印刷合作方，实地考察
  - 建立质检流程（抽查印刷成品）
  - 提供明确的退换货政策
  - 预留售后预算

#### 2. 物流成本和时效
- **描述**：实体印刷品物流成本高，偏远地区可能时效差
- **影响**：用户满意度下降
- **缓解措施**：
  - 印刷厂尽量覆盖多地
  - 物流成本计入商品定价
  - 对时效敏感用户提供加急选项
  - 提供物流追踪和预计到达时间

#### 3. 广告损害用户体验
- **描述**：广告太多或定向不精准会影响用户体验
- **影响**：用户流失，活跃度下降
- **缓解措施**：
  - 严格控制广告数量（不超过内容的 20%）
  - 付费用户可选择关闭广告
  - 广告内容需要与产品调性匹配
  - 建立用户反馈机制

### 🟡 中风险

#### 4. 品牌合作风险
- **描述**：合作品牌出现负面新闻（如质量丑闻、价值观问题）可能连累平台
- **影响**：品牌形象受损
- **缓解措施**：
  - 合作前进行品牌调查和评估
  - 合同中加入品牌保护条款（如对方负面时平台可终止合作）
  - 避免与单一品牌过度绑定

#### 5. 广告数据隐私合规
- **描述**：广告追踪涉及用户数据，需符合隐私法规
- **影响**：可能面临监管处罚
- **缓解措施**：
  - 获取用户明确同意
  - 数据匿名化处理
  - 定期进行合规审查
  - 咨询专业律师/合规顾问

#### 6. 印刷库存和资金占用
- **描述**：如果自营印刷，需要备货和库存管理
- **影响**：资金占用，库存积压风险
- **缓解措施**：
  - 初期采用按需印刷模式，不备货
  - 与印刷厂协商代发货
  - 预测需求，合理备货

### 🟢 低风险

#### 7. 市场竞争加剧
- **描述**：其他平台可能推出类似实体收藏服务
- **影响**：市场份额下降
- **缓解措施**：
  - 持续优化产品质量和服务
  - 建立品牌忠诚度
  - 深耕垂直用户群

#### 8. 广告主拖欠款项
- **描述**：广告主投放后不付款
- **影响**：坏账损失
- **缓解措施**：
  - 预付款制度（大客户可授信）
  - 定期对账和催收
  - 建立广告主信用评估机制

---

## V5.0 技术选型总结

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| PDF 生成 | Puppeteer + Handlebars | 后端 HTML 转 PDF |
| 印刷对接 | API 集成或手工下单 | 视合作方情况 |
| 物流追踪 | 快递 API 集成 | 顺丰/中通/圆通 |
| 广告系统 | 初期穿山甲/优量汇，后期自建 | 快速变现 vs 精细运营 |
| 品牌管理 | 独立 Brand Portal | B端管理后台 |

---

## V5.0 里程碑

1. ✅ 完成 PDF 导出功能
2. ✅ 完成实体印刷品下单系统
3. ✅ 对接印刷服务商
4. ✅ 完成物流追踪集成
5. ✅ 完成品牌合作管理后台
6. ✅ 完成广告系统基础功能
7. ✅ 完成广告联盟接入（快速变现）
8. ✅ 建立商业化运营团队
9. ✅ 验证商业化 ROI
