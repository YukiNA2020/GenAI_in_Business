/**
 * 成员 E — 阶段二·任务 2–4 自检
 * 1) 直接测试 ai.service（无需启动服务器）
 * 2) 若 backend 在运行，则 HTTP 探测四个端点
 *
 * 运行：node member_E/scripts/verify_phase2_tasks2_4_api.js
 * 可选：BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase2_tasks2_4_api.js
 */

const path = require('path');
const http = require('http');
const https = require('https');

const aiService = require(path.join(__dirname, '../backend/src/ai/ai.service.js'));
const aiSchemas = require(path.join(__dirname, '../backend/src/ai/ai.schemas.js'));

const sampleBody = {
  category: '明信片',
  location: '东京',
  dateAcquired: '2026-05-01',
  description: '在一家小书店买到的蓝色明信片',
};

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

async function runServiceTests() {
  console.log('\n[1] ai.service 层（mock）\n');

  const title = await aiService.suggestTitle(sampleBody);
  assert(aiSchemas.validateTitleResponse(title), 'suggestTitle 返回合法结构');

  const category = await aiService.suggestCategory({
    ...sampleBody,
    title: '东京蓝色明信片',
    imageDescription: '蓝色调明信片',
  });
  assert(aiSchemas.validateCategoryResponse(category), 'suggestCategory 返回合法结构');

  const tags = await aiService.suggestTags({ ...sampleBody, title: '东京蓝色明信片' });
  assert(aiSchemas.validateTagsResponse(tags), 'suggestTags 返回合法结构');

  const story = await aiService.generateStory({ ...sampleBody, title: '东京蓝色明信片' });
  assert(aiSchemas.validateStoryResponse(story), 'generateStory 返回合法结构');

  try {
    await aiService.suggestTitle({ description: '' });
    assert(false, '空 description 应失败');
  } catch (error) {
    assert(error.code === aiSchemas.AI_ERROR_CODES.validation, '空 description 返回 AI_VALIDATION_ERROR');
  }
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

  const routes = [
    ['/api/ai/suggest-title', 'suggestions'],
    ['/api/ai/suggest-category', 'category'],
    ['/api/ai/suggest-tags', 'tags'],
    ['/api/ai/generate-story', 'story'],
  ];

  for (const [route, key] of routes) {
    const { status, json } = await httpRequest(baseUrl, route, sampleBody);
    assert(status === 200 && json.success === true, `${route} 返回 200 success`);
    assert(json.data && key in json.data, `${route} data 含 ${key}`);
  }

  const bad = await httpRequest(baseUrl, '/api/ai/suggest-title', { description: '' });
  assert(bad.status === 400 && bad.json.error?.code === 'AI_VALIDATION_ERROR', 'HTTP 缺 description 返回 400');
}

async function main() {
  console.log('\n成员 E — 阶段二·任务 2–4：AI HTTP 接口自检\n');

  await runServiceTests();

  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  try {
    await runHttpTests(baseUrl);
  } catch (error) {
    console.log(`\n  ⚠ HTTP 探测跳过（${error.code || error.message}）。请先启动 backend：`);
    console.log('     cd backend && npm run dev');
    console.log('     然后：BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase2_tasks2_4_api.js\n');
  }

  console.log(`\n结果：${passed} 通过，${failed} 失败\n`);
  process.exit(failed > 0 ? 1 : 0);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
