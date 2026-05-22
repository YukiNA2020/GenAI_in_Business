const COLLECTION_CATEGORIES = [
  'Minerals',
  'Crystals',
  'Vinyl Records',
  'Postcards',
  'Tickets',
  'Travel Souvenirs',
  'Stamps',
  'Other Collections',
];

const STORY_STYLES = ['concise', 'scrapbook', 'travel', 'vintage'];

const AI_ENDPOINTS = {
  suggestTitle: 'POST /api/ai/suggest-title',
  suggestCategory: 'POST /api/ai/suggest-category',
  suggestTags: 'POST /api/ai/suggest-tags',
  generateStory: 'POST /api/ai/generate-story',
  analyzeImage: 'POST /api/ai/analyze-image',
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

function hasImageAnalysisInput(payload) {
  if (!isPlainObject(payload)) {
    return false;
  }
  const desc =
    typeof payload.imageDescription === 'string' && payload.imageDescription.trim().length > 0;
  const url = typeof payload.imageUrl === 'string' && payload.imageUrl.trim().length > 0;
  return desc || url;
}

function normalizeStoryStyle(style) {
  if (typeof style !== 'string') {
    return 'concise';
  }
  const normalized = style.trim().toLowerCase();
  return STORY_STYLES.includes(normalized) ? normalized : 'concise';
}

function validateTitleResponse(response) {
  return (
    isPlainObject(response) &&
    Array.isArray(response.suggestions) &&
    response.suggestions.length === 3 &&
    response.suggestions.every(
      (item) => typeof item === 'string' && item.trim().length > 0 && item.length <= 80
    )
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

function validateAnalyzeImageResponse(response) {
  if (!isPlainObject(response)) {
    return false;
  }
  const uniqueTags = new Set(response.suggestedTags);
  return (
    typeof response.suggestedTitle === 'string' &&
    response.suggestedTitle.trim().length > 0 &&
    response.suggestedTitle.length <= 80 &&
    COLLECTION_CATEGORIES.includes(response.suggestedCategory) &&
    Array.isArray(response.suggestedTags) &&
    response.suggestedTags.length >= 3 &&
    response.suggestedTags.length <= 8 &&
    uniqueTags.size === response.suggestedTags.length &&
    response.suggestedTags.every((item) => typeof item === 'string' && item.trim().length > 0) &&
    typeof response.description === 'string' &&
    response.description.trim().length > 0
  );
}

module.exports = {
  COLLECTION_CATEGORIES,
  STORY_STYLES,
  AI_ENDPOINTS,
  AI_ERROR_CODES,
  hasRequiredDescription,
  hasImageAnalysisInput,
  normalizeStoryStyle,
  validateTitleResponse,
  validateCategoryResponse,
  validateTagsResponse,
  validateStoryResponse,
  validateAnalyzeImageResponse,
};
