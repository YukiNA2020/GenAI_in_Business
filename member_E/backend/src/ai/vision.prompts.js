const { COLLECTION_CATEGORIES } = require('./ai.schemas');

function buildVisionAnalyzePrompt(input = {}) {
  const language = input.language || 'en-US';
  const imageDescription =
    typeof input.imageDescription === 'string' && input.imageDescription.trim().length > 0
      ? input.imageDescription.trim()
      : 'Not provided';
  const imageUrl =
    typeof input.imageUrl === 'string' && input.imageUrl.trim().length > 0
      ? input.imageUrl.trim()
      : 'Not provided';

  return `You are an image recognition assistant for Collection Journey App.

Please observe the image carefully, select the most matching category from the fixed list, and generate title, tags and description.

## Fixed categories (must select exactly one)
${JSON.stringify(COLLECTION_CATEGORIES)}

## Rules
1. suggestedCategory must be strictly from the fixed list above.
2. suggestedTags: output 3 to 8 English tags, no duplicates.
3. suggestedTitle: 40 characters or fewer, warm and editable.
4. description: 1 to 2 sentences describing "what it looks like", not a full story.
5. Do not fabricate specific brands, people, places or events not visible in the image.
6. Output only one JSON object, no explanations or Markdown.
7. Language: ${language}

## Image information (for reference)
- User补充 description: ${imageDescription}
- Image URL: ${imageUrl}

Output JSON directly:
{
  "suggestedTitle": "...",
  "suggestedCategory": "...",
  "suggestedTags": ["...", "..."],
  "description": "..."
}`;
}

module.exports = { buildVisionAnalyzePrompt };