# 给未来 AI 的 Prompt

> 本文件是成员 E / 成员 5 的实际开发任务文档。请先阅读 `README.md`、`Project_intro.md`、`Status.md`、`Prompt_library.md`、`Final_Team_Work_Division.md` 和 `Test.md`，再按本文档执行。
>
> 成员 E / 成员 5 负责 AI 功能、用户主页、测试用例、Bug 跟踪和 Demo 联调支持。不要随意修改成员 A、成员 B、成员 C、成员 D 或成员 6 的职责文件和模块；如必须改 AI 接口、测试范围、用户字段或共享流程，请同步记录到 `Status.md` 和必要的 `Test.md`。
>
> 每次完成开发、测试、修复或文档更新后，请在 `Status.md`、`Prompt_library.md` 和必要的 `Test.md` 中标明“负责人：成员 E / 成员 5”。`past_doc/` 中的旧版本规划仅供参考，不作为当前任务依据。

---

# 成员 5 开发任务详细文档 - AI 功能，用户主页与测试

> 对应最终分工：成员 5｜AI 功能 + 用户主页 + 测试  
> 角色类型：核心支撑层  
> 建议 DDL：18-21 号  
> 主要依赖方：成员 1、成员 2、成员 3、成员 4、成员 6

---

## 一、角色目标

成员 5 负责项目的核心支撑能力，包括 AI 辅助记录、用户主页、登录注册占位、个人资料编辑，以及测试用例和 Bug 跟踪。这个角色横跨产品差异化、用户留存和项目质量保障。

一句话概括：

> 成员 5 要让 AI 真正降低记录成本，同时保证用户主页和全流程测试能支撑最终 Demo。

---

## 二、总体负责范围

成员 5 负责：

1. AI Prompt 模板。
2. AI 标题、分类、标签、故事生成接口。
3. AI 图片识别方案。
4. 多风格故事生成。
5. 用户主页。
6. 收藏统计展示。
7. 登录 / 注册占位。
8. 个人资料编辑。
9. 测试用例编写。
10. Bug 跟踪和 Demo 流程校验。

成员 5 不主要负责：

1. 收藏 CRUD 主接口。
2. 创建表单具体页面。
3. 收藏墙主页面。
4. UI 高保真设计。
5. PPT 和视频制作。

---

## 三、技术路线总览

| 层级 | 技术方案 | 说明 |
|------|----------|------|
| AI 服务 | OpenAI API / Claude API | V1 先文字 AI，V2 再图片识别 |
| AI 路由 | Node.js + Express | 与后端服务统一 |
| Prompt 管理 | Markdown + JS template | 便于记录和调优 |
| 前端主页 | Flutter | 用户主页和资料编辑 |
| 状态管理 | Riverpod / Provider | 管理用户和 AI 状态 |
| 测试 | Test.md + 手动测试 + API 测试 | 课程项目优先可执行 |
| Bug 管理 | Test.md / Bug 表 | 统一记录和跟踪 |

推荐目录：

```text
backend/src/ai/
├── ai.service.js
├── ai.provider.js
├── ai.prompts.js
├── ai.schemas.js
└── ai.routes.js

docs/prompts/
├── prompt_title.md
├── prompt_category.md
├── prompt_tags.md
├── prompt_story.md
└── prompt_image_analysis.md

frontend/lib/features/profile/
├── pages/
│   ├── profile_page.dart
│   └── edit_profile_page.dart
├── widgets/
│   ├── profile_header.dart
│   ├── profile_stats.dart
│   └── recent_collections_section.dart
└── providers/
    └── profile_provider.dart
```

---

## 四、阶段一：V1.1 AI Prompt 模板和接口方案

### 阶段目标

先把 AI 要做什么、输入什么、输出什么确定下来，避免成员 2 接入时接口不稳定。

### 任务 1：设计标题生成 Prompt

目标：

根据用户输入的类别、地点、日期和描述，生成 3 个标题建议。

要求：

1. 每个标题不超过 20 字。
2. 有情感但不过度夸张。
3. 不编造用户没有提供的信息。
4. 输出结构稳定。

输出格式：

```json
{
  "suggestions": ["标题1", "标题2", "标题3"]
}
```

### 任务 2：设计分类建议 Prompt

目标：

根据用户输入和图片描述，推荐最合适的收藏类别。

默认类别：

1. 矿石
2. 水晶
3. 黑胶唱片
4. 明信片
5. 票根
6. 旅行纪念品
7. 其他

输出格式：

```json
{
  "category": "明信片",
  "confidence": 0.82
}
```

### 任务 3：设计标签推荐 Prompt

目标：

生成 3-8 个标签，帮助用户整理收藏。

要求：

1. 标签短。
2. 不重复。
3. 不要太泛。
4. 尽量包含地点、类别、情绪或主题。

输出格式：

```json
{
  "tags": ["东京", "明信片", "旅行", "书店"]
}
```

### 任务 4：设计故事生成 Prompt

目标：

生成 100-150 字的收藏故事草稿。

要求：

1. 温暖。
2. 可编辑。
3. 不编造具体事实。
4. 适合作为用户个人记忆记录。

输出格式：

```json
{
  "story": "生成的故事文本"
}
```

### 任务 5：确定 AI API Contract

需要和成员 2 确认：

1. 前端传哪些字段。
2. 后端返回哪些字段。
3. AI 失败时返回什么错误。
4. loading 状态如何处理。

### 阶段一验收标准

1. 四类基础 Prompt 有文档。
2. AI API 输入输出格式固定。
3. 成员 2 可以根据格式做 AI 建议面板。

---

## 五、阶段二：V1.2 AI 接口开发和表单联调

### 阶段目标

完成 AI 标题、分类、标签、故事生成接口，并与成员 2 的创建表单联调。

### 任务 1：实现 AI Provider 封装

职责：

1. 读取 API key。
2. 调用 AI 模型。
3. 设置 timeout。
4. 捕获错误。
5. 返回结构化 JSON。

建议函数：

```javascript
generateJson(prompt, schema)
```

### 任务 2：实现标题建议接口

接口：

```text
POST /api/ai/suggest-title
```

实现重点：

1. 参数校验。
2. 调用标题 Prompt。
3. 返回 3 个建议。
4. AI 失败时返回明确错误码。

### 任务 3：实现分类和标签建议接口

接口：

```text
POST /api/ai/suggest-category
POST /api/ai/suggest-tags
```

实现重点：

1. 分类必须落在默认类别中。
2. 标签数量受控。
3. 输出不能包含空字符串。

### 任务 4：实现故事生成接口

接口：

```text
POST /api/ai/generate-story
```

实现重点：

1. 生成内容适中。
2. 可以根据类别调整语气。
3. 不影响用户手动保存。

### 任务 5：和成员 2 联调 AI 面板

联调路径：

```text
创建收藏页面
  -> 输入少量字段
  -> 点击 AI 建议
  -> AI 返回结果
  -> 用户选择并写入表单
  -> 保存收藏
```

### 阶段二验收标准

1. 四个 AI 文字接口可用。
2. AI 输出结构稳定。
3. 成员 2 可以成功接入表单。
4. AI 服务失败不阻塞创建收藏。

---

## 六、阶段三：V2.1 用户主页、登录注册占位和个人资料

### 阶段目标

完成用户主页和基础用户信息展示，为 V2 留存体验做准备。

### 任务 1：开发用户主页

页面名称：

```text
ProfilePage
```

展示内容：

1. 头像。
2. 昵称。
3. 简介。
4. 收藏总数。
5. 收藏类别数量。
6. 最近收藏。
7. 编辑资料入口。

### 任务 2：开发收藏统计展示

数据来源：

```text
GET /api/users/:id/stats
```

如果成员 1 暂时没有接口，可先使用 mock 数据。

统计项：

1. totalCollections
2. categoryCount
3. publicCollections
4. recentCollections

### 任务 3：开发个人资料编辑页面

页面名称：

```text
EditProfilePage
```

字段：

1. 昵称。
2. 头像。
3. 简介。
4. 个人收藏偏好。

### 任务 4：开发登录 / 注册占位

V1-V2 课程项目可以先做占位：

1. 登录页 UI。
2. 注册页 UI。
3. 本地 mock 登录状态。
4. 后续接入真实 JWT。

### 任务 5：与成员 3 联调主页收藏展示

成员 5 负责主页框架，成员 3 负责收藏卡片展示组件复用。

联调重点：

1. 最近收藏。
2. 分类统计。
3. 空主页状态。
4. 编辑资料入口。

### 阶段三验收标准

1. 用户主页可以展示。
2. 收藏统计区域可用。
3. 编辑资料页面可以打开和保存 mock 数据。
4. 登录注册占位不阻塞 Demo。

---

## 七、阶段四：V2.3 AI 图片识别和多风格故事

### 阶段目标

在基础文字 AI 可用后，扩展图片识别和风格化故事能力。

### 任务 1：设计图片识别 Prompt

目标：

根据图片识别收藏品可能类型，并输出标题、分类、标签和描述建议。

输出格式：

```json
{
  "suggestedTitle": "复古展览票根",
  "suggestedCategory": "票根",
  "suggestedTags": ["展览", "票根", "复古"],
  "description": "这看起来像一张展览或活动票根。"
}
```

### 任务 2：实现图片识别接口方案

接口：

```text
POST /api/ai/analyze-image
```

V2 可以接入 Vision API。若时间不足，课程 Demo 可先用 mock 响应模拟图片识别。

### 任务 3：设计多风格故事 Prompt

支持风格：

1. concise - 简洁风。
2. scrapbook - 手账风。
3. travel - 旅行日记风。
4. vintage - 复古风。

### 任务 4：扩展故事生成接口

接口：

```text
POST /api/ai/generate-story
```

新增参数：

```json
{
  "style": "scrapbook"
}
```

### 任务 5：与成员 2 联调图片识别填表

流程：

```text
用户上传图片
  -> 点击识别图片
  -> AI 返回建议
  -> 自动填入标题、分类、标签、描述
  -> 用户编辑
```

### 阶段四验收标准

1. 图片识别接口方案明确。
2. 多风格故事生成可用或有 mock。
3. AI 图片结果可以被表单使用。
4. 风格化故事适合展示给成员 6 做 Demo。

---

## 八、阶段五：测试用例、Bug 跟踪和 Demo 校验

### 阶段目标

成员 5 还负责全流程测试与 Bug 跟踪，保证最终 Demo 稳定。

### 任务 1：编写测试计划

测试范围：

1. 创建收藏。
2. 图片上传。
3. AI 建议。
4. 收藏墙展示。
5. 搜索筛选。
6. 收藏详情。
7. 用户主页。

写入：

```text
Test.md
```

### 任务 2：编写核心测试用例

测试用例格式：

```text
用例编号
测试模块
前置条件
操作步骤
预期结果
实际结果
状态
备注
```

至少覆盖：

1. 成功创建收藏。
2. 标题为空不能保存。
3. 图片上传成功。
4. AI 标题建议成功。
5. AI 失败后仍可手动保存。
6. 搜索关键词返回结果。
7. 详情页展示完整数据。

### 任务 3：建立 Bug 跟踪表

Bug 字段：

1. Bug ID。
2. 模块。
3. 描述。
4. 复现步骤。
5. 严重程度。
6. 负责人。
7. 状态。

### 任务 4：执行全链路 Demo 测试

Demo 路径：

```text
打开 App
  -> 进入创建收藏
  -> 上传图片
  -> 输入基本信息
  -> 使用 AI 生成建议
  -> 保存收藏
  -> 返回收藏墙
  -> 搜索收藏
  -> 打开详情
  -> 查看个人主页
```

### 任务 5：给成员 6 输出测试结论和 Demo 亮点

需要提供：

1. 功能完成情况。
2. AI 示例输出。
3. Demo 流程说明。
4. 已知问题和规避方式。
5. 可放入 PPT 的测试结论。

### 阶段五验收标准

1. `Test.md` 已更新。
2. 核心测试用例完整。
3. Bug 有记录和状态。
4. Demo 路径至少跑通 2 次。
5. 成员 6 可以拿到测试和 AI 材料。

---

## 九、最终交付物清单

| 交付物 | 用途 |
|--------|------|
| `docs/prompts/prompt_title.md` | 标题生成 Prompt |
| `docs/prompts/prompt_category.md` | 分类建议 Prompt |
| `docs/prompts/prompt_tags.md` | 标签推荐 Prompt |
| `docs/prompts/prompt_story.md` | 故事生成 Prompt |
| `docs/prompts/prompt_image_analysis.md` | 图片识别 Prompt |
| `backend/src/ai/ai.service.js` | AI 服务封装 |
| `backend/src/ai/ai.routes.js` | AI 接口 |
| `profile_page.dart` | 用户主页 |
| `edit_profile_page.dart` | 编辑资料页 |
| `Test.md` 更新内容 | 测试记录和 Bug 跟踪 |

---

## 十、成员 5 最终汇报重点

成员 5 在汇报中应重点说明：

1. AI 如何降低用户记录收藏的成本。
2. Prompt 如何控制输出质量和格式。
3. AI 失败时如何不影响主流程。
4. 用户主页如何增强长期使用动机。
5. 测试如何保证最终 Demo 稳定。
