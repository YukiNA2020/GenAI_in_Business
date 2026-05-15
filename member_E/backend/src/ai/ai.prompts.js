const { COLLECTION_CATEGORIES } = require('./ai.schemas');

function valueOrEmpty(value) {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : '未提供';
}

function buildTitlePrompt(input = {}) {
  return `你是 Collection Journey App 的 AI 收藏记录助手。请根据用户提供的信息，为这件收藏品生成 3 个中文标题建议。

生成规则：
1. 每个标题不超过 20 个中文字符。
2. 标题要温暖、有个人记忆感，但不要夸张。
3. 不要编造用户没有提供的事实、品牌、地点、人物或事件。
4. 如果信息不足，请使用更中性的标题。
5. 只输出 JSON，不要输出 Markdown 或解释文字。

用户输入：
- 类别：${valueOrEmpty(input.category)}
- 地点：${valueOrEmpty(input.location)}
- 日期：${valueOrEmpty(input.dateAcquired)}
- 描述：${valueOrEmpty(input.description)}

请严格按照以下 JSON 格式输出：
{
  "suggestions": ["标题1", "标题2", "标题3"]
}`;
}

function buildCategoryPrompt(input = {}) {
  return `你是 Collection Journey App 的收藏分类助手。请根据用户输入，从固定类别列表中选择一个最合适的类别。

固定类别只能是：
${JSON.stringify(COLLECTION_CATEGORIES)}

分类规则：
1. category 必须严格来自固定类别列表。
2. confidence 是 0 到 1 之间的小数，表示你对分类的信心。
3. 如果信息不足或无法判断，请选择 "其他"，confidence 不要高于 0.5。
4. 不要输出固定类别以外的名称。
5. 只输出 JSON，不要输出 Markdown 或解释文字。

用户输入：
- 标题：${valueOrEmpty(input.title)}
- 描述：${valueOrEmpty(input.description)}
- 地点：${valueOrEmpty(input.location)}
- 图片描述：${valueOrEmpty(input.imageDescription)}

请严格按照以下 JSON 格式输出：
{
  "category": "明信片",
  "confidence": 0.82
}`;
}

function buildTagsPrompt(input = {}) {
  return `你是 Collection Journey App 的收藏标签助手。请根据用户提供的信息，为这件收藏品生成 3 到 8 个中文标签。

标签规则：
1. 每个标签要短，建议 2 到 6 个中文字符。
2. 标签不能重复。
3. 不要输出过于泛化的标签，例如“收藏”“物品”“记录”。
4. 尽量包含地点、类别、情绪、主题或使用场景。
5. 如果信息不足，也要返回至少 3 个保守标签。
6. 只输出 JSON，不要输出 Markdown 或解释文字。

用户输入：
- 标题：${valueOrEmpty(input.title)}
- 类别：${valueOrEmpty(input.category)}
- 地点：${valueOrEmpty(input.location)}
- 描述：${valueOrEmpty(input.description)}

请严格按照以下 JSON 格式输出：
{
  "tags": ["东京", "明信片", "旅行", "书店"]
}`;
}

function buildStoryPrompt(input = {}) {
  return `你是 Collection Journey App 的收藏故事助手。请根据用户提供的信息，生成一段 100 到 150 个中文字符左右的收藏故事草稿。

写作规则：
1. 语气温暖、自然，有个人记忆感。
2. 不要编造用户没有提供的具体事实、人物、品牌或事件。
3. 如果信息不足，请围绕“保存这件收藏的意义”写得更保守。
4. 文本应方便用户继续编辑，不要写成广告文案。
5. 只输出 JSON，不要输出 Markdown 或解释文字。

用户输入：
- 标题：${valueOrEmpty(input.title)}
- 类别：${valueOrEmpty(input.category)}
- 地点：${valueOrEmpty(input.location)}
- 日期：${valueOrEmpty(input.dateAcquired)}
- 描述：${valueOrEmpty(input.description)}

请严格按照以下 JSON 格式输出：
{
  "story": "生成的故事文本"
}`;
}

module.exports = {
  buildTitlePrompt,
  buildCategoryPrompt,
  buildTagsPrompt,
  buildStoryPrompt,
};
