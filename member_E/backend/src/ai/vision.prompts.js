const { COLLECTION_CATEGORIES } = require('./ai.schemas');

function buildVisionAnalyzePrompt(input = {}) {
  const language = input.language || 'zh-CN';
  const imageDescription =
    typeof input.imageDescription === 'string' && input.imageDescription.trim().length > 0
      ? input.imageDescription.trim()
      : '未提供';
  const imageUrl =
    typeof input.imageUrl === 'string' && input.imageUrl.trim().length > 0
      ? input.imageUrl.trim()
      : '未提供';

  return `你是 Collection Journey App 的收藏品图片识别助手。

请仔细观察图片，从固定类别中选择最匹配的一项，并生成标题、标签和描述。

## 固定类别（必须严格选一）
${JSON.stringify(COLLECTION_CATEGORIES)}

## 规则
1. suggestedCategory 必须严格来自上面的固定类别列表。
2. suggestedTags 输出 3 到 8 个中文标签，不重复。
3. suggestedTitle 不超过 20 个中文字符，温暖、有个人记忆感，可编辑。
4. description 用 1 到 2 句话描述「看起来像什么」，不要写成完整故事。
5. 不要编造图片中未体现的具体品牌、人物、地点或事件。
6. 只输出一个 JSON object，不要输出任何解释或 Markdown。
7. 语言：${language}

## 图片信息（供参考）
- 用户补充描述：${imageDescription}
- 图片地址：${imageUrl}

请直接输出 JSON：
{
  "suggestedTitle": "...",
  "suggestedCategory": "...",
  "suggestedTags": ["...", "..."],
  "description": "..."
}`;
}

module.exports = { buildVisionAnalyzePrompt };