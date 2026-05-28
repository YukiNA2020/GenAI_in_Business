/**
 * verify_deepseek_provider_live.js
 * 成员 E - DeepSeek 真实 LLM 接入验证
 *
 * 执行方式（export 后运行，避免 key 进 shell 历史）：
 *   export AI_API_KEY=your_key_here
 *   AI_PROVIDER=openai \
 *   AI_BASE_URL=https://api.deepseek.com \
 *   AI_MODEL=deepseek-v4-flash \
 *   AI_TIMEOUT_MS=30000 \
 *   node member_E/scripts/verify_deepseek_provider_live.js
 *
 * 或一键（key 会进历史，仅本地快速冒烟）：
 *   AI_PROVIDER=openai \
 *   AI_API_KEY=your_key_here \
 *   AI_BASE_URL=https://api.deepseek.com \
 *   AI_MODEL=deepseek-v4-flash \
 *   AI_TIMEOUT_MS=30000 \
 *   node member_E/scripts/verify_deepseek_provider_live.js
 */

const path = require('path');

// 加载 provider（直接用 member_E/backend/src/ai/）
const provider = require(path.resolve(__dirname, '../backend/src/ai/ai.provider'));
const { buildTitlePrompt, buildCategoryPrompt, buildTagsPrompt, buildStoryPrompt } = require(path.resolve(__dirname, '../backend/src/ai/ai.prompts'));
const schemas = require(path.resolve(__dirname, '../backend/src/ai/ai.schemas'));

const TEST_INPUT = {
  description: '在东京一家安静的小书店买到的蓝色明信片，背面有手写的街区地图。',
  category: '明信片',
  location: '东京',
  dateAcquired: '2026-05-01',
};

const TEST_STORY_STYLES = ['concise', 'travel'];

function green(msg) { console.log('\x1b[32m✓\x1b[0m', msg); }
function red(msg)   { console.log('\x1b[31m✗\x1b[0m', msg); }
function yellow(msg){ console.log('\x1b[33m⚠\x1b[0m', msg); }
function section(label) { console.log('\n--- ' + label + ' ---'); }

async function main() {
  console.log('成员 E — DeepSeek 真实 LLM 接入验证');
  console.log('注意：不要将 API Key 写入测试日志');

  const config = provider.getConfig();
  console.log('\n当前配置：');
  console.log('  Provider:', config.provider);
  console.log('  Base URL:', config.baseUrl);
  console.log('  Model:   ', config.model);
  console.log('  Timeout: ', config.timeoutMs, 'ms');
  console.log('  API Key: ', config.apiKey ? config.apiKey.slice(0, 6) + '***' : '(未设置)');

  const mode = provider.resolveProviderMode(config);
  console.log('  解析模式:', mode);

  if (mode !== 'openai') {
    red('ERROR: 模式不是 openai，请检查 AI_PROVIDER=openai 和 API Key');
    process.exit(1);
  }

  let passed = 0, failed = 0;

  // 1. suggestTitle
  section('测试 suggestTitle');
  try {
    const result = await provider.generateJson(
      buildTitlePrompt(TEST_INPUT),
      { validate: schemas.validateTitleResponse, mockKind: 'title' }
    );
    console.log('  原始返回:', JSON.stringify(result));
    if (Array.isArray(result.suggestions) && result.suggestions.length === 3 &&
        result.suggestions.every(t => typeof t === 'string' && t.trim().length > 0)) {
      green('suggestTitle PASS — 3 个有效标题');
      result.suggestions.forEach((t, i) => console.log(`    [${i+1}] ${t}`));
      passed++;
    } else {
      red('suggestTitle FAIL — 结构不符合预期');
      failed++;
    }
  } catch (err) {
    red('suggestTitle FAIL — ' + err.message);
    if (err.cause) console.log('  原因:', err.cause.message);
    failed++;
  }

  // 2. suggestCategory
  section('测试 suggestCategory');
  try {
    const result = await provider.generateJson(
      buildCategoryPrompt(TEST_INPUT),
      { validate: schemas.validateCategoryResponse, mockKind: 'category' }
    );
    console.log('  原始返回:', JSON.stringify(result));
    if (schemas.COLLECTION_CATEGORIES.includes(result.category)) {
      green(`suggestCategory PASS — category="${result.category}"`);
      passed++;
    } else {
      red(`suggestCategory FAIL — category="${result.category}" 不在集合内`);
      failed++;
    }
  } catch (err) {
    red('suggestCategory FAIL — ' + err.message);
    if (err.cause) console.log('  原因:', err.cause.message);
    failed++;
  }

  // 3. suggestTags
  section('测试 suggestTags');
  try {
    const result = await provider.generateJson(
      buildTagsPrompt(TEST_INPUT),
      { validate: schemas.validateTagsResponse, mockKind: 'tags' }
    );
    console.log('  原始返回:', JSON.stringify(result));
    if (Array.isArray(result.tags) && result.tags.length >= 3 && result.tags.length <= 8 &&
        result.tags.every(t => typeof t === 'string' && t.trim().length > 0)) {
      green(`suggestTags PASS — ${result.tags.length} 个标签: [${result.tags.join(', ')}]`);
      passed++;
    } else {
      red('suggestTags FAIL — 结构不符合预期');
      failed++;
    }
  } catch (err) {
    red('suggestTags FAIL — ' + err.message);
    if (err.cause) console.log('  原因:', err.cause.message);
    failed++;
  }

  // 4. generateStory (concise + travel)
  for (const style of TEST_STORY_STYLES) {
    section(`测试 generateStory (style=${style})`);
    try {
      const inputWithStyle = { ...TEST_INPUT, style };
      const result = await provider.generateJson(
        buildStoryPrompt(inputWithStyle),
        { validate: schemas.validateStoryResponse, mockKind: 'story' }
      );
      console.log('  原始返回:', JSON.stringify(result));
      if (typeof result.story === 'string' && result.story.trim().length > 0) {
        green(`generateStory(${style}) PASS — story 长度 ${result.story.length}`);
        console.log('    story:', result.story.slice(0, 80) + (result.story.length > 80 ? '...' : ''));
        passed++;
      } else {
        red(`generateStory(${style}) FAIL — story 无效`);
        failed++;
      }
    } catch (err) {
      red(`generateStory(${style}) FAIL — ` + err.message);
      if (err.cause) console.log('  原因:', err.cause.message);
      failed++;
    }
  }

  // 结果汇总
  section('结果汇总');
  console.log(`\n  通过: ${passed}  失败: ${failed}`);
  if (failed === 0) {
    green('DeepSeek 真实 LLM 验证全部通过');
  } else {
    red(`DeepSeek 真实 LLM 验证有 ${failed} 项失败`);
  }

  process.exit(failed > 0 ? 1 : 0);
}

main().catch(err => {
  console.error('脚本执行异常:', err.message);
  if (err.cause) console.error('原因:', err.cause.message);
  process.exit(1);
});