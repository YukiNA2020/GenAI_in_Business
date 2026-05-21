const {
  buildTitlePrompt,
  buildCategoryPrompt,
  buildTagsPrompt,
  buildStoryPrompt,
  buildAnalyzeImagePrompt,
} = require('./ai.prompts');
const { generateJson, AiProviderError } = require('./ai.provider');
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
  const prompt = buildAnalyzeImagePrompt(payload);
  return generateJson(prompt, {
    validate: validateAnalyzeImageResponse,
    mockKind: 'analyzeImage',
  });
}

module.exports = {
  suggestTitle,
  suggestCategory,
  suggestTags,
  generateStory,
  analyzeImage,
};
