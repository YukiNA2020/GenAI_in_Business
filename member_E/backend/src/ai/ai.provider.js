const { AI_ERROR_CODES } = require('./ai.schemas');

const DEFAULT_TIMEOUT_MS = 15000;
const DEFAULT_MODEL = 'gpt-4o-mini';
const DEFAULT_BASE_URL = 'https://api.openai.com/v1';

class AiProviderError extends Error {
  constructor(code, message, options = {}) {
    super(message);
    this.name = 'AiProviderError';
    this.code = code;
    this.cause = options.cause;
  }
}

function getConfig() {
  const timeoutMs = Number(process.env.AI_TIMEOUT_MS);
  return {
    apiKey: (process.env.OPENAI_API_KEY || process.env.AI_API_KEY || '').trim(),
    provider: (process.env.AI_PROVIDER || 'auto').trim().toLowerCase(),
    model: (process.env.AI_MODEL || DEFAULT_MODEL).trim(),
    timeoutMs: Number.isFinite(timeoutMs) && timeoutMs > 0 ? timeoutMs : DEFAULT_TIMEOUT_MS,
    baseUrl: (process.env.AI_BASE_URL || DEFAULT_BASE_URL).replace(/\/$/, ''),
  };
}

function resolveProviderMode(config) {
  if (config.provider === 'mock') {
    return 'mock';
  }
  if (config.provider === 'openai') {
    return config.apiKey ? 'openai' : 'unavailable';
  }
  return config.apiKey ? 'openai' : 'mock';
}

function inferMockKind(prompt, explicitKind) {
  if (explicitKind) {
    return explicitKind;
  }
  if (typeof prompt !== 'string') {
    return 'title';
  }
  if (prompt.includes('收藏分类助手') || prompt.includes('固定类别')) {
    return 'category';
  }
  if (prompt.includes('收藏标签助手')) {
    return 'tags';
  }
  if (prompt.includes('收藏故事助手')) {
    return 'story';
  }
  if (prompt.includes('图片识别助手')) {
    return 'analyzeImage';
  }
  return 'title';
}

function getMockStoryByStyle(style) {
  const stories = {
    concise:
      '这件收藏被留下来，是因为它连接着某段不想忘记的时间。不必说太多，只要看见它，就能想起当时的安静与满足。',
    scrapbook:
      '今天把它收进本子边——不算贵重，却刚好装下那天的温度。后来翻到这里，仍会觉得心里轻轻顿了一下。',
    travel:
      '路途上遇见它时，街道、光线和脚步都挤在同一张照片里。带回家后，它像一小段未完的旅程，提醒我曾经到过那里。',
    vintage:
      '岁月在上面留下浅浅的痕迹，像旧物自有自己的呼吸。保存它，是为了让某段缓慢而温柔的时间继续留在手边。',
  };
  return stories[style] || stories.concise;
}

function getMockAnalyzeImagePayload(prompt) {
  const text = typeof prompt === 'string' ? prompt : '';
  if (text.includes('票根') || text.includes('ticket')) {
    return {
      suggestedTitle: '复古展览票根',
      suggestedCategory: '票根',
      suggestedTags: ['展览', '票根', '复古'],
      description: '这看起来像一张展览或活动票根。',
    };
  }
  if (text.includes('黑胶') || text.includes('vinyl') || text.includes('唱片')) {
    return {
      suggestedTitle: '封面完好的黑胶',
      suggestedCategory: '黑胶唱片',
      suggestedTags: ['黑胶', '音乐', '收藏'],
      description: '这看起来像一张黑胶唱片或相关封面。',
    };
  }
  if (text.includes('矿石') || text.includes('mineral') || text.includes('水晶')) {
    return {
      suggestedTitle: '天然矿石标本',
      suggestedCategory: '矿石',
      suggestedTags: ['矿石', '自然', '标本'],
      description: '这看起来像一块矿石或矿物标本。',
    };
  }
  return {
    suggestedTitle: '值得保存的小物',
    suggestedCategory: '其他',
    suggestedTags: ['收藏', '纪念', '日常'],
    description: '这看起来像一件值得保存的日常收藏品。',
  };
}

function getMockPayload(kind, prompt) {
  switch (kind) {
    case 'category':
      return { category: '明信片', confidence: 0.75 };
    case 'tags':
      return { tags: ['旅行', '明信片', '书店'] };
    case 'story': {
      let style = 'concise';
      if (typeof prompt === 'string') {
        const match = prompt.match(/风格代码：(\w+)/);
        if (match) {
          style = match[1];
        }
      }
      return { story: getMockStoryByStyle(style) };
    }
    case 'analyzeImage':
      return getMockAnalyzeImagePayload(prompt);
    case 'title':
    default:
      return {
        suggestions: ['我的收藏记忆', '一件小小收藏', '值得保存的瞬间'],
      };
  }
}

function extractJsonText(text) {
  if (typeof text !== 'string') {
    return '';
  }
  const trimmed = text.trim();
  const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fenced) {
    return fenced[1].trim();
  }
  const firstBrace = trimmed.indexOf('{');
  const lastBrace = trimmed.lastIndexOf('}');
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    return trimmed.slice(firstBrace, lastBrace + 1);
  }
  return trimmed;
}

function parseModelJson(text) {
  const jsonText = extractJsonText(text);
  if (!jsonText) {
    throw new AiProviderError(AI_ERROR_CODES.invalidResponse, 'AI returned an empty response.');
  }
  try {
    const parsed = JSON.parse(jsonText);
    if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('parsed value is not a JSON object');
    }
    return parsed;
  } catch (error) {
    throw new AiProviderError(AI_ERROR_CODES.invalidResponse, 'AI returned an invalid response format.', {
      cause: error,
    });
  }
}

async function callOpenAIChat(prompt, config) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), config.timeoutMs);

  try {
    const response = await fetch(`${config.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: config.model,
        temperature: 0.4,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: 'You are a helpful assistant. Always reply with a single valid JSON object only.',
          },
          { role: 'user', content: prompt },
        ],
      }),
      signal: controller.signal,
    });

    const body = await response.json().catch(() => ({}));

    if (!response.ok) {
      const providerMessage =
        body?.error?.message || `OpenAI API responded with status ${response.status}`;
      throw new AiProviderError(
        AI_ERROR_CODES.providerUnavailable,
        'AI suggestion is temporarily unavailable. You can still save manually.',
        { cause: new Error(providerMessage) }
      );
    }

    const content = body?.choices?.[0]?.message?.content;
    if (!content) {
      throw new AiProviderError(AI_ERROR_CODES.invalidResponse, 'AI returned an invalid response format.');
    }

    return content;
  } catch (error) {
    if (error instanceof AiProviderError) {
      throw error;
    }
    const isTimeout = error?.name === 'AbortError';
    throw new AiProviderError(
      AI_ERROR_CODES.providerUnavailable,
      'AI suggestion is temporarily unavailable. You can still save manually.',
      { cause: isTimeout ? new Error(`AI request timed out after ${config.timeoutMs}ms`) : error }
    );
  } finally {
    clearTimeout(timer);
  }
}

/**
 * 调用 AI 模型并返回通过校验的结构化 JSON。
 * @param {string} prompt - 完整 Prompt 文本
 * @param {object} options
 * @param {(value: object) => boolean} options.validate - 响应结构校验函数
 * @param {'title'|'category'|'tags'|'story'} [options.mockKind] - mock 模式下的响应类型
 * @returns {Promise<object>}
 */
async function generateJson(prompt, options = {}) {
  const { validate, mockKind } = options;

  if (typeof prompt !== 'string' || prompt.trim().length === 0) {
    throw new AiProviderError(AI_ERROR_CODES.validation, 'prompt is required');
  }
  if (typeof validate !== 'function') {
    throw new AiProviderError(AI_ERROR_CODES.validation, 'validate function is required');
  }

  const config = getConfig();
  const mode = resolveProviderMode(config);

  let rawText;
  if (mode === 'mock') {
    rawText = JSON.stringify(getMockPayload(inferMockKind(prompt, mockKind), prompt));
  } else if (mode === 'openai') {
    rawText = await callOpenAIChat(prompt, config);
  } else {
    throw new AiProviderError(
      AI_ERROR_CODES.providerUnavailable,
      'AI suggestion is temporarily unavailable. You can still save manually.'
    );
  }

  const parsed = parseModelJson(rawText);
  if (!validate(parsed)) {
    throw new AiProviderError(AI_ERROR_CODES.invalidResponse, 'AI returned an invalid response format.');
  }

  return parsed;
}

module.exports = {
  AiProviderError,
  DEFAULT_MODEL,
  DEFAULT_TIMEOUT_MS,
  getConfig,
  resolveProviderMode,
  generateJson,
  parseModelJson,
  extractJsonText,
};
