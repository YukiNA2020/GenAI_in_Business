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
  if (prompt.includes('tags assistant')) {
    return 'tags';
  }
  if (prompt.includes('story assistant')) {
    return 'story';
  }
  if (prompt.includes('image recognition assistant')) {
    return 'analyzeImage';
  }
  return 'title';
}

function getMockStoryByStyle(style) {
  const stories = {
    concise:
      'I kept this piece because it holds a moment I do not want to forget. Seeing it again brings back a quiet, steady gladness.',
    scrapbook:
      'Slipped it beside today’s notes—not precious, just the right weight for that afternoon. I still pause when I turn to this page.',
    travel:
      'I met it on the road: street, light, and footsteps in one frame. At home it feels like an unfinished journey I can reopen.',
    vintage:
      'Time has left a soft patina, as if the object still breathes. I save it so a slow, gentle hour can stay within reach.',
  };
  return stories[style] || stories.concise;
}

function getMockAnalyzeImagePayload(prompt) {
  const text = typeof prompt === 'string' ? prompt : '';
  if (text.includes('ticket')) {
    return {
      suggestedTitle: 'Vintage exhibition ticket',
      suggestedCategory: 'Tickets',
      suggestedTags: ['exhibition', 'ticket', 'vintage'],
      description: 'This looks like a printed event or exhibition ticket.',
    };
  }
  if (text.includes('vinyl') || text.includes('record')) {
    return {
      suggestedTitle: 'Well-kept vinyl cover',
      suggestedCategory: 'Vinyl Records',
      suggestedTags: ['vinyl', 'music', 'collecting'],
      description: 'This looks like a vinyl record or album cover.',
    };
  }
  if (text.includes('mineral') || text.includes('crystal')) {
    return {
      suggestedTitle: 'Natural mineral specimen',
      suggestedCategory: 'Minerals',
      suggestedTags: ['mineral', 'nature', 'specimen'],
      description: 'This looks like a mineral or crystal specimen.',
    };
  }
  return {
    suggestedTitle: 'Small keepsake worth saving',
    suggestedCategory: 'Other Collections',
    suggestedTags: ['keepsake', 'memory', 'everyday'],
    description: 'This looks like an everyday collectible worth keeping.',
  };
}

function getMockPayload(kind, prompt) {
  switch (kind) {
    case 'category':
      return { category: 'Postcards', confidence: 0.75 };
    case 'tags':
      return { tags: ['travel', 'postcard', 'bookshop'] };
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
        suggestions: ['A small memory kept', 'Quiet keepsake', 'Worth saving'],
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
