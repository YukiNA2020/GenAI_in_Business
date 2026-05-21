# 阶段三·任务五 — 与成员 3 Profile 联调说明

> **负责人**：成员 E / 成员 5，由该成员的 AI 工具协助更新

---

## 联调结果

Profile Tab 现为**单页滚动**：

1. **成员 E 区**（顶栏、头像/简介、Edit profile、四列统计含 Last added）
2. **成员 C 区**（`ProfileCollectionPreview(embeddedInMemberEProfile: true)`）  
   - Visitor preview / Recent exhibits / Favorite tags + 分类网格 / Collection rooms / Settings

---

## 共享逻辑

`frontend/lib/features/collection_browse/utils/profile_exhibit_utils.dart`

- `resolveRecentExhibits`、`resolveLastAdded`、`filterProfileItems`  
- 成员 E `ProfileStats` 与成员 C 最近展品使用同一数据源与排序规则

---

## 成员 C 文件变更（联调必需）

`profile_collection_preview.dart`：

- 新增参数 `embeddedInMemberEProfile`
- 嵌入模式省略顶栏、Tong 头像块、重复统计行
- 独立模式（全屏）行为与原先一致

---

## 验收对照

| 联调项 | 实现 |
|---|---|
| 最近收藏 | 成员 C Recent exhibits 横滑 + `CollectionCard` → 详情 |
| 分类统计 | 成员 E 四列统计 + 成员 C Favorite tags 分类筛选网格 |
| 空主页状态 | Recent / 分类网格空文案保留 |
| 编辑资料入口 | 成员 E `ProfileHeader` → Edit profile |
