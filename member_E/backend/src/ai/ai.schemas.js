const COLLECTION_CATEGORIES = [
  '矿石',
  '水晶',
  '黑胶唱片',
  '明信片',
  '票根',
  '旅行纪念品',
  '其他',
];

const AI_ENDPOINTS = {
  suggestTitle: 'POST /api/ai/suggest-title',
  suggestCategory: 'POST /api/ai/suggest-category',
  suggestTags: 'POST /api/ai/suggest-tags',
  generateStory: 'POST /api/ai/generate-story',
};

const AI_ERROR_CODES = {
  validation: 'AI_VALIDATION_ERROR',
  providerUnavailable: 'AI_PROVIDER_UNAVAILABLE',
  invalidResponse: 'AI_INVALID_RESPONSE',
};

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function hasRequiredDescription(payload) {
  return isPlainObject(payload) && typeof payload.description === 'string' && payload.description.trim().length > 0;
}

function validateTitleResponse(response) {
  return (
    isPlainObject(response) &&
    Array.isArray(response.suggestions) &&
    response.suggestions.length === 3 &&
    response.suggestions.every((item) => typeof item === 'string' && item.trim().length > 0 && item.length <= 20)
  );
}

function validateCategoryResponse(response) {
  return (
    isPlainObject(response) &&
    COLLECTION_CATEGORIES.includes(response.category) &&
    typeof response.confidence === 'number' &&
    response.confidence >= 0 &&
    response.confidence <= 1
  );
}

function validateTagsResponse(response) {
  if (!isPlainObject(response) || !Array.isArray(response.tags)) {
    return false;
  }

  const uniqueTags = new Set(response.tags);

  return (
    response.tags.length >= 3 &&
    response.tags.length <= 8 &&
    uniqueTags.size === response.tags.length &&
    response.tags.every((item) => typeof item === 'string' && item.trim().length > 0)
  );
}

function validateStoryResponse(response) {
  return isPlainObject(response) && typeof response.story === 'string' && response.story.trim().length > 0;
}

module.exports = {
  COLLECTION_CATEGORIES,
  AI_ENDPOINTS,
  AI_ERROR_CODES,
  hasRequiredDescription,
  validateTitleResponse,
  validateCategoryResponse,
  validateTagsResponse,
  validateStoryResponse,
};
