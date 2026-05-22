const { COLLECTION_CATEGORIES, normalizeStoryStyle } = require('./ai.schemas');

const STORY_STYLE_HINTS = {
  concise: 'Concise: short sentences, restrained tone, about 80–120 words.',
  scrapbook: 'Scrapbook: like a margin note in a journal; gentle time markers such as "today" or "later".',
  travel: 'Travel diary: emphasize route, place, and first encounter; light and place matter.',
  vintage: 'Vintage: quiet nostalgia, unhurried tone, no exaggeration.',
};

function valueOrEmpty(value) {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : 'not provided';
}

function buildTitlePrompt(input = {}) {
  return `You are the AI assistant for Collection Journey App. Generate 3 English title suggestions for this collectible.

Rules:
1. Each title must be 80 characters or fewer.
2. Warm and personal, but not dramatic.
3. Do not invent facts, brands, places, people, or events the user did not provide.
4. If information is sparse, use neutral titles.
5. Output JSON only—no Markdown or explanation.

User input:
- Category: ${valueOrEmpty(input.category)}
- Location: ${valueOrEmpty(input.location)}
- Date acquired: ${valueOrEmpty(input.dateAcquired)}
- Description: ${valueOrEmpty(input.description)}

Output format:
{
  "suggestions": ["Title 1", "Title 2", "Title 3"]
}`;
}

function buildCategoryPrompt(input = {}) {
  return `You are the collection category assistant for Collection Journey App. Pick the best category from the fixed list.

Fixed categories only:
${JSON.stringify(COLLECTION_CATEGORIES)}

Rules:
1. category must be exactly one value from the fixed list.
2. confidence is a decimal from 0 to 1.
3. If unsure, choose "Other Collections" with confidence no higher than 0.5.
4. Do not output names outside the list.
5. Output JSON only.

User input:
- Title: ${valueOrEmpty(input.title)}
- Description: ${valueOrEmpty(input.description)}
- Location: ${valueOrEmpty(input.location)}
- Image description: ${valueOrEmpty(input.imageDescription)}

Output format:
{
  "category": "Postcards",
  "confidence": 0.82
}`;
}

function buildTagsPrompt(input = {}) {
  return `You are the collection tags assistant for Collection Journey App. Generate 3 to 8 English tags.

Rules:
1. Keep tags short (about 2–24 characters).
2. No duplicates.
3. Avoid overly generic tags such as "collection", "item", or "record".
4. Prefer place, category, mood, theme, or use case when possible.
5. Return at least 3 conservative tags even if input is sparse.
6. Output JSON only.

User input:
- Title: ${valueOrEmpty(input.title)}
- Category: ${valueOrEmpty(input.category)}
- Location: ${valueOrEmpty(input.location)}
- Description: ${valueOrEmpty(input.description)}

Output format:
{
  "tags": ["Tokyo", "postcard", "travel", "bookshop"]
}`;
}

function buildStoryPrompt(input = {}) {
  const style = normalizeStoryStyle(input.style);
  const styleHint = STORY_STYLE_HINTS[style] || STORY_STYLE_HINTS.concise;

  return `You are the collection story assistant for Collection Journey App. Write an English story draft of about 80–150 words.

Style (required):
- Style code: ${style}
- ${styleHint}

Rules:
1. Warm, natural, personal tone.
2. Do not invent specific facts, people, brands, or events the user did not provide.
3. If information is sparse, write conservatively about why keeping this piece matters.
4. Easy for the user to edit; not ad copy.
5. Output JSON only.

User input:
- Title: ${valueOrEmpty(input.title)}
- Category: ${valueOrEmpty(input.category)}
- Location: ${valueOrEmpty(input.location)}
- Date acquired: ${valueOrEmpty(input.dateAcquired)}
- Description: ${valueOrEmpty(input.description)}
- Image description: ${valueOrEmpty(input.imageDescription)}

Output format:
{
  "story": "Story text here"
}`;
}

function buildAnalyzeImagePrompt(input = {}) {
  return `You are the collectible image recognition assistant for Collection Journey App. Suggest title, category, tags, and a short description from the image information.

Fixed categories only:
${JSON.stringify(COLLECTION_CATEGORIES)}

Rules:
1. suggestedCategory must be from the fixed list.
2. suggestedTags: 3 to 8 unique English tags.
3. suggestedTitle: 80 characters or fewer, warm and editable.
4. description: 1–2 sentences on what it appears to be—not a full story.
5. Do not invent details not visible in the image.
6. Output JSON only.

Image info:
- Image description: ${valueOrEmpty(input.imageDescription)}
- Image URL: ${valueOrEmpty(input.imageUrl)}

Output format:
{
  "suggestedTitle": "Vintage exhibition ticket",
  "suggestedCategory": "Tickets",
  "suggestedTags": ["exhibition", "ticket", "vintage"],
  "description": "This looks like a printed event or exhibition ticket."
}`;
}

module.exports = {
  buildTitlePrompt,
  buildCategoryPrompt,
  buildTagsPrompt,
  buildStoryPrompt,
  buildAnalyzeImagePrompt,
};
