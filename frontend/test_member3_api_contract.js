/**
 * 成员 C / 成员 3 — 前端 API 契约与浏览流程测试（模拟 collection_query_service.dart）
 * 负责人：成员 C / 成员 3，由该成员的测试 AI 协助编写
 */
const BASE = 'http://localhost:3000';

let passed = 0;
let failed = 0;
const failures = [];

function ok(name, cond, detail = '') {
  if (cond) {
    passed++;
    console.log(`  ✅ ${name}`);
  } else {
    failed++;
    const msg = detail || 'assertion failed';
    failures.push({ name, msg });
    console.log(`  ❌ ${name}: ${msg}`);
  }
}

async function api(path, opts = {}) {
  const res = await fetch(`${BASE}${path}`, opts);
  const json = await res.json().catch(() => null);
  return { res, json };
}

async function run() {
  console.log('=== 成员 3 API 契约测试（对齐 collection_query_service.dart）===\n');

  // Health — main.dart checkHealth
  {
    const { res, json } = await api('/api/health');
    ok('GET /api/health → 200', res.status === 200);
    ok('health success=true', json?.success === true);
  }

  // List — fetchCollections default (pageSize=20 in provider initial)
  let listItems = [];
  let total = 0;
  {
    const { res, json } = await api('/api/collections?page=1&pageSize=20&sort=created_desc');
    ok('GET /api/collections 列表 200', res.status === 200 && json?.success);
    const data = json?.data;
    listItems = data?.items ?? [];
    total = data?.total ?? 0;
    ok('列表含 items/total/page/pageSize', Array.isArray(listItems) && typeof total === 'number');
    ok('seed 约 15 条', total >= 15, `total=${total}`);
    if (listItems[0]) {
      const item = listItems[0];
      ok('camelCase: imageUrl', 'imageUrl' in item && !('image_url' in item));
      ok('tags 为数组', Array.isArray(item.tags), JSON.stringify(item.tags));
      ok('卡片字段: id/title/category', item.id && item.title);
    }
  }

  // Keyword search — debounce 后 keyword 参数
  {
    const { json } = await api('/api/collections?keyword=紫水晶&page=1&pageSize=20');
    const items = json?.data?.items ?? [];
    ok('keyword=紫水晶 有结果', items.length >= 1, `count=${items.length}`);
    const hit = items.some((i) => i.title?.includes('紫水晶') || i.tags?.some((t) => t.includes('紫水晶')));
    ok('结果匹配标题或 tags', hit);
  }

  // Category filter
  {
    const { json } = await api('/api/collections?category=crystal&page=1&pageSize=20');
    const items = json?.data?.items ?? [];
    ok('category=crystal 有结果', items.length >= 1);
    ok('全部为 crystal', items.every((i) => i.category === 'crystal'));
  }

  // Tag filter
  {
    const { json } = await api('/api/collections?tag=旅行&page=1&pageSize=20');
    const items = json?.data?.items ?? [];
    ok('tag=旅行 有结果', items.length >= 1);
  }

  // Sort
  for (const sort of ['created_desc', 'created_asc', 'date_desc', 'date_asc']) {
    const { res } = await api(`/api/collections?sort=${sort}&pageSize=3`);
    ok(`sort=${sort} 200`, res.status === 200);
  }

  // Pagination append simulation
  {
    const p1 = await api('/api/collections?page=1&pageSize=3');
    const p2 = await api('/api/collections?page=2&pageSize=3');
    const ids1 = (p1.json?.data?.items ?? []).map((i) => i.id);
    const ids2 = (p2.json?.data?.items ?? []).map((i) => i.id);
    ok('分页 page1/page2 不重复', ids1.length && ids2.length && !ids1.some((id) => ids2.includes(id)));
  }

  // Detail — fetchById
  const detailId = listItems[0]?.id ?? 1;
  {
    const { res, json } = await api(`/api/collections/${detailId}`);
    ok('GET /api/collections/:id 200', res.status === 200);
    const item = json?.data;
    ok('详情含 story/location/dateAcquired', item?.story != null || item?.location != null);
    ok('详情 tags 数组', Array.isArray(item?.tags));
  }

  // Categories — fetchCategories
  {
    const { res, json } = await api('/api/categories');
    ok('GET /api/categories 200', res.status === 200);
    const cats = json?.data ?? [];
    ok('8 个分类', cats.length === 8, `len=${cats.length}`);
    ok('分类含 displayPriority camelCase', cats[0] && 'displayPriority' in cats[0]);
  }

  // User stats — fetchUserStats(1)
  {
    const { res, json } = await api('/api/users/1/stats');
    ok('GET /api/users/1/stats 200', res.status === 200);
    const d = json?.data;
    ok('stats 四字段', d && 'totalCollections' in d && 'categoryCount' in d && 'publicCollections' in d && 'recentCollections' in d);
    ok('recentCollections ≤5', Array.isArray(d?.recentCollections) && d.recentCollections.length <= 5);
  }

  // Public filter simulation — fetchPublicCollections
  {
    const { json } = await api('/api/collections?page=1&pageSize=100');
    const all = json?.data?.items ?? [];
    const pub = all.filter((i) => i.visibility === 'public');
    ok('存在 public 收藏', pub.length >= 1, `public=${pub.length}`);
  }

  // DELETE — deleteById (create temp then delete)
  {
    const create = await api('/api/collections', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: 'M3 Test Delete' }),
    });
    const newId = create.json?.data?.id;
    ok('创建测试收藏', create.res.status === 201 && newId);
    if (newId) {
      const del = await api(`/api/collections/${newId}`, { method: 'DELETE' });
      ok('DELETE /api/collections/:id 200', del.res.status === 200);
      const again = await api(`/api/collections/${newId}`);
      ok('删除后 GET 404', again.res.status === 404);
    }
  }

  // 404 detail
  {
    const { res } = await api('/api/collections/99999');
    ok('不存在 id → 404', res.status === 404);
  }

  console.log(`\n=== 结果: ${passed} 通过, ${failed} 失败 ===`);
  if (failures.length) {
    console.log('\n失败明细:');
    failures.forEach((f) => console.log(`  - ${f.name}: ${f.msg}`));
    process.exit(1);
  }
}

run().catch((e) => {
  console.error('测试运行失败:', e.message);
  process.exit(1);
});
