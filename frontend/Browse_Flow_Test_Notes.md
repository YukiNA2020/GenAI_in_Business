# 浏览流程自测说明（成员 C / 成员 3 · Flutter）

> **负责人**：成员 C / 成员 3，由该成员的 AI 工具协助编写  
> **上次更新**：2026-05-19（成员 C / 成员 3 修订：月度 Room 联调、编辑页、文档同步）  
> **状态**：阶段一～五主要功能已实现；请独立测试 AI 按本表验证并写入根目录 `Test.md`

## 技术栈

- **Flutter**（`frontend/lib/features/collection_browse/`）
- 状态管理：Riverpod（`collection_list_provider`、`app_navigation_provider`、`collectionRoomIndexProvider`、`member3_ui_settings_provider` 等）
- 网络：dio → `http://localhost:3000`（Web/桌面）或 `http://10.0.2.2:3000`（Android 模拟器）
- 布局：瀑布流 `CollectionGrid` + `collection_wall_slivers`（嵌入 Gallery）
- 图片：`cached_network_image` + `GET /api/collections/:id/image`；编辑页换图 `POST …/image`（`file_picker`）
- 视觉：`design-export/png export/Collectory Museum Home UI/` 各屏 `Mobile.png` + `collectory-ui-handoff.md`
- 手机壳：`CollectoryMobileShell`（390×844 Web 预览）
- 月度 Room 配置：`utils/collectory_room_catalog.dart`（May / Jun / Jul 共用）

## 应用结构（handoff 四 Tab + 叠层）

| 入口 | 页面 / 文件 | 说明 |
|------|-------------|------|
| Home | `museum_home_page.dart` | 柱廊 + 四类展品热点 → Gallery 分类筛选 |
| Gallery | `design_gallery_page.dart` | Room archive（三 room 芯片）+ 2×2 分层墙 + **Collection wall** |
| Add | `add_exhibit_design_page.dart` | 创建展品（`POST /api/collections`） |
| Profile | `profile_design_page.dart` → `profile_collection_preview.dart` | 统计 / Recent / **Collection rooms** / Settings |
| 叠层 | `collection_room_page.dart` | `roomIndex` 0/1/2；Gallery 与 Profile **同月同页** |
| 叠层 | `share_room_settings_page.dart` | Profile 设置齿轮 / Visibility 卡片 |
| 叠层 | `share_room_preview_page.dart` | Share settings 右下角 **Preview**（非设置页内嵌） |
| 叠层 | `collection_detail_page.dart` | 私有详情 / 公开访客详情（`isPublicView`） |
| 叠层 | `edit_collection_page.dart` | 详情 Edit → `PUT /api/collections/:id` + 图片上传 |
| 叠层 | `public_collections_page.dart` | 公开浏览（可选路径） |

叠层打开时 **底部 Tab 隐藏**（`app.dart`）。Collection room 的 `AnimatedSwitcher` key 含 `roomIndex`，切换月份会重建页面。

## 前置条件

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（3.3+）
2. 在 `frontend/` 执行：

```bash
flutter create . --project-name collection_journey_app
flutter pub get
```

3. 后端已 seed 并运行（`../backend`，端口 **3000**，数据 `backend/data/collectory.db`）

4. （可选）API 合同脚本：

```bash
cd frontend
node test_member3_api_contract.js
# 期望 32/32（backend 在线时）
```

## 运行

```bash
# 终端 1
cd backend && npm run dev

# 终端 2（Web；端口占用可换 8085–8090）
cd frontend
flutter run -d web-server --web-port=8090
# 浏览器打开 http://localhost:8090
```

热重启：**R**（改 UI 后建议完整重启 + 浏览器强制刷新）。

---

## 阶段一：收藏墙（Gallery → Collection wall）

| # | 步骤 | 预期 |
|---|------|------|
| 1 | **Gallery** Tab，向下滚至 **Collection wall** | 搜索框、分类 Tab、Tags 按钮、排序 |
| 2 | 首屏列表 | 最多 **6 张**卡片（`pageSize=6`）；底部 `Showing X of Y` 或翻页条 |
| 3 | 总数 > 6 | **Previous / Next**；每页 6 张；Next 请求 `page=2` 并拼接 |
| 4 | 滚到底（总数 ≤6） | 可 `loadMore`；无更多显示 **End of collection** |
| 5 | Collection wall **下拉刷新** | `page=1`；保留 keyword / 分类 / 标签 / 排序 |
| 6 | 点击卡片 | 私有详情（Edit / Delete） |

## 阶段二：详情与编辑

| # | 步骤 | 预期 |
|---|------|------|
| 7 | 详情加载 | 大图、Story、标签、日期、地点、customFields |
| 8 | 顶栏 **Edit** | 进入 `edit_collection_page.dart`（非占位页） |
| 9 | 编辑页修改标题/故事/地点/日期/标签/可见性后 **Save** | `PUT /api/collections/:id`；返回详情；Gallery 列表刷新 |
| 10 | 编辑页 **Change** 换图 | `POST /api/collections/:id/image`；预览更新 |
| 11 | **Suggest story draft** | 根据标题与标签生成草稿（可再编辑） |
| 12 | 删除并确认 | 返回 Gallery，条目消失 |

## 阶段三：搜索 / 筛选 / 分页 / 刷新

| # | 步骤 | 预期 |
|---|------|------|
| 13 | 搜索「紫水晶」 | ~400ms debounce；`page` 重置为 1 |
| 14 | 分类 Chip | `GET /api/collections?category=` |
| 15 | **Tags** 按钮 | 底部弹层四角圆角、不遮挡底栏 |
| 16 | 排序切换 | `sort=date_desc` / `date_asc` |
| 17 | 翻页加载中 | `_busy` 期间不重复请求 |

## 阶段四：个人主页（Profile）

| # | 步骤 | 预期 |
|---|------|------|
| 18 | **Profile** Tab | Exhibits / Rooms / Public / **Last added**（年份黑色） |
| 19 | Recent exhibits | 横向卡片，按 `dateAcquired` 新→旧 |
| 20 | Favorite tags | Music / Ticket / Mineral / Memory → 网格筛选 |
| 21 | **Museum Visibility** | 开关过滤公开预览；卡片主体 → Share settings |
| 22 | **Collection rooms** 三张卡 | May / Jun（Preview）/ Jul（Preview） |

## 阶段五：分享与公开浏览

| # | 步骤 | 预期 |
|---|------|------|
| 23 | Share settings | 对齐 PNG；无页内 Visitor preview |
| 24 | 胶囊开关 | 滑动/点击后保持 |
| 25 | **Preview** | 独立 `share_room_preview_page.dart` |
| 26 | Preview 开关往返 | 故事/日期/私密说明随开关变化 |
| 27 | Visibility = Private | Preview 显示不可访问说明 |
| 28 | 公开列表 | `GET ?visibility=public` |
| 29 | 公开详情 | 无 Edit/Delete；作者 Tong（占位） |

## Home / Gallery / 月度 Room（成员 C / 成员 3 重点）

| # | 步骤 | 预期 |
|---|------|------|
| 30 | Home **Open room** | Collection room，`roomIndex=0`（May） |
| 31 | Gallery 点 **ROOM 01 · May 2026** | 进入 May room 页 |
| 32 | Gallery 点 **ROOM 02 · Jun 2026** | 进入 Jun room 页（与 Profile 点 Jun 卡片 **同一页面配置**） |
| 33 | Gallery 点 **ROOM 03 · Jul 2026** | 进入 Jul room 页（与 Profile 点 Jul 卡片一致） |
| 34 | Profile **May 2026** 卡片 | 与 Gallery ROOM 01 相同：`May 2026 Archive`、MAY 时间轴、May 1–31, 2026 |
| 35 | Profile **Jun / Jul Preview** 卡片 | `Jun/Jul 2026 Archive`、JUN/JUL 时间轴、Preview 角标 |
| 36 | Collection room 返回 | 回到进入前的 Tab（Gallery→Gallery，Profile→Profile） |
| 37 | Highlights / Timeline | 各 3 条；API 有数据时按当月筛选；日期前缀为 **MAY/JUN/JUL** |
| 38 | **Open wall** | 回 Gallery，且 Gallery 顶部 room 芯片与刚浏览月份一致 |

## 已知限制

1. 需本机 Flutter；首次 `flutter create .`。
2. seed 图片 `.jpg` 占位会尝试 `.png`。
3. 无 `GET /api/public/collections`。
4. 编辑页 Story assistant 为本地草稿，非成员 E 真实 AI API。
5. 公开详情作者 **Tong** 为占位。
6. Jun/Jul 若无当月藏品，Highlights 为 Preview 占位、展品数可为 0。

## curl 验证后端

```bash
curl http://localhost:3000/api/health
curl "http://localhost:3000/api/collections?page=1&pageSize=6"
curl http://localhost:3000/api/collections/1
curl -X PUT http://localhost:3000/api/collections/1 -H "Content-Type: application/json" -d "{\"title\":\"test\"}"
curl http://localhost:3000/api/users/1/stats
curl http://localhost:3000/api/collections/tags
curl "http://localhost:3000/api/collections?visibility=public&pageSize=6"
```
