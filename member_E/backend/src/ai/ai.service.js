const {
  buildTitlePrompt,
  buildCategoryPrompt,
  buildTagsPrompt,
  buildStoryPrompt,
} = require('./ai.prompts');
const { generateJson, AiProviderError } = require('./ai.provider');
const {
  AI_ERROR_CODES,
  hasRequiredDescription,
  validateTitleResponse,
  validateCategoryResponse,
  validateTagsResponse,
  validateStoryResponse,
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
  const prompt = buildStoryPrompt(payload);
  return generateJson(prompt, {
    validate: validateStoryResponse,
    mockKind: 'story',
  });
}

module.exports = {
  suggestTitle,
  suggestCategory,
  suggestTags,
  generateStory,
};
