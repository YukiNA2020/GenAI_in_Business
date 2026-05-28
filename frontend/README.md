# 成员 3 — Flutter 收藏浏览模块

> **负责人**：成员 C / 成员 3，由该成员的 AI 工具协助编写  
> **上次更新**：2026-05-19（成员 C / 成员 3：月度 Room 统一、编辑页、文档同步）

严格遵循：

- 目录：`lib/features/collection_browse/`（见 `Member_3_Collection_Wall_Search_Detail_Plan.md` §三）
- 视觉：`design-export/png export/Collectory Museum Home UI/` 各屏 `Mobile.png` + `collectory-ui-handoff.md` + `design-export/design_tokens.json`
- 接口：`backend/` + 根目录 `API_Contract.md`（**禁止前端直连 SQLite**）

## 功能概览

| 模块 | 说明 |
|------|------|
| Museum Home | 柱廊场景 + Open room → May Collection room |
| Gallery | 三 room 芯片（May/Jun/Jul）+ 2×2 分层墙 + **Collection wall** |
| 月度 Room | Gallery 与 Profile **同 `roomIndex` 进入同一 Collection room**；日期随月份变化 |
| Collection wall | 每页 **6** 条；Previous/Next；下拉刷新保留筛选 |
| Item Detail | `GET /api/collections/:id`；`DELETE` |
| Edit exhibit | `PUT /api/collections/:id`；`POST …/image`；Story 草稿助手 |
| Profile | stats + Recent + 三张 room 卡 + Public preview |
| Share settings / Preview | Figma 单屏；Preview 独立叠层 |
| Public browse | `visibility=public` + 访客详情 |
| Add | `POST /api/collections` |

## 月度 Room（成员 C / 成员 3）

配置见 `lib/features/collection_browse/utils/collectory_room_catalog.dart`：

| roomIndex | 芯片 / 卡片 | Collection room 标题 | 时间轴前缀 | 日期区间 |
|-----------|-------------|------------------------|------------|----------|
| 0 | ROOM 01 · May 2026 | May 2026 Archive | MAY | May 1–31, 2026 |
| 1 | ROOM 02 · Jun 2026 | Jun 2026 Archive | JUN | Jun 1–30, 2026 |
| 2 | ROOM 03 · Jul 2026 | Jul 2026 Archive | JUL | Jul 1–31, 2026 |

- 导航：`openCollectionRoom(ref, roomIndex: i)`（`app_navigation_provider.dart`）
- 状态：`collectionRoomIndexProvider`；`app.dart` 中 `AnimatedSwitcher` key 为 `collectionRoom_$roomIndex`
- 返回：`closeCollectionRoom` 回到进入 room 前的 Tab

## 推荐目录（已实现）

```text
lib/
├── app.dart                          # 四 Tab + 叠层；room 按 roomIndex 分实例
├── core/
│   ├── layout/collectory_mobile_shell.dart
│   └── layout/collectory_status_bar.dart
└── features/collection_browse/
    ├── pages/
    │   ├── museum_home_page.dart
    │   ├── design_gallery_page.dart
    │   ├── collection_detail_page.dart
    │   ├── collection_room_page.dart      # roomIndex 构造参数
    │   ├── edit_collection_page.dart      # PUT + 图片上传
    │   ├── share_room_settings_page.dart
    │   ├── share_room_preview_page.dart
    │   ├── public_collections_page.dart
    │   ├── profile_design_page.dart
    │   ├── add_exhibit_design_page.dart
    │   └── layer_motion_page.dart
    ├── widgets/
    │   ├── collection_wall_slivers.dart
    │   ├── profile_collection_preview.dart
    │   ├── tag_filter_sheet.dart
    │   └── design/
    │       ├── room_selector_row.dart     # Gallery 三 room
    │       └── collectory_favorite_tags.dart
    ├── providers/
    │   ├── collection_list_provider.dart
    │   ├── app_navigation_provider.dart   # collectionRoomIndexProvider
    │   ├── share_room_preview_provider.dart
    │   └── member3_ui_settings_provider.dart
    ├── utils/
    │   ├── collectory_room_catalog.dart   # 成员 C / 成员 3
    │   └── gallery_layers.dart
    ├── models/
    └── services/
        └── collection_query_service.dart  # GET/POST/PUT/DELETE + multipart 图片
```

## 数据流

```text
Flutter (dio)
  → http://localhost:3000/api/*
  → backend (Express)
  → sql.js → backend/data/collectory.db
```

常用端点：`GET/POST/PUT/DELETE /api/collections`、`POST /api/collections/:id/image`、`GET /api/users/:id/stats`。

## 运行

```bash
# 终端 1 — 后端（必须，否则列表为空）
cd backend
npm install
npm run seed    # 首次或需重置
npm run dev     # http://localhost:3000

# 终端 2 — Flutter
cd frontend
flutter pub get
flutter run -d web-server --web-port=8090
```

浏览器：**http://localhost:8090**（端口占用可改 8085–8090）。

### API 基址

| 环境 | 默认 `apiBaseUrl` |
|------|-------------------|
| Web / 桌面 | `http://localhost:3000` |
| Android 模拟器 | `http://10.0.2.2:3000` |
| 自定义 | `--dart-define=API_BASE_URL=http://host:3000` |

### 自测

- 人工：**`Browse_Flow_Test_Notes.md`**（成员 C / 成员 3 编写）
- 合同：`node test_member3_api_contract.js`（32/32，需 backend）
- 记录：根目录 **`Test.md`**

## 依赖说明

- `file_picker`：编辑页换图（Web 选文件 → `POST …/image`）

## 已知限制

1. 无 `GET /api/public/collections` — 使用 `?visibility=public`。
2. 编辑页 Story assistant 为本地草稿，非成员 E 线上 AI。
3. 公开详情作者 **Tong** 为占位。
4. Web 改代码后需热重启 + 强制刷新浏览器。

## Flutter 运行模式（重要）

| 模式 | 命令 | 效果 |
|---|---|---|
| Debug 模式 | `flutter run -d web-server` | 有黄黑调试条、布局适配差、Bottom overflow 警告 |
| **Release 模式** | `flutter build web` + HTTP server | **无调试条、布局正常，推荐用于测试和演示** |

**推荐启动方式（用于测试和演示）：**

```bash
# 终端 1 — 后端
cd backend
AI_PROVIDER=mock npm run dev

# 终端 2 — Flutter Release
cd frontend
flutter build web
cd build/web
python3 -m http.server 8080

# 浏览器打开 http://localhost:8080
```

**不要用 `flutter run -d web-server`**（那是 Debug 模式，会有黄黑条和布局问题）。
