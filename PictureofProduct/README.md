# 产品截图说明文档

本文档展示 Collection Journey 收藏品管理应用各页面的截图。

## 目录结构

| 文件名 | 页面 | 说明 |
|--------|------|------|
| [01-museum-home.png](01-museum-home.png) | Museum Home | 柱廊场景首页，展示月度房间入口 |
| [02-gallery-may.png](02-gallery-may.png) | Gallery - May 2026 | 5月收藏展厅，2×2分层墙展示 |
| [03-gallery-jun.png](03-gallery-jun.png) | Gallery - Jun 2026 | 6月收藏展厅 |
| [04-gallery-jul.png](04-gallery-jul.png) | Gallery - Jul 2026 | 7月收藏展厅 |
| [05-collection-detail.png](05-collection-detail.png) | Collection Detail | 藏品详情页，展示单件藏品信息 |
| [06-add-exhibit.png](06-add-exhibit.png) | Add Exhibit | 添加展品页，表单录入新藏品 |
| [07-profile.png](07-profile.png) | Profile | 个人主页，统计数据与收藏概览 |
| [08-share-settings.png](08-share-settings.png) | Share Settings | 分享设置，管理可见性与分享权限 |
| [09-edit-collection.png](09-edit-collection.png) | Edit Collection | 编辑藏品，修改已有藏品信息 |
| [10-public-browse.png](10-public-browse.png) | Public Browse | 公开浏览，查看公开分享的藏品 |

---

## 1. Museum Home（首页/柱廊）

**路径**: `/` 或 `/#/`

应用入口，呈现柱廊场景布局。用户可通过底部 Tab 导航到不同功能区，或点击特定月份的房间卡片进入该月的收藏展厅。

**核心元素**:
- 顶部状态栏
- 柱廊场景展示区
- 月度 Room 入口卡片（May/Jun/Jul）
- 底部 Tab 导航栏（Home/Gallery/Add/Profile）

---

## 2. Gallery - May 2026（5月展厅）

**路径**: `/#/gallery/0`

以 Room 01 May 2026 为例展示月度收藏墙。芯片栏显示当前选中的月份，下方为 2×2 分层墙布局，每页展示 6 条藏品记录，支持 Previous/Next 分页。

**核心元素**:
- 月份芯片导航栏（ROOM 01 · May 2026 / ROOM 02 · Jun 2026 / ROOM 03 · Jul 2026）
- 2×2 分层墙网格
- 藏品缩略卡片
- 分页控件

---

## 3. Gallery - Jun 2026（6月展厅）

**路径**: `/#/gallery/1`

ROOM 02 · Jun 2026 的收藏展厅展示页面。与 May 展厅共享同一页面框架，内容按 6 月区间（Jun 1–30, 2026）筛选。

---

## 4. Gallery - Jul 2026（7月展厅）

**路径**: `/#/gallery/2`

ROOM 03 · Jul 2026 的收藏展厅展示页面。时间轴前缀为 JUL，日期区间为 Jul 1–31, 2026。

---

## 5. Collection Detail（藏品详情）

**路径**: `/#/collection/:id`

点击具体藏品后进入详情页，显示该藏品的完整信息（标题、分类、来源地、获得日期、Story 描述、图片、标签等），支持删除操作。

**核心元素**:
- 藏品主图
- 标题与分类
- 来源地、获得日期
- Story 叙述文本
- 标签展示
- 操作按钮（删除等）

---

## 6. Add Exhibit（添加展品）

**路径**: `/#/add`

通过表单新增藏品的页面。表单字段包括标题、分类、来源地、获得日期、Story 描述、图片上传、标签录入等。

**核心元素**:
- 图片上传区
- 标题输入框
- 分类选择器
- 来源地输入框
- 获得日期选择器
- Story 文本输入区
- 标签输入框
- 提交按钮

---

## 7. Profile（个人主页）

**路径**: `/#/profile`

用户个人资料与收藏统计页面。展示用户统计数据、最近新增藏品、以及三张月度 Room 预览卡片。

**核心元素**:
- 用户头像与信息
- 收藏统计数据（总数、分类统计等）
- Recent 藏品列表
- 三张月度 Room 卡片
- Public Preview 入口

---

## 8. Share Settings（分享设置）

**路径**: `/#/share-settings`

管理藏品分享权限的页面。设置藏品的可见性（public/private），并可配置分享链接与预览权限。

**核心元素**:
- 可见性开关（Public/Private）
- 分享链接管理
- 权限配置选项

---

## 9. Edit Collection（编辑藏品）

**路径**: `/#/edit/:id`

编辑已有藏品信息的页面，表单预填充现有数据，支持修改标题、分类、图片、Story 等字段，并可上传新图片。

**核心元素**:
- 当前藏品图片展示
- 编辑表单（预填充数据）
- 图片替换上传
- 保存更新按钮

---

## 10. Public Browse（公开浏览）

**路径**: `/#/public`

无需登录即可浏览公开藏品的页面。以游客身份查看所有设置为 `visibility=public` 的藏品，支持查看详情但受限操作权限。

**核心元素**:
- 公开藏品列表（2×2 网格）
- 藏品卡片（图片+标题+分类）
- 访客详情查看入口