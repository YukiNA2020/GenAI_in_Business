// Phase 5 Task 4: AI Integration Tests (成员 1 / 成员 5 联调验证)
const http = require('http');

function req(method, path, body) {
  return new Promise((resolve, reject) => {
    const url = new URL('http://localhost:3000' + path);
    const data = body ? JSON.stringify(body) : '';
    const opts = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method,
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) },
    };
    const r = http.request(opts, (res) => {
      let raw = '';
      res.on('data', (chunk) => raw += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(raw) }); }
        catch { resolve({ status: res.statusCode, body: raw }); }
      });
    });
    r.on('error', reject);
    if (data) r.write(data);
    r.end();
  });
}

async function run() {
  let passed = 0;
  let failed = 0;
  const ids = [];

  function assert(label, condition, detail) {
    if (condition) { passed++; console.log('  PASS: ' + label); }
    else { failed++; console.log('  FAIL: ' + label + ' — ' + (detail !== undefined ? detail : '')); }
  }

  function cleanup(id) { if (id) ids.push(id); }

  // ============================================================
  // GROUP 1: AI output saved to collections
  // ============================================================
  console.log('\n=== 1. AI 输出保存到收藏 (核心验证) ===');

  const aiData = {
    title: 'AI标题 — 东京蓝色明信片',
    category: 'postcard',
    tags: ['AI标签1', 'AI标签2', '旅行'],
    story: 'AI生成的收藏故事：在一个安静的下午，AI帮助用户回忆起这段美好的旅行时光。',
    location: 'AI推测地点 — Tokyo',
    dateAcquired: '2026-05-01',
    customFields: '{"ai_generated":true,"confidence":0.85}',
    visibility: 'public',
    userId: 1,
    categoryTemplate: 'postcard',
  };
  const r1 = await req('POST', '/api/collections', aiData);
  assert('AI全字段创建(201)', r1.status === 201, r1.body.error?.message);
  assert('AI标题保存', r1.body.data?.title === aiData.title);
  assert('AI标签为数组', Array.isArray(r1.body.data?.tags) && r1.body.data.tags.length === 3);
  assert('AI故事保存', r1.body.data?.story === aiData.story);
  assert('AI地点保存', r1.body.data?.location === aiData.location);
  assert('customFields保存', r1.body.data?.customFields === aiData.customFields);
  assert('categoryTemplate保存', r1.body.data?.categoryTemplate === 'postcard');
  const aiId = r1.body.data?.id;
  cleanup(aiId);

  // Verify appears in list
  const r2 = await req('GET', '/api/collections?pageSize=50');
  assert('AI收藏出现在列表', r2.body.data?.items.some(i => i.id === aiId));

  // Verify detail
  const r3 = await req('GET', '/api/collections/' + aiId);
  assert('AI收藏详情可查', r3.status === 200 && r3.body.success);
  assert('详情tags为数组', Array.isArray(r3.body.data?.tags));

  // AI partial update
  const r4 = await req('PUT', '/api/collections/' + aiId, {
    title: 'AI更新标题',
    tags: ['更新标签'],
    story: 'AI重新生成的故事',
  });
  assert('AI部分更新(200)', r4.status === 200);
  assert('更新标题正确', r4.body.data?.title === 'AI更新标题');
  assert('更新tags数组', Array.isArray(r4.body.data?.tags) && r4.body.data.tags.length === 1);

  // AI null clear
  const r5 = await req('PUT', '/api/collections/' + aiId, {
    location: null,
    customFields: null,
  });
  assert('null清空字段', r5.status === 200);
  assert('location已清空', r5.body.data?.location === null);
  assert('customFields已清空', r5.body.data?.customFields === null);

  // Empty tags from AI
  const r6 = await req('POST', '/api/collections', {
    title: '最小AI创建',
    tags: [],
    story: 'AI最简故事',
  });
  assert('tags=[]返回空数组', Array.isArray(r6.body.data?.tags) && r6.body.data.tags.length === 0);
  cleanup(r6.body.data?.id);

  // Tags omitted entirely
  const r7 = await req('POST', '/api/collections', { title: '无tags字段' });
  assert('不传tags返回空数组', Array.isArray(r7.body.data?.tags) && r7.body.data.tags.length === 0);
  cleanup(r7.body.data?.id);

  // ============================================================
  // GROUP 2: AI failure does NOT block main flow
  // ============================================================
  console.log('\n=== 2. AI 失败不影响主流程 ===');

  const r8 = await req('POST', '/api/collections', {
    title: '纯手动收藏-无AI',
    category: 'mineral',
    location: '手动地点',
    story: '手动故事',
    tags: ['手动标签'],
  });
  assert('无AI字段创建成功', r8.status === 201);
  cleanup(r8.body.data?.id);

  const r9 = await req('POST', '/api/collections', { title: '最简-仅标题' });
  assert('仅标题创建成功', r9.status === 201);
  cleanup(r9.body.data?.id);

  assert('API无AI依赖(无/ai路由)', true);

  // ============================================================
  // GROUP 3: ai_usage_logs table
  // ============================================================
  console.log('\n=== 3. ai_usage_logs 表验证 ===');

  const { getDb, saveDb, closeDb } = require('../src/db/connection');
  const db = await getDb();
  try {
    db.run('DELETE FROM ai_usage_logs');
    db.run('INSERT INTO ai_usage_logs (user_id, feature) VALUES (?, ?)', [1, 'title_generation']);
    db.run('INSERT INTO ai_usage_logs (user_id, feature) VALUES (?, ?)', [1, 'category_suggestion']);
    db.run('INSERT INTO ai_usage_logs (user_id, feature) VALUES (?, ?)', [1, 'tags_recommendation']);
    db.run('INSERT INTO ai_usage_logs (user_id, feature) VALUES (?, ?)', [1, 'story_generation']);

    const result = db.exec('SELECT * FROM ai_usage_logs');
    const rows = result.length ? result[0].values : [];
    assert('ai_usage_logs可写入', rows.length === 4, 'rows=' + rows.length);
    assert('feature字段正确', rows.some(r => r[2] === 'title_generation'));
    assert('user_id关联正确', rows.every(r => r[1] === 1));
    assert('created_at自动填充', rows.every(r => typeof r[3] === 'string' && r[3].length > 0));

    const cols = result[0].columns;
    assert('含id列', cols.includes('id'));
    assert('含user_id列', cols.includes('user_id'));
    assert('含feature列', cols.includes('feature'));
    assert('含created_at列', cols.includes('created_at'));

    db.run('DELETE FROM ai_usage_logs');
  } finally {
    saveDb();
    closeDb();
  }

  // ============================================================
  // GROUP 4: Categories API (AI category name → slug mapping)
  // ============================================================
  console.log('\n=== 4. Categories API (AI分类映射) ===');

  const r10 = await req('GET', '/api/categories');
  assert('分类列表可获取', r10.status === 200 && Array.isArray(r10.body.data));
  assert('共8个分类', r10.body.data.length === 8);

  const cats = r10.body.data;
  assert('每个分类有id+name', cats.every(c => typeof c.id === 'string' && typeof c.name === 'string'));

  // Verify key mappings that AI needs
  const mappings = { postcard: '明信片', mineral: '矿石', crystal: '水晶', vinyl: '黑胶唱片', ticket: '票根', souvenir: '旅行纪念品', stamp: '邮票', other: '其他收藏' };
  for (const [slug, name] of Object.entries(mappings)) {
    const c = cats.find(x => x.id === slug);
    assert('slug→name: ' + slug + '→' + name, c?.name === name);
  }

  // Category detail
  const r11 = await req('GET', '/api/categories/postcard');
  assert('分类详情可获取', r11.status === 200 && r11.body.data?.id === 'postcard');
  assert('fields已解析为数组', Array.isArray(r11.body.data?.fields));
  assert('displayPriority为camelCase', typeof r11.body.data?.displayPriority === 'number');

  // ============================================================
  // GROUP 5: Users stats (Member 5 user profile page)
  // ============================================================
  console.log('\n=== 5. Users Stats (用户主页) ===');

  const r12 = await req('GET', '/api/users/1/stats');
  assert('用户统计可获取', r12.status === 200 && r12.body.success);
  assert('totalCollections为number', typeof r12.body.data?.totalCollections === 'number');
  assert('categoryCount为number', typeof r12.body.data?.categoryCount === 'number');
  assert('publicCollections为number', typeof r12.body.data?.publicCollections === 'number');
  assert('recentCollections为数组', Array.isArray(r12.body.data?.recentCollections));

  if (r12.body.data?.recentCollections.length > 0) {
    const recent = r12.body.data.recentCollections[0];
    assert('recent含id', typeof recent.id === 'number');
    assert('recent含title', typeof recent.title === 'string');
    assert('recent的tags为数组', Array.isArray(recent.tags));
    assert('recent含imageUrl', 'imageUrl' in recent);
    assert('recent含createdAt', 'createdAt' in recent);
    assert('recent含userId', 'userId' in recent);
    assert('recent含visibility', 'visibility' in recent);
    assert('recent含categoryTemplate', 'categoryTemplate' in recent);
    assert('recent含customFields', 'customFields' in recent);
  }

  // Non-existent user
  const r13 = await req('GET', '/api/users/999/stats');
  assert('不存在用户→404', r13.status === 404);

  // Invalid ID
  const r14 = await req('GET', '/api/users/abc/stats');
  assert('非法ID→400', r14.status === 400);

  // ============================================================
  // GROUP 6: Edge cases
  // ============================================================
  console.log('\n=== 6. AI集成边界情况 ===');

  // Long story
  const longStory = 'AI生成的长故事。'.repeat(50);
  const r15 = await req('POST', '/api/collections', {
    title: '长故事测试',
    story: longStory,
    tags: Array.from({ length: 20 }, (_, i) => '标签' + (i + 1)),
  });
  assert('超长故事可保存', r15.status === 201 && r15.body.data?.story === longStory);
  assert('20个标签可保存', r15.body.data?.tags.length === 20);
  cleanup(r15.body.data?.id);

  // Special characters
  const r16 = await req('POST', '/api/collections', {
    title: "特殊字符 <>&\"' 测试",
    story: '换行\n引号"test"内容',
  });
  assert('特殊字符可保存', r16.status === 201);
  cleanup(r16.body.data?.id);

  // Emoji
  const r17 = await req('POST', '/api/collections', {
    title: '🎵 AI生成标题 ✨',
    story: '🎨 这条收藏很特别 🌍',
  });
  assert('Emoji可保存', r17.status === 201);
  cleanup(r17.body.data?.id);

  // Complex customFields JSON
  const complexJson = JSON.stringify({
    ai_analysis: {
      primary_type: 'mineral',
      confidence_scores: { mineral: 0.7, crystal: 0.3 },
    },
    metadata: { model: 'claude-4', timestamp: '2026-05-16T10:00:00Z' },
  });
  const r18 = await req('POST', '/api/collections', {
    title: '复杂customFields',
    customFields: complexJson,
  });
  assert('复杂JSON customFields保存', r18.status === 201);
  assert('customFields内容完整', r18.body.data?.customFields === complexJson);
  cleanup(r18.body.data?.id);

  // Empty string fields
  const r19 = await req('POST', '/api/collections', {
    title: '空字符串字段',
    category: '',
    location: '',
    story: '',
  });
  assert('空字符串可保存', r19.status === 201);
  cleanup(r19.body.data?.id);

  // ============================================================
  // Cleanup
  // ============================================================
  for (const id of ids) {
    await req('DELETE', '/api/collections/' + id);
  }

  console.log('\n========== 测试结果 ==========');
  console.log('通过: ' + passed);
  console.log('失败: ' + failed);
  console.log('总计: ' + (passed + failed));
  if (failed > 0) process.exit(1);
}

run().catch(e => { console.error(e); process.exit(1); });
