const { getDb, saveDb, closeDb } = require('./connection');

const seedData = {
  users: [
    {
      username: 'collector_demo',
      email: 'demo@collection-journey.app',
      avatar_url: '/uploads/avatars/default.png',
      bio: '热爱收藏生活中的每一个美好瞬间。矿石、唱片、票根、明信片——每件小物背后都有一段旅程。',
    },
  ],

  categories: [
    { id: 'mineral', name: '矿石', icon: 'diamond', fields: '["weight","size","origin","color"]', display_priority: 1 },
    { id: 'crystal', name: '水晶', icon: 'auto_awesome', fields: '["type","color","origin","uses"]', display_priority: 2 },
    { id: 'vinyl', name: '黑胶唱片', icon: 'album', fields: '["artist","album","year","genre"]', display_priority: 3 },
    { id: 'postcard', name: '明信片', icon: 'mail', fields: '["from","to","postmark_date"]', display_priority: 4 },
    { id: 'ticket', name: '票根', icon: 'confirmation_number', fields: '["event","venue","date","seat"]', display_priority: 5 },
    { id: 'souvenir', name: '旅行纪念品', icon: 'flight_takeoff', fields: '["destination","trip_date","material"]', display_priority: 6 },
    { id: 'stamp', name: '邮票', icon: 'stamp', fields: '["country","year","denomination"]', display_priority: 7 },
    { id: 'other', name: '其他收藏', icon: 'favorite', fields: '[]', display_priority: 99 },
  ],

  collections: [
    {
      title: '紫水晶晶簇 — 阿根廷',
      category: 'crystal',
      date_acquired: '2024-11-15',
      location: 'Buenos Aires, Argentina',
      story: '在阿根廷旅行时，在一家小巷里的矿石店发现这枚紫水晶晶簇。店主是一位头发花白的老先生，他花了二十分钟给我讲解这块水晶的产地和特点。紫色的晶体在灯光下折射出淡紫色的光晕，每次看到它都会让我想起那个安静的午后。',
      image_url: '/uploads/collections/seed-01.jpg',
      tags: '["水晶","紫水晶","阿根廷","旅行","自然"]',
    },
    {
      title: '萤石立方 — 湖南郴州',
      category: 'mineral',
      date_acquired: '2025-01-20',
      location: '湖南郴州',
      story: '这块萤石来自郴州的矿山，绿色和紫色在立方体晶面上分层分布。是我第一次参加矿物展时入手的，卖家用略带湖南口音的普通话给我讲这块矿石的开采故事。绿色层是氟元素的富集区，紫色层则是微量锰元素致色。',
      image_url: '/uploads/collections/seed-02.jpg',
      tags: '["矿石","萤石","郴州","矿物展","中国"]',
    },
    {
      title: 'Pink Floyd — The Dark Side of the Moon',
      category: 'vinyl',
      date_acquired: '2024-09-05',
      location: 'London, UK',
      story: '在伦敦诺丁山的一家二手唱片店里找到了这张1973年的原版。封面上的三棱镜折射图案已经有些泛黄，但唱片保存得出奇地好。店主说这张唱片前主人是一位退休的BBC录音师。每次放这张唱片，整个房间都被那种温暖的模拟声音填满。',
      image_url: '/uploads/collections/seed-03.jpg',
      tags: '["黑胶","Pink Floyd","摇滚","经典","英国"]',
    },
    {
      title: '京都金阁寺明信片',
      category: 'postcard',
      date_acquired: '2024-04-08',
      location: 'Kyoto, Japan',
      story: '春假去京都旅行时，在金阁寺门口的邮局给自己寄了这张明信片。金阁寺在阳光下倒映在镜湖池中，那一刻觉得时间都慢下来了。明信片背面写的是一段日文小诗，虽然语法可能不太对，但那是当时最真实的感受。',
      image_url: '/uploads/collections/seed-04.jpg',
      tags: '["明信片","京都","金阁寺","日本","旅行"]',
    },
    {
      title: '坂本龙一音乐会票根 — 东京',
      category: 'ticket',
      date_acquired: '2023-12-10',
      location: 'Tokyo, Japan',
      story: '那晚在东京歌剧城的音乐会，教授弹了Merry Christmas Mr. Lawrence。全场安静得像时间凝固了一样，只有钢琴声在空气中流淌。票根上有手写的座位号，还有检票时留下的一道浅浅的折痕。这是一张值得永远保存的票。',
      image_url: '/uploads/collections/seed-05.jpg',
      tags: '["票根","音乐会","坂本龙一","东京","音乐"]',
    },
    {
      title: '冰岛黑沙滩鹅卵石',
      category: 'souvenir',
      date_acquired: '2024-07-22',
      location: 'Reynisfjara, Iceland',
      story: '在冰岛维克黑沙滩上捡的几颗被海浪打磨光滑的黑色鹅卵石。玄武岩柱在身后矗立，北大西洋的风吹得人睁不开眼。这些石头在冰岛的海浪中打磨了上千年，现在安静地躺在我的收藏盒里。每次摸到它们冰凉的表面，就想起那个世界尽头般的海滩。',
      image_url: '/uploads/collections/seed-06.jpg',
      tags: '["旅行纪念品","冰岛","黑沙滩","自然","石头"]',
    },
    {
      title: '黄铁矿太阳 — 秘鲁',
      category: 'mineral',
      date_acquired: '2024-08-14',
      location: 'Lima, Peru',
      story: '在秘鲁利马的一个矿物市场淘到的。秘鲁黄铁矿以其明亮的金属光泽闻名，这颗被切割成圆形，像一个小小的金属太阳。卖家说当地人会把它放在办公桌上，象征财富和光明。它的立方体晶形隐约可见，在光线下闪闪发光。',
      image_url: '/uploads/collections/seed-07.jpg',
      tags: '["矿石","黄铁矿","秘鲁","旅行","矿物"]',
    },
    {
      title: '西湖雷峰塔明信片',
      category: 'postcard',
      date_acquired: '2024-10-03',
      location: '杭州',
      story: '国庆假期去的杭州，人山人海中在雷峰塔下的小店买了这张明信片。画面是夕阳下的雷峰塔和西湖，背后写着"欲把西湖比西子，淡妆浓抹总相宜"。虽然已经去过很多次杭州，但每次西湖的光影都不一样。',
      image_url: '/uploads/collections/seed-08.jpg',
      tags: '["明信片","西湖","杭州","中国","旅行"]',
    },
    {
      title: 'Miles Davis — Kind of Blue',
      category: 'vinyl',
      date_acquired: '2025-02-14',
      location: 'New York, USA',
      story: '在纽约格林威治村的一家爵士唱片店找到的。1959年的经典录音，蓝色封面已经有些褪色，但唱片只播放过寥寥数次。店主说这张唱片来自一位老爵士乐手的遗物，里面还有一张手写的便签，写着"for the quiet nights"。',
      image_url: '/uploads/collections/seed-09.jpg',
      tags: '["黑胶","爵士","Miles Davis","美国","经典"]',
    },
    {
      title: '上海国际电影节票根',
      category: 'ticket',
      date_acquired: '2024-06-16',
      location: '上海',
      story: '那天在大光明电影院看的是一部修复版的费里尼黑白电影。票根上印着电影节的logo，座位是二楼中间的位置，视野特别好。散场时外面下着小雨，和朋友们在旁边的咖啡馆聊电影聊到深夜。这张票根就是那个完美的电影之夜。',
      image_url: '/uploads/collections/seed-10.jpg',
      tags: '["票根","电影节","上海","电影","费里尼"]',
    },
    {
      title: '玫瑰石英 — 马达加斯加',
      category: 'crystal',
      date_acquired: '2024-05-18',
      location: 'Antananarivo, Madagascar',
      story: '马达加斯加的玫瑰石英以质地纯净著称。这块原石未经切割，保持着天然的六方柱形，淡粉色在自然光下特别温柔。当地人说玫瑰石英是爱之石，我自己倒觉得它更像是一种安静的陪伴——放在书桌上，每次眼睛瞟到都会不自觉地微笑。',
      image_url: '/uploads/collections/seed-11.jpg',
      tags: '["水晶","玫瑰石英","马达加斯加","旅行","自然"]',
    },
    {
      title: '挪威邮轮峡湾纪念磁贴',
      category: 'souvenir',
      date_acquired: '2024-08-03',
      location: 'Geirangerfjord, Norway',
      story: '坐邮轮穿越盖朗厄尔峡湾时买的纪念磁贴。峡湾两侧是陡峭的悬崖和飞流直下的瀑布，船上的广播在介绍着每一段山壁的历史。磁贴上印着挪威国旗和峡湾地图。它现在贴在我的冰箱门上，每次路过都会想起那个凉爽的北欧夏日。',
      image_url: '/uploads/collections/seed-12.jpg',
      tags: '["旅行纪念品","挪威","峡湾","邮轮","北欧"]',
    },
    {
      title: '1980年代中国生肖邮票 — 龙年',
      category: 'stamp',
      date_acquired: '2024-01-10',
      location: '北京',
      story: '在潘家园旧货市场淘到的第一轮生肖龙票。票面有些微黄，但图案清晰，龙的造型充满八十年代的质朴感。卖邮票的大叔说这是他家老爷子当年集邮时留的，虽然没有生肖猴票那么稀有，但对我来说，能遇到一枚和自己属相一致的龙票，也是缘分。',
      image_url: '/uploads/collections/seed-13.jpg',
      tags: '["邮票","生肖","龙年","中国","收藏"]',
    },
    {
      title: '普罗旺斯薰衣草干花束',
      category: 'souvenir',
      date_acquired: '2024-07-05',
      location: 'Provence, France',
      story: '七月的普罗旺斯，薰衣草田像一片紫色海洋。从一位戴着草帽的当地农妇手里买了这束刚收割的薰衣草，她用法语说了很多话，我只听懂了"bon voyage"。花束现在已经完全干了，但香气还在。放在衣柜里，偶尔打开柜门就有淡淡的薰衣草香。',
      image_url: '/uploads/collections/seed-14.jpg',
      tags: '["旅行纪念品","薰衣草","法国","普罗旺斯","夏日"]',
    },
    {
      title: '蓝铜矿与孔雀石共生 — 刚果',
      category: 'mineral',
      date_acquired: '2025-03-02',
      location: 'Kinshasa, Congo',
      story: '蓝色和绿色在一小块石头上完美共存——深蓝色的蓝铜矿嵌在翠绿色的孔雀石基质中，像一幅天然的抽象画。这块矿石来自刚果的著名铜矿区，是一位地质学家朋友帮忙带回来的。蓝色部分是铜的碳酸盐矿物，绿色则是另一种铜矿物。两种颜色对比太强烈了，每次朋友来访都会问这是什么。',
      image_url: '/uploads/collections/seed-15.jpg',
      tags: '["矿石","蓝铜矿","孔雀石","刚果","自然"]',
    },
  ],
};

async function seed() {
  console.log('Seeding database...');

  const db = await getDb();

  // Clear existing data
  db.run('DELETE FROM collections');
  db.run('DELETE FROM categories');
  db.run('DELETE FROM users');

  // Reset AUTOINCREMENT counters
  db.run("DELETE FROM sqlite_sequence WHERE name IN ('collections', 'users')");

  // Insert default user
  const insertUser = db.prepare(
    'INSERT INTO users (username, email, avatar_url, bio) VALUES (?, ?, ?, ?)'
  );
  seedData.users.forEach((u) => {
    insertUser.run([u.username, u.email, u.avatar_url, u.bio]);
  });
  insertUser.free();

  const userIdResult = db.exec('SELECT last_insert_rowid()');
  const userId = userIdResult[0].values[0][0];
  console.log(`  Inserted ${seedData.users.length} user(s) (id=${userId})`);

  // Insert categories
  const insertCategory = db.prepare(
    'INSERT INTO categories (id, name, icon, fields, display_priority) VALUES (?, ?, ?, ?, ?)'
  );
  seedData.categories.forEach((c) => {
    insertCategory.run([c.id, c.name, c.icon, c.fields, c.display_priority]);
  });
  insertCategory.free();
  console.log(`  Inserted ${seedData.categories.length} categories`);

  // Insert collections
  const insertCollection = db.prepare(
    `INSERT INTO collections (title, category, date_acquired, location, story, image_url, tags, user_id, visibility)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
  );
  seedData.collections.forEach((c, i) => {
    const visibility = i % 3 === 0 ? 'public' : 'private';
    insertCollection.run([
      c.title, c.category, c.date_acquired, c.location,
      c.story, c.image_url, c.tags, userId, visibility,
    ]);
  });
  insertCollection.free();
  console.log(`  Inserted ${seedData.collections.length} collections`);

  saveDb();
  closeDb();

  console.log('Seed completed successfully.');
  console.log('Database file: backend/data/collections.db');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
