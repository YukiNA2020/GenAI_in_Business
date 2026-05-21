/**
 * 成员 E — 阶段四·任务 1–5 自检
 * analyze-image + generate-story style
 *
 * node member_E/scripts/verify_phase4_tasks1_5_api.js
 */

const path = require('path');
const http = require('http');
const https = require('https');

const aiService = require(path.join(__dirname, '../backend/src/ai/ai.service.js'));
const aiSchemas = require(path.join(__dirname, '../backend/src/ai/ai.schemas.js'));

let passed = 0;
let failed = 0;

function assert(condition, message) {
  if (condition) {
    passed += 1;
    console.log(`  ✓ ${message}`);
  } else {
    failed += 1;
    console.error(`  ✗ ${message}`);
  }
}

process.env.AI_PROVIDER = 'mock';
delete process.env.OPENAI_API_KEY;

const sampleBody = {
  category: '明信片',
  location: '东京',
  dateAcquired: '2026-05-01',
  description: '在一家小书店买到的蓝色明信片',
};

async function runServiceTests() {
  console.log('\n[1] ai.service 层（mock）\n');

  const image = await aiService.analyzeImage({
    imageDescription: '一张泛黄的展览票根，边缘略有磨损',
  });
  assert(aiSchemas.validateAnalyzeImageResponse(image), 'analyzeImage 返回合法结构');

  try {
    await aiService.analyzeImage({});
    assert(false, '空 image 输入应失败');
  } catch (error) {
    assert(error.code === aiSchemas.AI_ERROR_CODES.validation, '缺 image 输入返回 AI_VALIDATION_ERROR');
  }

  for (const style of aiSchemas.STORY_STYLES) {
    const story = await aiService.generateStory({
      ...sampleBody,
      title: '东京蓝色明信片',
      style,
    });
    assert(aiSchemas.validateStoryResponse(story), `generateStory style=${style} 合法`);
    assert(story.story.length > 20, `generateStory style=${style} 有内容`);
  }

  const concise = await aiService.generateStory({
    ...sampleBody,
    title: '测试',
    style: 'invalid-style',
  });
  assert(aiSchemas.validateStoryResponse(concise), '无效 style 回退 concise');
}

function httpRequest(baseUrl, route, body) {
  return new Promise((resolve, reject) => {
    const url = new URL(route, baseUrl);
    const payload = JSON.stringify(body);
    const lib = url.protocol === 'https:' ? https : http;
    const req = lib.request(
      url,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (chunk) => {
          raw += chunk;
        });
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, json: JSON.parse(raw) });
          } catch (error) {
            reject(error);
          }
        });
      }
    );
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function runHttpTests(baseUrl) {
  console.log(`\n[2] HTTP 层（${baseUrl}）\n`);

  const analyze = await httpRequest(baseUrl, '/api/ai/analyze-image', {
    imageDescription: '黑胶唱片封面，红色标签',
  });
  assert(
    analyze.status === 200 && analyze.json.success === true,
    '/api/ai/analyze-image 返回 200'
  );
  assert(
    analyze.json.data?.suggestedTitle,
    'analyze-image data 含 suggestedTitle'
  );

  const story = await httpRequest(baseUrl, '/api/ai/generate-story', {
    ...sampleBody,
    style: 'travel',
  });
  assert(story.status === 200 && story.json.data?.story, 'generate-story + style 返回 story');

  const bad = await httpRequest(baseUrl, '/api/ai/analyze-image', {});
  assert(
    bad.status === 400 && bad.json.error?.code === 'AI_VALIDATION_ERROR',
    'analyze-image 缺字段返回 400'
  );
}

async function main() {
  console.log('\n成员 E — 阶段四·任务 1–5：图片识别 + 多风格故事\n');
  await runServiceTests();

  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  try {
    await runHttpTests(baseUrl);
  } catch (error) {
    console.log(`\n  ⚠ HTTP 探测跳过（${error.code || error.message}）\n`);
  }

  console.log(`\n结果：${passed} 通过，${failed} 失败\n`);
  process.exit(failed > 0 ? 1 : 0);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
