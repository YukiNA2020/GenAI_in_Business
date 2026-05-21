/**
 * 成员 E — 阶段五·任务 4 全链路 Demo API 自检
 * 模拟：创建 → AI → 保存 → 墙/搜索 → 详情 → 主页统计
 *
 * node member_E/scripts/verify_phase5_demo_e2e.js
 * BASE_URL=http://localhost:3000 node member_E/scripts/verify_phase5_demo_e2e.js
 */

const http = require('http');
const https = require('https');

const baseUrl = process.env.BASE_URL || 'http://localhost:3000';

let passed = 0;
let failed = 0;
let createdId = null;

function assert(condition, message) {
  if (condition) {
    passed += 1;
    console.log(`  ✓ ${message}`);
  } else {
    failed += 1;
    console.error(`  ✗ ${message}`);
  }
}

function request(method, path, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, baseUrl);
    const payload = body === undefined ? null : JSON.stringify(body);
    const lib = url.protocol === 'https:' ? https : http;
    const req = lib.request(
      url,
      {
        method,
        headers: {
          ...(payload
            ? {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(payload),
              }
            : {}),
          ...headers,
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (c) => {
          raw += c;
        });
        res.on('end', () => {
          let json = null;
          try {
            json = raw ? JSON.parse(raw) : null;
          } catch {
            json = { _raw: raw };
          }
          resolve({ status: res.statusCode, json });
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function chineseCategoryToSlug(name, categories) {
  const hit = categories.find((c) => c.name === name);
  return hit ? hit.id : 'other';
}

async function main() {
  console.log('\n成员 E — 阶段五 Demo 全链路 API 自检\n');
  console.log(`BASE_URL=${baseUrl}\n`);

  const health = await request('GET', '/api/collections?page=1&pageSize=1');
  assert(health.status === 200 && health.json?.success === true, '后端在线且列表可读');

  const cats = await request('GET', '/api/categories');
  const categoryList = cats.json?.data || [];
  assert(cats.status === 200 && categoryList.length >= 7, 'GET /api/categories 可用');

  const image = await request('POST', '/api/ai/analyze-image', {
    imageDescription: '一张泛黄的展览票根照片',
  });
  assert(image.status === 200 && image.json?.data?.suggestedTitle, 'AI 图片识别成功');
  const ai = image.json.data;
  const slug = chineseCategoryToSlug(ai.suggestedCategory, categoryList);

  const create = await request('POST', '/api/collections', {
    title: `[E5-Demo] ${ai.suggestedTitle}`,
    category: slug,
    story: ai.description,
    tags: ai.suggestedTags,
    visibility: 'private',
    userId: 1,
  });
  assert(create.status === 201 && create.json?.data?.id, '创建收藏成功');
  createdId = create.json.data.id;

  const badAi = await request('POST', '/api/ai/suggest-title', { description: '' });
  assert(badAi.status === 400, 'AI 标题失败返回 400（不阻塞主流程）');

  const manual = await request('POST', '/api/collections', {
    title: '[E5-Demo] Manual save after AI fail',
    category: 'postcard',
    story: '手动保存验证',
    userId: 1,
  });
  assert(manual.status === 201, 'AI 失败后仍可手动创建');

  const emptyTitle = await request('POST', '/api/collections', { story: 'no title' });
  assert(emptyTitle.status === 400, '标题为空不能保存');

  const storyAi = await request('POST', '/api/ai/generate-story', {
    description: ai.description,
    title: ai.suggestedTitle,
    category: ai.suggestedCategory,
    style: 'travel',
  });
  assert(storyAi.status === 200 && storyAi.json?.data?.story, '多风格故事 travel 成功');

  await request('PUT', `/api/collections/${createdId}`, {
    story: storyAi.json.data.story,
  });

  const keyword = encodeURIComponent('E5-Demo');
  const search = await request('GET', `/api/collections?keyword=${keyword}&page=1&pageSize=10`);
  const items = search.json?.data?.items || search.json?.data || [];
  const list = Array.isArray(items) ? items : [];
  assert(
    search.status === 200 && list.some((i) => String(i.id) === String(createdId)),
    '关键词搜索可找到新建收藏'
  );

  const detail = await request('GET', `/api/collections/${createdId}`);
  assert(
    detail.status === 200 &&
      detail.json?.data?.title &&
      detail.json?.data?.story &&
      Array.isArray(detail.json?.data?.tags),
    '详情页数据完整（含 tags 数组）'
  );

  const stats = await request('GET', '/api/users/1/stats');
  assert(
    stats.status === 200 &&
      typeof stats.json?.data?.totalCollections === 'number' &&
      Array.isArray(stats.json?.data?.recentCollections),
    '用户主页统计可用'
  );

  console.log(`\n结果：${passed} 通过，${failed} 失败`);
  if (createdId) {
    console.log(`（Demo 写入 collection id=${createdId}，可选手动 DELETE 清理）\n`);
  }
  process.exit(failed > 0 ? 1 : 0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
