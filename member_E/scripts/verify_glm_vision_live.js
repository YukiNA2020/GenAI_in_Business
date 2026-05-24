/**
 * verify_glm_vision_live.js
 *
 * GLM Vision live test script. Requires a real ZHIPU_API_KEY in backend/.env
 * or the current shell environment. Does not print the API key or full base64.
 *
 * Usage:
 *   node member_E/scripts/verify_glm_vision_live.js [path/to/image.png]
 */

const path = require('path');
const fs = require('fs');

require(path.resolve(__dirname, '..', '..', 'backend', 'node_modules', 'dotenv')).config({
  path: path.resolve(__dirname, '..', '..', 'backend', '.env'),
});

const { analyzeImage, getVisionConfig } = require('../backend/src/ai/vision.provider');
const { buildVisionAnalyzePrompt } = require('../backend/src/ai/vision.prompts');
const { validateAnalyzeImageResponse } = require('../backend/src/ai/ai.schemas');

const CONFIG = getVisionConfig();

function localImageToDataUrl(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Image file not found: ${filePath}`);
  }

  const ext = path.extname(filePath).toLowerCase();
  const mimeMap = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
  };
  const mimeType = mimeMap[ext];
  if (!mimeType) {
    throw new Error(`Unsupported image extension: ${ext}`);
  }

  const raw = fs.readFileSync(filePath);
  return {
    dataUrl: `data:${mimeType};base64,${raw.toString('base64')}`,
    bytes: raw.length,
  };
}

async function main() {
  console.log('=== GLM Vision Live Test ===');
  console.log(`Provider: ${CONFIG.provider}`);
  console.log(`Base URL: ${CONFIG.baseUrl}`);
  console.log(`Model: ${CONFIG.model}`);
  console.log(`API Key configured: ${CONFIG.apiKey ? 'yes' : 'no'}`);

  if (CONFIG.provider !== 'glm') {
    console.error('ERROR: VISION_PROVIDER is not set to "glm".');
    process.exit(1);
  }

  if (!CONFIG.apiKey) {
    console.error('ERROR: ZHIPU_API_KEY is not configured.');
    process.exit(1);
  }

  const imagePath =
    process.argv[2] ||
    path.resolve(__dirname, '..', '..', 'frontend', 'assets', 'screens', 'add_exhibit.png');
  const { dataUrl, bytes } = localImageToDataUrl(imagePath);

  console.log(`Image: ${imagePath}`);
  console.log(`Image size: ${Math.round(bytes / 1024)}KB`);
  console.log('Calling GLM Vision with real image...');

  const prompt = buildVisionAnalyzePrompt({
    language: 'zh-CN',
    imageDescription: '本地 live 测试图片，请识别画面内容并映射到收藏品字段。',
  });

  try {
    const result = await analyzeImage(
      prompt,
      { dataUrl, imageUrl: null },
      validateAnalyzeImageResponse
    );

    console.log('\n--- GLM Vision Result ---');
    console.log(`suggestedTitle: ${result.suggestedTitle}`);
    console.log(`suggestedCategory: ${result.suggestedCategory}`);
    console.log(`suggestedTags: ${JSON.stringify(result.suggestedTags)}`);
    console.log(`description: ${result.description}`);
    console.log('\nValidation: PASSED');
  } catch (error) {
    console.error('\n--- GLM Vision Error ---');
    console.error(`Code: ${error.code || 'UNKNOWN'}`);
    console.error(`Message: ${error.message}`);
    if (error.cause) {
      console.error(`Cause: ${error.cause.message}`);
    }
    console.error('\nValidation: FAILED');
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('Unexpected error:', error);
  process.exit(1);
});
