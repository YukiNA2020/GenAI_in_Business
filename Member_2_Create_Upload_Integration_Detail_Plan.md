# 给未来 AI 的 Prompt

> 本文件是成员 B / 成员 2 的实际开发任务文档。请先阅读 `README.md`、`Project_intro.md`、`Status.md`、`Prompt_library.md` 和 `Final_Team_Work_Division.md`，再按本文档执行。
>
> 成员 B / 成员 2 负责创建收藏、编辑收藏、图片上传、AI 建议面板接入和最终整合优化。不要随意修改成员 A、C、D、E 或成员 6 的职责文件和模块；如必须改共享接口或字段，请同步记录到 `Status.md`。
>
> 每次完成开发、修复或文档更新后，请在 `Status.md` 和 `Prompt_library.md` 中标明“负责人：成员 B / 成员 2”。`past_doc/` 中的旧版本规划仅供参考，不作为当前任务依据。

---

# 成员 2 开发任务详细文档 - 创建收藏与图片上传，最终整合和优化

> 对应最终分工：成员 2｜创建收藏与图片上传 + 最终整合和优化  
> 角色类型：全栈 - 输入流程  
> 建议 DDL：22-25 号  
> 主要依赖方：成员 1、成员 4、成员 5

---

## 一、角色目标

成员 2 负责用户从“我要记录一件收藏”到“收藏成功保存”的完整输入流程。这个模块是 V1 MVP 的核心闭环之一，直接决定用户是否能够顺利完成第一件收藏。

一句话概括：

> 成员 2 要把创建、编辑、图片上传、表单校验、AI 建议接入和最终流程整合做成稳定可演示的用户路径。

---

## 二、总体负责范围

成员 2 负责：

1. 创建收藏页面。
2. 编辑收藏页面。
3. 图片选择、预览、上传。
4. 表单字段校验。
5. 调用成员 1 的收藏和图片 API。
6. 接入成员 5 的 AI 建议。
7. 根据成员 4 的视觉规范落地页面。
8. 动态表单功能。
9. 最终整合和流程优化。

成员 2 不主要负责：

1. 数据库 schema 设计。
2. 收藏墙和搜索页面。
3. AI Prompt 设计。
4. PPT 和视频。

---

## 三、技术路线总览

| 层级 | 技术方案 | 说明 |
|------|----------|------|
| 前端框架 | Flutter | 移动端主实现 |
| 状态管理 | Riverpod / Provider | 推荐 Riverpod 管理表单状态 |
| 图片选择 | image_picker | 相册和相机图片选择 |
| 网络请求 | dio / http | 调用后端 REST API |
| 表单校验 | Flutter Form + validator | 本地即时校验 |
| AI 接入 | AI suggestion panel | 使用成员 5 提供的 AI 接口 |
| 动态字段 | category schema rendering | 根据类别字段配置渲染表单 |

推荐目录：

```text
frontend/lib/features/collection_form/
├── pages/
│   ├── create_collection_page.dart
│   └── edit_collection_page.dart
├── widgets/
│   ├── collection_form.dart
│   ├── image_picker_field.dart
│   ├── tag_input_field.dart
│   ├── category_selector.dart
│   ├── dynamic_fields_section.dart
│   └── ai_suggestion_panel.dart
├── providers/
│   └── collection_form_provider.dart
├── models/
│   ├── collection_form_state.dart
│   └── dynamic_field_config.dart
└── services/
    └── collection_form_service.dart
```

---

## 四、阶段一：V1.1 创建收藏表单基础

### 阶段目标

先完成一个可以输入收藏信息的表单页面，即使后端和 AI 尚未完全接好，也能用本地 mock 状态开发 UI 和交互。

### 任务 1：搭建创建收藏页面

页面名称：

```text
CreateCollectionPage
```

页面结构：

1. 顶部标题。
2. 图片选择区域。
3. 标题输入框。
4. 分类选择。
5. 日期选择。
6. 地点输入框。
7. 标签输入。
8. 故事文本框。
9. 保存按钮。

实现重点：

1. 页面布局参考成员 4 的视觉规范。
2. 表单元素不要过度拥挤。
3. 保存按钮要有 loading 状态。

### 任务 2：建立表单状态模型

建议模型：

```dart
class CollectionFormState {
  final String title;
  final String category;
  final DateTime? dateAcquired;
  final String location;
  final List<String> tags;
  final String story;
  final String? localImagePath;
  final String? imageUrl;
  final bool isSubmitting;
  final String? errorMessage;
}
```

实现重点：

1. 每个字段变化都更新状态。
2. 状态层不要直接写 UI 代码。
3. 提交失败时保留用户已输入内容。

### 任务 3：实现基础表单校验

V1 必须校验：

1. 标题不能为空。
2. 标题建议不超过 40 字。
3. 日期不能晚于当前日期。
4. 标签数量不超过 10 个。
5. 故事不超过 1000 字。

错误提示原则：

1. 简短。
2. 显示在对应字段附近。
3. 不阻塞用户修改其他字段。

### 任务 4：实现分类选择组件

组件名称：

```text
CategorySelector
```

V1 默认类别：

1. 矿石
2. 水晶
3. 黑胶唱片
4. 明信片
5. 票根
6. 旅行纪念品
7. 其他

后续 V2 可以从成员 1 的 `GET /api/categories` 获取配置。

### 任务 5：实现标签输入组件

组件名称：

```text
TagInputField
```

交互要求：

1. 用户输入文字后点击添加。
2. 标签以胶囊样式显示。
3. 标签可以删除。
4. AI 推荐标签可以一键加入。

### 阶段一验收标准

1. 创建页面可以打开。
2. 用户可以填写所有基础字段。
3. 表单校验可用。
4. 标签可以添加和删除。
5. 页面视觉遵守成员 4 的规范。

---

## 五、阶段二：V1.2 图片选择、预览和上传

### 阶段目标

完成收藏图片相关流程，让用户可以选择图片、预览图片并上传到后端。

### 任务 1：实现图片选择组件

组件名称：

```text
ImagePickerField
```

技术方案：

```text
image_picker
```

功能要求：

1. 从相册选择图片。
2. 可选支持相机拍摄。
3. 选择后显示预览。
4. 支持重新选择。
5. 支持删除当前选择。

### 任务 2：实现图片本地预览

实现重点：

1. 使用本地文件路径显示预览。
2. 图片区域比例稳定。
3. 加载失败时显示占位。
4. 大图不要挤压表单。

### 任务 3：接入创建收藏 API

接口：

```text
POST /api/collections
```

提交流程：

```text
表单校验通过
  -> 调用创建收藏接口
  -> 获得 collection id
  -> 如果有图片，继续上传图片
  -> 成功后跳转收藏详情或收藏墙
```

### 任务 4：接入图片上传 API

接口：

```text
POST /api/collections/:id/image
```

实现重点：

1. 使用 multipart/form-data。
2. 上传中显示 loading。
3. 上传失败时允许重试。
4. 上传成功后保存 `imageUrl`。

### 任务 5：处理创建失败和上传失败

失败情况：

1. 网络错误。
2. 后端校验错误。
3. 图片文件过大。
4. 上传中断。

处理原则：

1. 不清空用户已填写内容。
2. 提供重试按钮。
3. 能手动保存无图片收藏。

### 阶段二验收标准

1. 用户可以选择并预览图片。
2. 用户可以创建带图片的收藏。
3. 图片上传失败时不会丢失表单内容。
4. 成员 1 的 API 可以稳定接入。

---

## 六、阶段三：V1.3 编辑收藏和 AI 建议接入

### 阶段目标

完成编辑收藏页面，并让用户可以把 AI 建议填入表单。

### 任务 1：开发编辑收藏页面

页面名称：

```text
EditCollectionPage
```

实现流程：

```text
进入编辑页
  -> 调用 GET /api/collections/:id
  -> 填充表单初始值
  -> 用户修改
  -> 调用 PUT /api/collections/:id
```

实现重点：

1. 复用 `CollectionForm`。
2. 初始值加载时显示 loading。
3. 保存成功后回到详情页。

### 任务 2：实现图片替换和删除

需要支持：

1. 当前已有图片展示。
2. 重新选择图片。
3. 删除当前图片。
4. 删除图片后同步后端。

涉及接口：

```text
POST /api/collections/:id/image
DELETE /api/collections/:id/image
```

### 任务 3：接入 AI 标题建议

接口由成员 5 提供：

```text
POST /api/ai/suggest-title
```

交互流程：

```text
用户输入少量信息
  -> 点击生成标题
  -> 展示 3 个建议
  -> 用户点击某个建议
  -> 填入标题输入框
```

### 任务 4：接入 AI 标签和分类建议

接口：

```text
POST /api/ai/suggest-category
POST /api/ai/suggest-tags
```

实现重点：

1. 分类建议可以一键选中。
2. 标签建议可以一键加入。
3. 用户可以删除 AI 标签。

### 任务 5：接入 AI 故事生成

接口：

```text
POST /api/ai/generate-story
```

实现重点：

1. AI 生成故事填入故事文本框。
2. 用户可以继续编辑。
3. AI loading 不影响其他字段输入。
4. AI 失败时提示用户手动填写。

### 阶段三验收标准

1. 用户可以编辑已有收藏。
2. 图片可以替换和删除。
3. AI 标题、分类、标签、故事建议可以写入表单。
4. 所有 AI 内容都可编辑。

---

## 七、阶段四：V2.1 动态表单和分类扩展

### 阶段目标

让不同收藏类别可以显示不同字段，为 V2 的分类体验优化做准备。

### 任务 1：读取分类配置

接口：

```text
GET /api/categories
```

分类配置示例：

```json
{
  "id": "vinyl",
  "name": "黑胶唱片",
  "fields": [
    {"name": "artist", "label": "艺术家", "type": "text"},
    {"name": "releaseYear", "label": "发行年份", "type": "year"}
  ]
}
```

### 任务 2：开发动态字段渲染组件

组件名称：

```text
DynamicFieldsSection
```

支持字段类型：

1. text
2. number
3. select
4. date
5. year

### 任务 3：保存 custom fields

保存格式：

```json
{
  "artist": "The Beatles",
  "releaseYear": "1969"
}
```

写入字段：

```text
customFields
```

### 任务 4：按类别优化表单文案

示例：

1. 票根类显示“活动地点”。
2. 黑胶类显示“艺术家”。
3. 矿石类显示“产地”和“成分”。

### 任务 5：联调详情页展示

成员 2 保存的动态字段，需要成员 3 在详情页展示。因此要提供字段结构说明。

### 阶段四验收标准

1. 选择不同类别时，表单字段会变化。
2. 动态字段可以保存和编辑。
3. 成员 3 可以正确展示动态字段。
4. 动态表单不影响 V1 基础字段。

---

## 八、阶段五：最终整合和优化

### 阶段目标

在 DDL 22-25 号完成全流程整合，保证创建流程、AI、后端、展示页可以稳定串起来。

### 任务 1：全流程联调

完整路径：

```text
打开创建页
  -> 选择图片
  -> 输入基础信息
  -> 使用 AI 建议
  -> 保存收藏
  -> 跳转收藏墙
  -> 点击详情
  -> 编辑收藏
```

### 任务 2：处理边界状态

需要覆盖：

1. 无网络。
2. AI 服务失败。
3. 图片上传失败。
4. 表单校验失败。
5. 后端返回 500。

### 任务 3：根据成员 4 视觉规范做页面修正

重点检查：

1. 间距。
2. 字体。
3. 按钮样式。
4. 标签样式。
5. 图片区域比例。

### 任务 4：配合成员 5 完成测试

需要提供：

1. 创建收藏测试路径。
2. 编辑收藏测试路径。
3. 图片上传测试路径。
4. AI 建议接入测试路径。

### 任务 5：最终代码清理和文档说明

需要整理：

1. 页面入口。
2. 依赖接口。
3. 已知限制。
4. 后续优化建议。

### 阶段五验收标准

1. 创建和编辑流程可稳定 Demo。
2. AI 建议可以顺利接入。
3. 图片上传流程稳定。
4. 表单交互没有明显阻塞问题。
5. 成员 6 可以录制完整创建流程。

---

## 九、最终交付物清单

| 交付物 | 用途 |
|--------|------|
| `create_collection_page.dart` | 创建收藏页面 |
| `edit_collection_page.dart` | 编辑收藏页面 |
| `collection_form.dart` | 表单复用组件 |
| `image_picker_field.dart` | 图片选择组件 |
| `tag_input_field.dart` | 标签输入组件 |
| `ai_suggestion_panel.dart` | AI 建议面板 |
| `dynamic_fields_section.dart` | 动态表单字段 |
| `Create_Flow_Test_Notes.md` | 创建流程自测说明 |

---

## 十、成员 2 最终汇报重点

成员 2 在汇报中应重点说明：

1. 如何实现创建收藏的完整用户路径。
2. 如何处理图片选择、预览和上传。
3. 如何把 AI 建议变成可编辑表单内容。
4. 如何根据类别支持动态表单。
5. 如何在最终阶段整合后端、AI 和收藏墙。
