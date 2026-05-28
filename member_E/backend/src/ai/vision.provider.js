/**
 * GLM Vision provider for Collection Journey image recognition.
 *
 * This provider is intentionally separate from ai.provider.js:
 * - ai.provider.js handles text-only DeepSeek/OpenAI-compatible JSON calls.
 * - vision.provider.js handles real image inputs for POST /api/ai/analyze-image.
 */

const { AiProviderError, parseModelJson } = require('./ai.provider');
const { AI_ERROR_CODES } = require('./ai.schemas');

const DEFAULT_GLM_BASE_URL = 'https://open.bigmodel.cn/api/paas/v4';
const DEFAULT_GLM_VISION_MODEL = 'glm-4v-flash';
const DEFAULT_VISION_TIMEOUT_MS = 45000;
const DEFAULT_VISION_MAX_IMAGE_BYTES = 20 * 1024 * 1024;

class VisionProviderError extends Error {
  constructor(code, message, options = {}) {
    super(message);
    this.name = 'VisionProviderError';
    this.code = code;
    this.cause = options.cause;
  }
}

function getVisionConfig() {
  const timeoutMs = Number(process.env.ZHIPU_VISION_TIMEOUT_MS);
  const maxBytes = Number(process.env.ZHIPU_VISION_MAX_IMAGE_BYTES || process.env.VISION_MAX_IMAGE_BYTES);
  const baseUrl = (process.env.ZHIPU_API_BASE_URL || DEFAULT_GLM_BASE_URL).replace(/\/$/, '');

  return {
    provider: (process.env.VISION_PROVIDER || 'glm').trim().toLowerCase(),
    apiKey: (
      process.env.ZHIPU_API_KEY ||
      process.env.BIGMODEL_API_KEY ||
      process.env.GLM_API_KEY ||
      ''
    ).trim(),
    baseUrl,
    model: (process.env.ZHIPU_VISION_MODEL || DEFAULT_GLM_VISION_MODEL).trim(),
    timeoutMs: Number.isFinite(timeoutMs) && timeoutMs > 0 ? timeoutMs : DEFAULT_VISION_TIMEOUT_MS,
    maxImageBytes: Number.isFinite(maxBytes) && maxBytes > 0 ? maxBytes : DEFAULT_VISION_MAX_IMAGE_BYTES,
  };
}

function parseDataUrl(dataUrl) {
  if (typeof dataUrl !== 'string' || !dataUrl.startsWith('data:')) {
    return null;
  }

  const commaIdx = dataUrl.indexOf(',');
  if (commaIdx < 0) {
    return null;
  }

  const meta = dataUrl.slice(5, commaIdx);
  const mimeType = meta.split(';')[0].toLowerCase();
  const raw = dataUrl.slice(commaIdx + 1);

  if (!meta.toLowerCase().includes('base64') || !/^[A-Za-z0-9+/=]+$/.test(raw)) {
    return null;
  }

  return { mimeType, base64: raw };
}

function isAllowedImageMime(mimeType) {
  return ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(
    String(mimeType || '').toLowerCase()
  );
}

function endpointForConfig(config) {
  return config.baseUrl.endsWith('/chat/completions')
    ? config.baseUrl
    : `${config.baseUrl}/chat/completions`;
}

function normalizeImageInput(imageInput, config) {
  if (!imageInput || (!imageInput.dataUrl && !imageInput.imageUrl)) {
    throw new VisionProviderError(AI_ERROR_CODES.validation, 'imageDataUrl or imageUrl is required');
  }

  if (imageInput.dataUrl) {
    const parsed = parseDataUrl(imageInput.dataUrl);
    if (!parsed) {
      throw new VisionProviderError(AI_ERROR_CODES.validation, 'Invalid imageDataUrl format');
    }
    if (!isAllowedImageMime(parsed.mimeType)) {
      throw new VisionProviderError(
        AI_ERROR_CODES.validation,
        `Unsupported image format: ${parsed.mimeType}. Supported: JPEG, PNG, GIF, WebP.`
      );
    }

    const approxBytes = Math.ceil((parsed.base64.length * 3) / 4);
    if (approxBytes > config.maxImageBytes) {
      throw new VisionProviderError(
        AI_ERROR_CODES.validation,
        `Image too large (${Math.round(approxBytes / 1024 / 1024)}MB). Max: ${Math.round(config.maxImageBytes / 1024 / 1024)}MB.`
      );
    }

    return imageInput.dataUrl;
  }

  const imageUrl = String(imageInput.imageUrl || '').trim();
  if (!/^https?:\/\//i.test(imageUrl)) {
    throw new VisionProviderError(
      AI_ERROR_CODES.validation,
      'imageUrl must be a public HTTP(S) URL. Use imageDataUrl for local images.'
    );
  }

  return imageUrl;
}

async function callGlmVision(promptText, imageInput, config) {
  const imageSource = normalizeImageInput(imageInput, config);
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), config.timeoutMs);

  try {
    const response = await fetch(endpointForConfig(config), {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: config.model,
        temperature: 0.1,
        max_tokens: 700,
        messages: [
          {
            role: 'system',
            content: 'You are a careful vision assistant. Reply with one valid JSON object only.',
          },
          {
            role: 'user',
            content: [
              { type: 'image_url', image_url: { url: imageSource } },
              { type: 'text', text: promptText },
            ],
          },
        ],
      }),
      signal: controller.signal,
    });

    const body = await response.json().catch(() => ({}));

    if (!response.ok) {
      const providerMessage =
        body?.error?.message ||
        body?.message ||
        `GLM Vision API responded with status ${response.status}`;
      throw new VisionProviderError(
        AI_ERROR_CODES.providerUnavailable,
        providerMessage,
        { cause: new Error(providerMessage) }
      );
    }

    const content = body?.choices?.[0]?.message?.content;
    if (!content) {
      throw new VisionProviderError(AI_ERROR_CODES.invalidResponse, 'GLM Vision returned an empty response.');
    }

    return content;
  } catch (error) {
    if (error instanceof VisionProviderError) {
      throw error;
    }

    const isTimeout = error?.name === 'AbortError';
    throw new VisionProviderError(
      AI_ERROR_CODES.providerUnavailable,
      isTimeout
        ? `GLM Vision request timed out after ${config.timeoutMs}ms`
        : 'GLM Vision is temporarily unavailable. You can still save manually.',
      { cause: isTimeout ? new Error(`Timeout after ${config.timeoutMs}ms`) : error }
    );
  } finally {
    clearTimeout(timer);
  }
}

async function analyzeImage(promptText, imageInput, validate) {
  if (typeof promptText !== 'string' || promptText.trim().length === 0) {
    throw new VisionProviderError(AI_ERROR_CODES.validation, 'prompt is required');
  }
  if (typeof validate !== 'function') {
    throw new VisionProviderError(AI_ERROR_CODES.validation, 'validate function is required');
  }

  const config = getVisionConfig();

  if (config.provider !== 'glm') {
    throw new VisionProviderError(AI_ERROR_CODES.providerUnavailable, 'VISION_PROVIDER is not set to glm');
  }
  if (!config.apiKey) {
    throw new VisionProviderError(AI_ERROR_CODES.providerUnavailable, 'GLM Vision API key is not configured.');
  }

  try {
    const rawText = await callGlmVision(promptText, imageInput, config);
    const parsed = parseModelJson(rawText);
    if (!validate(parsed)) {
      throw new VisionProviderError(AI_ERROR_CODES.invalidResponse, 'GLM Vision returned an invalid response format.');
    }
    return parsed;
  } catch (error) {
    if (error instanceof AiProviderError) {
      throw new VisionProviderError(error.code, error.message, { cause: error.cause });
    }
    throw error;
  }
}

module.exports = {
  VisionProviderError,
  getVisionConfig,
  analyzeImage,
  parseDataUrl,
  isAllowedImageMime,
};
