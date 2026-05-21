/**
 * 成员 E — 阶段二·任务一自检脚本
 * 验证 AI Provider 封装（mock / 错误处理 / JSON 解析），不调用真实 OpenAI。
 *
 * 运行：node member_E/scripts/verify_phase2_task1_provider.js
 */

const path = require('path');

const aiPrompts = require(path.join(__dirname, '../backend/src/ai/ai.prompts.js'));
const aiSchemas = require(path.join(__dirname, '../backend/src/ai/ai.schemas.js'));
const aiProvider = require(path.join(__dirname, '../backend/src/ai/ai.provider.js'));

let passed = 0;
let failed = 0;

const originalEnv = { ...process.env };

function assert(condition, message) {
  if (condition) {
    passed += 1;
    console.log(`  ✓ ${message}`);
  } else {
    failed += 1;
    console.error(`  ✗ ${message}`);
  }
}

async function expectError(fn, expectedCode, label) {
  try {
    await fn();
    assert(false, `${label} 应抛出错误`);
  } catch (error) {
    assert(error instanceof aiProvider.AiProviderError, `${label} 抛出 AiProviderError`);
    assert(error.code === expectedCode, `${label} 错误码为 ${expectedCode}`);
  }
}

function restoreEnv() {
  process.env = { ...originalEnv };
}

console.log('\n成员 E — 阶段二·任务一：AI Provider 封装自检\n');

restoreEnv();
process.env.AI_PROVIDER = 'mock';
delete process.env.OPENAI_API_KEY;
delete process.env.AI_API_KEY;

assert(aiProvider.resolveProviderMode(aiProvider.getConfig()) === 'mock', '无 API Key 时 auto 模式解析为 mock');

(async () => {
  const titlePrompt = aiPrompts.buildTitlePrompt({
    category: '明信片',
    location: '东京',
    dateAcquired: '2026-05-01',
    description: '在一家小书店买到的蓝色明信片',
  });
  const titleData = await aiProvider.generateJson(titlePrompt, {
    validate: aiSchemas.validateTitleResponse,
    mockKind: 'title',
  });
  assert(aiSchemas.validateTitleResponse(titleData), 'mock 模式生成标题 JSON 并通过校验');

  const categoryPrompt = aiPrompts.buildCategoryPrompt({ description: '黑胶唱片封面很复古' });
  const categoryData = await aiProvider.generateJson(categoryPrompt, {
    validate: aiSchemas.validateCategoryResponse,
    mockKind: 'category',
  });
  assert(aiSchemas.validateCategoryResponse(categoryData), 'mock 模式生成分类 JSON');

  const tagsPrompt = aiPrompts.buildTagsPrompt({ description: '旅行纪念品' });
  const tagsData = await aiProvider.generateJson(tagsPrompt, {
    validate: aiSchemas.validateTagsResponse,
    mockKind: 'tags',
  });
  assert(aiSchemas.validateTagsResponse(tagsData), 'mock 模式生成标签 JSON');

  const storyPrompt = aiPrompts.buildStoryPrompt({ description: '想留住那次旅行的记忆' });
  const storyData = await aiProvider.generateJson(storyPrompt, {
    validate: aiSchemas.validateStoryResponse,
    mockKind: 'story',
  });
  assert(aiSchemas.validateStoryResponse(storyData), 'mock 模式生成故事 JSON');

  const fenced = aiProvider.parseModelJson('```json\n{"suggestions":["A","B","C"]}\n```');
  assert(
    Array.isArray(fenced.suggestions) && fenced.suggestions.length === 3,
    'parseModelJson 可解析 Markdown 代码块中的 JSON'
  );

  await expectError(
    () =>
      aiProvider.generateJson(titlePrompt, {
        validate: () => false,
        mockKind: 'title',
      }),
    aiSchemas.AI_ERROR_CODES.invalidResponse,
    '校验失败'
  );

  restoreEnv();
  process.env.AI_PROVIDER = 'openai';
  delete process.env.OPENAI_API_KEY;
  delete process.env.AI_API_KEY;
  assert(
    aiProvider.resolveProviderMode(aiProvider.getConfig()) === 'unavailable',
    'AI_PROVIDER=openai 且无 Key 时标记为 unavailable'
  );

  await expectError(
    () =>
      aiProvider.generateJson(titlePrompt, {
        validate: aiSchemas.validateTitleResponse,
      }),
    aiSchemas.AI_ERROR_CODES.providerUnavailable,
    'openai 模式无 Key'
  );

  restoreEnv();
  console.log(`\n结果：${passed} 通过，${failed} 失败\n`);
  process.exit(failed > 0 ? 1 : 0);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
