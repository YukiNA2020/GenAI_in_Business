# 阶段三·任务 1–4 完成说明

> **负责人**：成员 E / 成员 5，由该成员的 AI 工具协助更新

---

## 任务对照

| 任务 | 交付物 | 说明 |
|---|---|---|
| 1 用户主页 | `profile_page.dart` + `profile_header.dart` | 头像、昵称、简介、编辑入口 |
| 2 收藏统计 | `profile_stats.dart` | `GET /api/users/:id/stats`（复用 `userStatsProvider`） |
| 3 编辑资料 | `edit_profile_page.dart` | 昵称、头像 URL、简介、收藏偏好；**本地 mock 保存** |
| 4 登录注册占位 | `login_placeholder_page.dart`、`register_placeholder_page.dart` | Mock 会话 `authSessionProvider` |

任务 5（与成员 3 联调）未在本轮实现；成员 C 的 `ProfileCollectionPreview` 通过 Profile 页按钮 **Open museum rooms (Member 3)** 进入。

---

## 目录

```text
frontend/lib/features/profile/     # 可运行副本
member_E/frontend/lib/features/profile/   # 成员 E 工作区副本
```

---

## 运行自测

```bash
cd backend && npm run dev
cd frontend && flutter run -d chrome
```

1. 打开 **Profile** Tab → 见 MY ARCHIVE (Member E)、统计、Recent exhibits  
2. **Edit profile** → 修改并 Save → 返回见更新  
3. **Sign out** → **Sign in** → mock 登录  
4. **Open museum rooms (Member 3)** → 全屏成员 C 原 Profile 内容  

---

## 跨成员说明

- `profile_design_page.dart`（成员 C）改为挂载 `ProfilePage`（成员 E），已注释说明。
- 无新增后端 `PUT /api/users`；资料编辑仅存 Riverpod 内存。
