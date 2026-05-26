const { COLLECTION_CATEGORIES, normalizeStoryStyle } = require('./ai.schemas');

const STORY_STYLE_HINTS = {
  concise: 'Concise: short sentences, restrained tone, around 100–120 characters, minimal metaphor.',
  scrapbook: 'Scrapbook: casual notes in the margin of a personal journal, light temporal feel like "today" or "later".',
  travel: 'Travel Journal: emphasizes journey, scenery and encounters, stronger sense of place and light.',
  vintage: 'Vintage: slightly old-world and aged, unhurried and gentle tone, not dramatic.',
};

function valueOrEmpty(value) {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : 'Not provided';
}

function buildTitlePrompt(input = {}) {
  return `You are an AI assistant for Collection Journey App. Generate 3 English title suggestions for this collectible.

Rules:
1. Each title must be 40 characters or fewer.
2. Titles should be warm and personal, but not exaggerated.
3. Do not fabricate facts, brands, places, people or events that the user has not provided.
4. If information is insufficient, use more neutral titles.
5. Output JSON only, no Markdown or explanatory text.

User input:
- Category: ${valueOrEmpty(input.category)}
- Location: ${valueOrEmpty(input.location)}
- Date: ${valueOrEmpty(input.dateAcquired)}
- Description: ${valueOrEmpty(input.description)}

Output exactly in this JSON format:
{
  "suggestions": ["Title1", "Title2", "Title3"]
}`;
}

function buildCategoryPrompt(input = {}) {
  return `You are a category assistant for Collection Journey App. From the fixed category list below, select the most appropriate one.

Fixed categories (must be exactly one of):
${JSON.stringify(COLLECTION_CATEGORIES)}

Rules:
1. Category must be strictly from the fixed list.
2. Confidence is a number between 0 and 1 indicating your certainty.
3. If information is insufficient or unclear, select "Other Collections" with confidence no higher than 0.5.
4. Do not output any name outside the fixed list.
5. Output JSON only, no Markdown or explanatory text.

User input:
- Title: ${valueOrEmpty(input.title)}
- Description: ${valueOrEmpty(input.description)}
- Location: ${valueOrEmpty(input.location)}
- Image description: ${valueOrEmpty(input.imageDescription)}

Output exactly in this JSON format:
{
  "category": "Postcards",
  "confidence": 0.82
}`;
}

function buildTagsPrompt(input = {}) {
  return `You are a tag assistant for Collection Journey App. Generate 3 to 8 short English tags for this collectible.

Rules:
1. Each tag should be short, 2 to 8 characters recommended.
2. Tags must not be duplicated.
3. Do not output overly generic tags like "collection", "item", or "record".
4. Try to include place, category, mood, theme or usage context.
5. If information is insufficient, still return at least 3 conservative tags.
6. Output JSON only, no Markdown or explanatory text.

User input:
- Title: ${valueOrEmpty(input.title)}
- Category: ${valueOrEmpty(input.category)}
- Location: ${valueOrEmpty(input.location)}
- Description: ${valueOrEmpty(input.description)}

Output exactly in this JSON format:
{
  "tags": ["Tokyo", "Postcards", "Travel", "Bookshop"]
}`;
}

function buildStoryPrompt(input = {}) {
  const style = normalizeStoryStyle(input.style);
  const styleHint = STORY_STYLE_HINTS[style] || STORY_STYLE_HINTS.concise;

  return `You are a story assistant for Collection Journey App. Generate a draft of 100 to 150 characters of a personal story for this collectible.

Writing style (must follow):
- Style code: ${style}
- ${styleHint}

Rules:
1. Tone should be warm, natural and personal.
2. Do not fabricate specific facts, people, brands or events the user has not provided.
3. If information is insufficient, write more conservatively around "the meaning of keeping this item".
4. Text should be easy for the user to continue editing; do not write advertising copy.
5. Output JSON only, no Markdown or explanatory text.

User input:
- Title: ${valueOrEmpty(input.title)}
- Category: ${valueOrEmpty(input.category)}
- Location: ${valueOrEmpty(input.location)}
- Date: ${valueOrEmpty(input.dateAcquired)}
- Description: ${valueOrEmpty(input.description)}
- Image description: ${valueOrEmpty(input.imageDescription)}

Output exactly in this JSON format:
{
  "story": "Generated story text"
}`;
}

function buildAnalyzeImagePrompt(input = {}) {
  return `You are an image recognition assistant for Collection Journey App. Based on the image information, determine the likely category and provide title, category, tags and short description suggestions.

Fixed categories (must be exactly one of):
${JSON.stringify(COLLECTION_CATEGORIES)}

Rules:
1. suggestedCategory must be strictly from the fixed list.
2. suggestedTags: output 3 to 8 English tags, no duplicates.
3. suggestedTitle: 40 characters or fewer, warm and editable.
4. description: 1 to 2 sentences describing "what it looks like", not a full story.
5. Do not fabricate specific facts, brands, people, places or events not visible in the image.
6. Output JSON only, no Markdown or explanatory text.

Image information:
- Image description: ${valueOrEmpty(input.imageDescription)}
- Image URL: ${valueOrEmpty(input.imageUrl)}

Output exactly in this JSON format:
{
  "suggestedTitle": "Vintage Exhibition Ticket",
  "suggestedCategory": "Tickets",
  "suggestedTags": ["Exhibition", "Ticket", "Vintage"],
  "description": "This looks like an exhibition or event ticket."
}`;
}

module.exports = {
  buildTitlePrompt,
  buildCategoryPrompt,
  buildTagsPrompt,
  buildStoryPrompt,
  buildAnalyzeImagePrompt,
};