/**
 * 成员 E — 阶段一·任务一自检脚本
 * 验证标题 Prompt 文档约定、Prompt builder 与响应结构校验函数。
 * 不调用真实 AI API，不依赖根目录 backend 服务。
 *
 * 运行：node member_E/scripts/verify_phase1_task1_title.js
 */

const path = require('path');

const aiPrompts = require(path.join(__dirname, '../backend/src/ai/ai.prompts.js'));
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

const sampleInput = {
  category: 'Postcards',
  location: 'Tokyo',
  dateAcquired: '2026-05-01',
  description: 'A blue postcard bought at a small bookshop',
};

console.log('\n成员 E — 阶段一·任务一：标题生成 Prompt 自检\n');

// 1. Prompt builder
const prompt = aiPrompts.buildTitlePrompt(sampleInput);
assert(typeof prompt === 'string' && prompt.length > 100, 'buildTitlePrompt returns non-empty string');
assert(prompt.includes('Generate 3 English title suggestions'), 'Prompt requires 3 English titles');
assert(prompt.includes('40 characters') || prompt.includes('40 character'), 'Prompt includes 40 char limit');
assert(prompt.includes('Do not fabricate') || prompt.includes('fabricate'), 'Prompt includes no-fabrication rule');
assert(prompt.includes('"suggestions"'), 'Prompt specifies suggestions JSON field');
assert(prompt.includes(sampleInput.description), 'Prompt injects user description');
assert(prompt.includes(sampleInput.location), 'Prompt injects location');

// 2. 必填字段校验（供阶段二接口复用）
assert(aiSchemas.hasRequiredDescription({ description: '  有内容  ' }), 'description 非空时通过校验');
assert(!aiSchemas.hasRequiredDescription({ description: '' }), 'description 为空时校验失败');
assert(!aiSchemas.hasRequiredDescription({}), '缺少 description 时校验失败');

// 3. Response structure validation
const validResponse = {
  suggestions: ['A Blue Postcard from Tokyo', 'Bookshop Memory', 'That Blue Postcard'],
};
assert(aiSchemas.validateTitleResponse(validResponse), 'Valid 3-title response passes validation');

const badCount = { suggestions: ['Only one'] };
assert(!aiSchemas.validateTitleResponse(badCount), 'Title count not 3 fails validation');

const tooLong = {
  suggestions: ['A very long title that exceeds forty characters limit here', 'Title two', 'Title three'],
};
assert(!aiSchemas.validateTitleResponse(tooLong), 'Single title over 40 chars fails validation');

const emptyItem = { suggestions: ['', 'Title two', 'Title three'] };
assert(!aiSchemas.validateTitleResponse(emptyItem), 'Empty string title fails validation');

// 4. API 端点常量（任务五合同，任务一输出格式与之对齐）
assert(
  aiSchemas.AI_ENDPOINTS.suggestTitle === 'POST /api/ai/suggest-title',
  'AI_ENDPOINTS 已登记 suggest-title 路径'
);

console.log(`\n结果：${passed} 通过，${failed} 失败\n`);
process.exit(failed > 0 ? 1 : 0);
