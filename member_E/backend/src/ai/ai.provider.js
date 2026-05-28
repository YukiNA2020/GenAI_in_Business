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
  if (prompt.includes('category assistant') || prompt.includes('Fixed categories')) {
    return 'category';
  }
  if (prompt.includes('tag assistant')) {
    return 'tags';
  }
  if (prompt.includes('story assistant')) {
    return 'story';
  }
  if (prompt.includes('image recognition')) {
    return 'analyzeImage';
  }
  if (prompt.includes('room reflection') || prompt.includes('Room Reflection')) {
    return 'roomReflection';
  }
  if (prompt.includes('title suggestions') || prompt.includes('Generate 3 English title')) {
    return 'title';
  }
  return 'title';
}

function getMockStoryByStyle(style) {
  const stories = {
    concise:
      'This piece stays because it connects to a time I do not want to forget. No need to say much — just seeing it brings back the quiet satisfaction of that moment.',
    scrapbook:
      'Tucked it into the edge of my journal today — nothing fancy, but it fit the temperature of that day. Flipping back, it still makes me pause.',
    travel:
      'Found it on the road where the street, the light and my footsteps all crowded into the same photo. It sits in my room like an unfinished journey, reminding me I was there.',
    vintage:
      'Time has left faint traces on it, as old things breathe in their own way. Keeping it means letting a certain slow and gentle kind of time stay a little longer.',
  };
  return stories[style] || stories.concise;
}

function getMockAnalyzeImagePayload(prompt) {
  const text = typeof prompt === 'string' ? prompt : '';
  if (text.includes('ticket') || text.includes('Ticket')) {
    return {
      suggestedTitle: 'Vintage Exhibition Ticket',
      suggestedCategory: 'Tickets',
      suggestedTags: ['Exhibition', 'Ticket', 'Vintage'],
      description: 'This looks like an exhibition or event ticket.',
    };
  }
  if (text.includes('vinyl') || text.includes('Vinyl') || text.includes('record')) {
    return {
      suggestedTitle: 'Well-Preserved Vinyl Record',
      suggestedCategory: 'Vinyl Records',
      suggestedTags: ['Vinyl', 'Music', 'Collection'],
      description: 'This looks like a vinyl record or its cover.',
    };
  }
  if (text.includes('mineral') || text.includes('Mineral') || text.includes('crystal') || text.includes('Crystal')) {
    return {
      suggestedTitle: 'Natural Mineral Specimen',
      suggestedCategory: 'Minerals',
      suggestedTags: ['Mineral', 'Nature', 'Specimen'],
      description: 'This looks like a mineral or crystal specimen.',
    };
  }
  return {
    suggestedTitle: 'A Small Thing Worth Keeping',
    suggestedCategory: 'Other Collections',
    suggestedTags: ['Collection', 'Memory', 'Daily'],
    description: 'This looks like an everyday collectible worth preserving.',
  };
}

function getMockPayload(kind, prompt) {
  switch (kind) {
    case 'category':
      return { category: 'Postcards', confidence: 0.75 };
    case 'tags':
      return { tags: ['Travel', 'Postcards', 'Bookshop'] };
    case 'roomReflection':
      return { reflection: 'A rich month of memories — this room holds stories of travel, music, and quiet moments collected together.' };
    case 'story': {
      let style = 'concise';
      if (typeof prompt === 'string') {
        const match = prompt.match(/Style code:\s*(\w+)/i);
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
        suggestions: ['My Collection Memory', 'A Small Keepsake', 'A Moment Worth Preserving'],
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
