# 图片识别 Prompt

负责人：成员 E / 成员 5  
阶段：阶段四 - 任务 1  
用途：根据 GLM Vision 看到的图片（或 fallback 图片描述）识别收藏品类型，输出标题、分类、标签与描述建议。

---

## 1. 目标

根据用户上传的收藏品图片生成可填入创建表单的结构化建议。当前主路径是前端传 `imageDataUrl` 给后端，由 GLM Vision 真实看图；没有真实图片时仍可用 `imageDescription` 作为文本 fallback。

要求：

1. 不编造图片中未体现的具体品牌、人物、地点或事件。
2. `suggestedCategory` 必须来自固定 7 类。
3. `suggestedTags` 3–8 个，不重复。
4. `suggestedTitle` 不超过 20 个中文字符。
5. 只输出 JSON。

---

## 2. 输入字段

```json
{
  "imageDataUrl": "data:image/png;base64,...",
  "imageDescription": "一张泛黄的展览票根，边缘略有磨损",
  "imageUrl": "/uploads/collections/collection-12-1715600000.jpg",
  "language": "zh-CN"
}
```

| 字段 | 类型 | 是否必填 | 说明 |
|---|---|---|---|
| `imageDataUrl` | string | 三选一 | GLM Vision 主路径；本地选图后由前端转成 data URL |
| `imageDescription` | string | 三选一 / 可选补充 | 图片内容描述；可作为 Vision 补充，也可在无图片时 fallback |
| `imageUrl` | string | 三选一 | 公网 HTTP/HTTPS 图片 URL |
| `language` | string | 否 | 默认 `zh-CN` |

---

## 3. Prompt 模板

```text
你是 Collection Journey App 的收藏品图片识别助手。请根据图片信息，判断这件收藏品可能属于哪一类，并给出标题、分类、标签和简短描述建议。

识别规则：
1. suggestedCategory 必须严格来自固定类别列表。
2. suggestedTags 输出 3 到 8 个中文标签，不重复。
3. suggestedTitle 不超过 20 个中文字符，温暖、可编辑。
4. description 用 1 到 2 句话说明「看起来像什么」，不要写成完整故事。
5. 不要编造图片中看不到的具体事实。
6. 只输出 JSON。

固定类别：["矿石","水晶","黑胶唱片","明信片","票根","旅行纪念品","其他"]

图片信息：
- 图片 data URL：{{imageDataUrl}}
- 图片描述：{{imageDescription}}
- 图片地址：{{imageUrl}}

输出格式：
{
  "suggestedTitle": "复古展览票根",
  "suggestedCategory": "票根",
  "suggestedTags": ["展览", "票根", "复古"],
  "description": "这看起来像一张展览或活动票根。"
}
```

---

## 4. 输出 Schema

| 字段 | 类型 | 约束 |
|---|---|---|
| `suggestedTitle` | string | 非空，≤20 字 |
| `suggestedCategory` | string | 固定 7 类之一 |
| `suggestedTags` | string[] | 3–8 个，唯一 |
| `description` | string | 非空 |

---

## 6. 自检

运行：

```bash
node member_E/scripts/verify_phase4_tasks1_5_api.js
node member_E/scripts/verify_glm_vision_live.js frontend/assets/screens/add_exhibit.png
```
