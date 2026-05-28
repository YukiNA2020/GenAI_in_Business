const {
  buildTitlePrompt,
  buildCategoryPrompt,
  buildTagsPrompt,
  buildStoryPrompt,
  buildAnalyzeImagePrompt,
  buildRoomReflectionPrompt,
} = require('./ai.prompts');
const { buildVisionAnalyzePrompt } = require('./vision.prompts');
const { generateJson, AiProviderError } = require('./ai.provider');
const { analyzeImage: runVision, VisionProviderError } = require('./vision.provider');
const {
  AI_ERROR_CODES,
  hasRequiredDescription,
  hasImageAnalysisInput,
  normalizeStoryStyle,
  validateTitleResponse,
  validateCategoryResponse,
  validateTagsResponse,
  validateStoryResponse,
  validateAnalyzeImageResponse,
  validateRoomReflectionResponse,
} = require('./ai.schemas');

function ensureDescription(input) {
  if (!hasRequiredDescription(input)) {
    throw new AiProviderError(AI_ERROR_CODES.validation, 'description is required');
  }
  return input;
}

async function suggestTitle(input) {
  const payload = ensureDescription(input);
  const prompt = buildTitlePrompt(payload);
  return generateJson(prompt, {
    validate: validateTitleResponse,
    mockKind: 'title',
  });
}

async function suggestCategory(input) {
  const payload = ensureDescription(input);
  const prompt = buildCategoryPrompt(payload);
  return generateJson(prompt, {
    validate: validateCategoryResponse,
    mockKind: 'category',
  });
}

async function suggestTags(input) {
  const payload = ensureDescription(input);
  const prompt = buildTagsPrompt(payload);
  return generateJson(prompt, {
    validate: validateTagsResponse,
    mockKind: 'tags',
  });
}

async function generateStory(input) {
  const payload = ensureDescription(input);
  const withStyle = { ...payload, style: normalizeStoryStyle(payload.style) };
  const prompt = buildStoryPrompt(withStyle);
  return generateJson(prompt, {
    validate: validateStoryResponse,
    mockKind: 'story',
  });
}

function ensureImageInput(input) {
  if (!hasImageAnalysisInput(input)) {
    throw new AiProviderError(
      AI_ERROR_CODES.validation,
      'imageDescription or imageUrl is required'
    );
  }
  return input;
}

async function analyzeImage(input) {
  const payload = ensureImageInput(input);

  // Check if we have real image data for GLM Vision
  const hasDataUrl =
    typeof payload.imageDataUrl === 'string' && payload.imageDataUrl.trim().length > 0;
  const hasUrl =
    typeof payload.imageUrl === 'string' && payload.imageUrl.trim().length > 0;
  const hasRealImage = hasDataUrl || hasUrl;

  if (hasRealImage) {
    // Try GLM Vision first
    const prompt = buildVisionAnalyzePrompt(payload);
    try {
      const result = await runVision(
        prompt,
        { dataUrl: hasDataUrl ? payload.imageDataUrl : null, imageUrl: hasUrl ? payload.imageUrl : null },
        validateAnalyzeImageResponse
      );
      return result;
    } catch (visionError) {
      if (visionError instanceof VisionProviderError) {
        // Convert VisionProviderError to AiProviderError so routes.js can handle it
        const hasDesc =
          typeof payload.imageDescription === 'string' && payload.imageDescription.trim().length > 0;
        if (hasDesc) {
          // Fallback to text-based analysis using DeepSeek
          const fallbackPrompt = buildAnalyzeImagePrompt({
            imageDescription: payload.imageDescription,
            imageUrl: payload.imageUrl,
            language: payload.language,
          });
          return generateJson(fallbackPrompt, {
            validate: validateAnalyzeImageResponse,
            mockKind: 'analyzeImage',
          });
        }
        // No description to fallback — convert to AiProviderError and re-throw
        throw new AiProviderError(visionError.code, visionError.message, { cause: visionError.cause });
      }
      throw visionError;
    }
  }

  // No real image — use text-based analysis via DeepSeek (existing path)
  const prompt = buildAnalyzeImagePrompt(payload);
  return generateJson(prompt, {
    validate: validateAnalyzeImageResponse,
    mockKind: 'analyzeImage',
  });
}

async function generateRoomReflection(input = {}) {
  const prompt = buildRoomReflectionPrompt(input);
  return generateJson(prompt, {
    validate: validateRoomReflectionResponse,
    mockKind: 'roomReflection',
  });
}

module.exports = {
  suggestTitle,
  suggestCategory,
  suggestTags,
  generateStory,
  analyzeImage,
  generateRoomReflection,
};
