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
  category: '明信片',
  location: '东京',
  dateAcquired: '2026-05-01',
  description: '在一家小书店买到的蓝色明信片',
};

console.log('\n成员 E — 阶段一·任务一：标题生成 Prompt 自检\n');

// 1. Prompt builder
const prompt = aiPrompts.buildTitlePrompt(sampleInput);
assert(typeof prompt === 'string' && prompt.length > 100, 'buildTitlePrompt 返回非空字符串');
assert(prompt.includes('3 个中文标题建议'), 'Prompt 要求生成 3 个标题');
assert(prompt.includes('不超过 20 个中文字符'), 'Prompt 包含 20 字长度限制');
assert(prompt.includes('不要编造'), 'Prompt 包含禁止编造规则');
assert(prompt.includes('"suggestions"'), 'Prompt 固定 suggestions JSON 字段');
assert(prompt.includes(sampleInput.description), 'Prompt 注入用户描述');
assert(prompt.includes(sampleInput.location), 'Prompt 注入地点');

// 2. 必填字段校验（供阶段二接口复用）
assert(aiSchemas.hasRequiredDescription({ description: '  有内容  ' }), 'description 非空时通过校验');
assert(!aiSchemas.hasRequiredDescription({ description: '' }), 'description 为空时校验失败');
assert(!aiSchemas.hasRequiredDescription({}), '缺少 description 时校验失败');

// 3. 响应结构校验
const validResponse = {
  suggestions: ['东京蓝色明信片', '小书店的蓝色记忆', '那张蓝色明信片'],
};
assert(aiSchemas.validateTitleResponse(validResponse), '合法 3 条标题响应通过校验');

const badCount = { suggestions: ['仅一条'] };
assert(!aiSchemas.validateTitleResponse(badCount), '标题数量不为 3 时校验失败');

const tooLong = {
  suggestions: ['一二三四五六七八九十一二三四五六七八九十一', '标题二', '标题三'],
};
assert(!aiSchemas.validateTitleResponse(tooLong), '单条标题超过 20 字时校验失败');

const emptyItem = { suggestions: ['', '标题二', '标题三'] };
assert(!aiSchemas.validateTitleResponse(emptyItem), '空字符串标题时校验失败');

// 4. API 端点常量（任务五合同，任务一输出格式与之对齐）
assert(
  aiSchemas.AI_ENDPOINTS.suggestTitle === 'POST /api/ai/suggest-title',
  'AI_ENDPOINTS 已登记 suggest-title 路径'
);

console.log(`\n结果：${passed} 通过，${failed} 失败\n`);
process.exit(failed > 0 ? 1 : 0);
