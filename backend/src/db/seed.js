const { getDb, saveDb, closeDb } = require('./connection');

// ============================================================
// Room definitions: each room = one calendar month
// ============================================================
const rooms = [
  { month: '2023-12', label: '2023年12月' },
  { month: '2024-01', label: '2024年1月' },
  { month: '2024-04', label: '2024年4月' },
  { month: '2024-05', label: '2024年5月' },
  { month: '2024-06', label: '2024年6月' },
  { month: '2024-07', label: '2024年7月' },
  { month: '2024-08', label: '2024年8月' },
  { month: '2024-09', label: '2024年9月' },
  { month: '2024-10', label: '2024年10月' },
  { month: '2024-11', label: '2024年11月' },
  { month: '2025-01', label: '2025年1月' },
  { month: '2025-02', label: '2025年2月' },
  { month: '2025-03', label: '2025年3月' },
];

const categories = [
  { id: 'mineral', name: '矿石', icon: 'diamond', fields: '["weight","size","origin","color"]', display_priority: 1 },
  { id: 'crystal', name: '水晶', icon: 'auto_awesome', fields: '["type","color","origin","uses"]', display_priority: 2 },
  { id: 'vinyl', name: '黑胶唱片', icon: 'album', fields: '["artist","album","year","genre"]', display_priority: 3 },
  { id: 'postcard', name: '明信片', icon: 'mail', fields: '["from","to","postmark_date"]', display_priority: 4 },
  { id: 'ticket', name: '票根', icon: 'confirmation_number', fields: '["event","venue","date","seat"]', display_priority: 5 },
  { id: 'souvenir', name: '旅行纪念品', icon: 'flight_takeoff', fields: '["destination","trip_date","material"]', display_priority: 6 },
  { id: 'stamp', name: '邮票', icon: 'stamp', fields: '["country","year","denomination"]', display_priority: 7 },
  { id: 'other', name: '其他收藏', icon: 'favorite', fields: '[]', display_priority: 99 },
];

// Original 15 collections, reorganized by month-room
// Each belongs to exactly one room; date_acquired matches that room's month
const originalCollections = [
  // ===== Room 2023-12 =====
  { month: '2023-12', title: '坂本龙一音乐会票根 — 东京', category: 'ticket',
    date_acquired: '2023-12-10', location: 'Tokyo, Japan',
    story: '那晚在东京歌剧城的音乐会，教授弹了Merry Christmas Mr. Lawrence。全场安静得像时间凝固了一样，只有钢琴声在空气中流淌。票根上有手写的座位号，还有检票时留下的一道浅浅的折痕。这是一张值得永远保存的票。',
    image_url: '/uploads/collections/seed-05.jpg', tags: '["票根","音乐会","坂本龙一","东京","音乐"]' },
  // ===== Room 2024-01 =====
  { month: '2024-01', title: '1980年代中国生肖邮票 — 龙年', category: 'stamp',
    date_acquired: '2024-01-10', location: '北京',
    story: '在潘家园旧货市场淘到的第一轮生肖龙票。票面有些微黄，但图案清晰，龙的造型充满八十年代的质朴感。卖邮票的大叔说这是他家老爷子当年集邮时留的。能遇到一枚和自己属相一致的龙票，也是缘分。',
    image_url: '/uploads/collections/seed-13.jpg', tags: '["邮票","生肖","龙年","中国","收藏"]' },
  // ===== Room 2024-04 =====
  { month: '2024-04', title: '京都金阁寺明信片', category: 'postcard',
    date_acquired: '2024-04-08', location: 'Kyoto, Japan',
    story: '春假去京都旅行时，在金阁寺门口的邮局给自己寄了这张明信片。金阁寺在阳光下倒映在镜湖池中，那一刻觉得时间都慢下来了。明信片背面写的是一段日文小诗，虽然语法可能不太对，但那是当时最真实的感受。',
    image_url: '/uploads/collections/seed-04.jpg', tags: '["明信片","京都","金阁寺","日本","旅行"]' },
  // ===== Room 2024-05 (existing 1 item) =====
  { month: '2024-05', title: '玫瑰石英 — 马达加斯加', category: 'crystal',
    date_acquired: '2024-05-18', location: 'Antananarivo, Madagascar',
    story: '马达加斯加的玫瑰石英以质地纯净著称。这块原石未经切割，保持着天然的六方柱形，淡粉色在自然光下特别温柔。当地人说玫瑰石英是爱之石，我自己倒觉得它更像是一种安静的陪伴——放在书桌上，每次眼睛瞟到都会不自觉地微笑。',
    image_url: '/uploads/collections/seed-11.jpg', tags: '["水晶","玫瑰石英","马达加斯加","旅行","自然"]' },
  // ===== Room 2024-06 =====
  { month: '2024-06', title: '上海国际电影节票根', category: 'ticket',
    date_acquired: '2024-06-16', location: '上海',
    story: '那天在大光明电影院看的是一部修复版的费里尼黑白电影。票根上印着电影节的logo，座位是二楼中间的位置。散场时外面下着小雨，和朋友们在旁边的咖啡馆聊电影聊到深夜。这张票根就是那个完美的电影之夜。',
    image_url: '/uploads/collections/seed-10.jpg', tags: '["票根","电影节","上海","电影","费里尼"]' },
  // ===== Room 2024-07 =====
  { month: '2024-07', title: '普罗旺斯薰衣草干花束', category: 'souvenir',
    date_acquired: '2024-07-05', location: 'Provence, France',
    story: '七月的普罗旺斯，薰衣草田像一片紫色海洋。从一位戴着草帽的当地农妇手里买了这束刚收割的薰衣草。花束现在已经完全干了，但香气还在。放在衣柜里，偶尔打开柜门就有淡淡的薰衣草香。',
    image_url: '/uploads/collections/seed-14.jpg', tags: '["旅行纪念品","薰衣草","法国","普罗旺斯","夏日"]' },
  { month: '2024-07', title: '冰岛黑沙滩鹅卵石', category: 'souvenir',
    date_acquired: '2024-07-22', location: 'Reynisfjara, Iceland',
    story: '在冰岛维克黑沙滩上捡的几颗被海浪打磨光滑的黑色鹅卵石。玄武岩柱在身后矗立，北大西洋的风吹得人睁不开眼。这些石头在冰岛的海浪中打磨了上千年，现在安静地躺在我的收藏盒里。',
    image_url: '/uploads/collections/seed-06.jpg', tags: '["旅行纪念品","冰岛","黑沙滩","自然","石头"]' },
  // ===== Room 2024-08 =====
  { month: '2024-08', title: '挪威邮轮峡湾纪念磁贴', category: 'souvenir',
    date_acquired: '2024-08-03', location: 'Geirangerfjord, Norway',
    story: '坐邮轮穿越盖朗厄尔峡湾时买的纪念磁贴。峡湾两侧是陡峭的悬崖和飞流直下的瀑布。磁贴上印着挪威国旗和峡湾地图。它现在贴在我的冰箱门上，每次路过都会想起那个凉爽的北欧夏日。',
    image_url: '/uploads/collections/seed-12.jpg', tags: '["旅行纪念品","挪威","峡湾","邮轮","北欧"]' },
  { month: '2024-08', title: '黄铁矿太阳 — 秘鲁', category: 'mineral',
    date_acquired: '2024-08-14', location: 'Lima, Peru',
    story: '在秘鲁利马的一个矿物市场淘到的。秘鲁黄铁矿以其明亮的金属光泽闻名，这颗被切割成圆形，像一个小小的金属太阳。卖家说当地人会把它放在办公桌上，象征财富和光明。',
    image_url: '/uploads/collections/seed-07.jpg', tags: '["矿石","黄铁矿","秘鲁","旅行","矿物"]' },
  // ===== Room 2024-09 =====
  { month: '2024-09', title: 'Pink Floyd — The Dark Side of the Moon', category: 'vinyl',
    date_acquired: '2024-09-05', location: 'London, UK',
    story: '在伦敦诺丁山的一家二手唱片店里找到了这张1973年的原版。封面上的三棱镜折射图案已经有些泛黄，但唱片保存得出奇地好。每次放这张唱片，整个房间都被那种温暖的模拟声音填满。',
    image_url: '/uploads/collections/seed-03.jpg', tags: '["黑胶","Pink Floyd","摇滚","经典","英国"]' },
  // ===== Room 2024-10 =====
  { month: '2024-10', title: '西湖雷峰塔明信片', category: 'postcard',
    date_acquired: '2024-10-03', location: '杭州',
    story: '国庆假期去的杭州，人山人海中在雷峰塔下的小店买了这张明信片。画面是夕阳下的雷峰塔和西湖。虽然已经去过很多次杭州，但每次西湖的光影都不一样。',
    image_url: '/uploads/collections/seed-08.jpg', tags: '["明信片","西湖","杭州","中国","旅行"]' },
  // ===== Room 2024-11 =====
  { month: '2024-11', title: '紫水晶晶簇 — 阿根廷', category: 'crystal',
    date_acquired: '2024-11-15', location: 'Buenos Aires, Argentina',
    story: '在阿根廷旅行时，在一家小巷里的矿石店发现这枚紫水晶晶簇。店主是一位头发花白的老先生，他花了二十分钟给我讲解这块水晶的产地和特点。紫色的晶体在灯光下折射出淡紫色的光晕。',
    image_url: '/uploads/collections/seed-01.jpg', tags: '["水晶","紫水晶","阿根廷","旅行","自然"]' },
  // ===== Room 2025-01 =====
  { month: '2025-01', title: '萤石立方 — 湖南郴州', category: 'mineral',
    date_acquired: '2025-01-20', location: '湖南郴州',
    story: '这块萤石来自郴州的矿山，绿色和紫色在立方体晶面上分层分布。是我第一次参加矿物展时入手的。绿色层是氟元素的富集区，紫色层则是微量锰元素致色。',
    image_url: '/uploads/collections/seed-02.jpg', tags: '["矿石","萤石","郴州","矿物展","中国"]' },
  // ===== Room 2025-02 =====
  { month: '2025-02', title: 'Miles Davis — Kind of Blue', category: 'vinyl',
    date_acquired: '2025-02-14', location: 'New York, USA',
    story: '在纽约格林威治村的一家爵士唱片店找到的。1959年的经典录音，蓝色封面已经有些褪色。店主说这张唱片来自一位老爵士乐手的遗物，里面还有一张手写的便签，写着"for the quiet nights"。',
    image_url: '/uploads/collections/seed-09.jpg', tags: '["黑胶","爵士","Miles Davis","美国","经典"]' },
  // ===== Room 2025-03 =====
  { month: '2025-03', title: '蓝铜矿与孔雀石共生 — 刚果', category: 'mineral',
    date_acquired: '2025-03-02', location: 'Kinshasa, Congo',
    story: '蓝色和绿色在一小块石头上完美共存——深蓝色的蓝铜矿嵌在翠绿色的孔雀石基质中，像一幅天然的抽象画。这块矿石来自刚果的著名铜矿区，是一位地质学家朋友帮忙带回来的。',
    image_url: '/uploads/collections/seed-15.jpg', tags: '["矿石","蓝铜矿","孔雀石","刚果","自然"]' },
];

// ============================================================
// NEW: 15 additional May 2024 collections
// Cover all 4 exhibit categories: mineral, crystal, vinyl, postcard
// ============================================================
const newMayCollections = [
  // --- mineral (矿石) x4 ---
  { month: '2024-05', title: '天河石原石 — 巴西', category: 'mineral',
    date_acquired: '2024-05-02', location: 'Sao Paulo, Brazil',
    story: '这块天河石呈现迷人的蓝绿色，在阳光下会泛出丝绸般的光泽。在巴西圣保罗的矿物展上，一位老收藏家推荐给我的。蓝绿色的晶体中夹杂着白色的钠长石条纹，像天空中的云朵。',
    image_url: '/uploads/collections/seed-may-01.jpg', tags: '["矿石","天河石","巴西","矿物展","五月"]' },
  { month: '2024-05', title: '黄铜矿标本 — 秘鲁安第斯山脉', category: 'mineral',
    date_acquired: '2024-05-05', location: 'Cusco, Peru',
    story: '这块黄铜矿来自安第斯山脉的高海拔矿区。表面有五彩斑斓的晕彩——蓝色、紫色、金色在同一个晶体面上交叠变换，像矿物的极光。是在库斯科的一家小店遇到的。',
    image_url: '/uploads/collections/seed-may-02.jpg', tags: '["矿石","黄铜矿","秘鲁","安第斯","晕彩"]' },
  { month: '2024-05', title: '赤铁矿 — 澳大利亚皮尔巴拉', category: 'mineral',
    date_acquired: '2024-05-08', location: 'Perth, Australia',
    story: '皮尔巴拉的赤铁矿以高纯度著称，这块标本表面有标志性的暗红色条痕。在珀斯的一家地质博物馆纪念品店买的，店员说这块赤铁矿形成于二十多亿年前的前寒武纪。拿在手里很沉，能真切感受到地球的古老。',
    image_url: '/uploads/collections/seed-may-03.jpg', tags: '["矿石","赤铁矿","澳大利亚","皮尔巴拉","地质"]' },
  { month: '2024-05', title: '石墨片岩 — 中国云南大理', category: 'mineral',
    date_acquired: '2024-05-12', location: '云南大理',
    story: '在大理苍山脚下的小溪边捡到的石墨片岩。层层叠叠的片状结构像一本石头做的书，每一层都是几亿年地质运动的结果。虽然不是什么名贵矿石，但它是第一次野外采集的成果，比任何商店买的都更有意义。',
    image_url: '/uploads/collections/seed-may-04.jpg', tags: '["矿石","石墨片岩","大理","苍山","野外采集"]' },
  // --- crystal (水晶) x3 (plus existing 玫瑰石英 = 4) ---
  { month: '2024-05', title: '月光石 — 斯里兰卡', category: 'crystal',
    date_acquired: '2024-05-03', location: 'Colombo, Sri Lanka',
    story: '斯里兰卡的月光石在宝石界享有盛誉。这颗月光石在光线下会浮现出淡淡的蓝色光晕，像月光洒在印度洋的海面上。科伦坡的一位宝石商说，好的月光石要看光晕是否"浮"得起来——这块的光晕会在不同角度下流动。',
    image_url: '/uploads/collections/seed-may-05.jpg', tags: '["水晶","月光石","斯里兰卡","宝石","五月"]' },
  { month: '2024-05', title: '海蓝宝石 — 巴基斯坦喀喇昆仑', category: 'crystal',
    date_acquired: '2024-05-07', location: 'Islamabad, Pakistan',
    story: '巴基斯坦喀喇昆仑山脉出产的海蓝宝石以清透的蓝色闻名。这颗六方柱形的晶体颜色从浅蓝渐变到海水蓝，里面可以看到细小的气泡包裹体。放在白色底座上，像一小块凝固的海水。',
    image_url: '/uploads/collections/seed-may-06.jpg', tags: '["水晶","海蓝宝石","巴基斯坦","喀喇昆仑","矿物"]' },
  { month: '2024-05', title: '烟水晶柱 — 瑞士阿尔卑斯', category: 'crystal',
    date_acquired: '2024-05-10', location: 'Zurich, Switzerland',
    story: '在苏黎世一家矿物店里，一眼就看中了这根烟水晶柱。它来自阿尔卑斯山脉的深处，通体是深沉的烟褐色，在强光下会变成温暖的琥珀色。晶体顶端是完美的六方锥形，侧面有清晰的水平生长纹。',
    image_url: '/uploads/collections/seed-may-07.jpg', tags: '["水晶","烟水晶","瑞士","阿尔卑斯","收藏"]' },
  // --- vinyl (黑胶) x4 ---
  { month: '2024-05', title: 'The Beatles — Abbey Road', category: 'vinyl',
    date_acquired: '2024-05-04', location: 'Liverpool, UK',
    story: '在披头士故乡利物浦的一家老唱片店找到的。1969年的经典封面——四人走过斑马线的画面早已成为音乐史上的标志。唱片保存得出奇地好，只有轻微的噼啪声，反而让声音更有温度。Come Together的前奏一响，店里几个陌生人不约而同地点了点头。',
    image_url: '/uploads/collections/seed-may-08.jpg', tags: '["黑胶","The Beatles","披头士","英国","经典摇滚"]' },
  { month: '2024-05', title: 'Billie Holiday — Lady in Satin', category: 'vinyl',
    date_acquired: '2024-05-09', location: 'New Orleans, USA',
    story: '在新奥尔良法国区的一家爵士唱片店淘到的。1958年的录音，是Billie Holiday生前最后几张专辑之一。封面上她穿着缎面礼服，眼神里有种说不出的故事感。放上唱针的那一刻，她沙哑又深情的声音充满了整个房间。',
    image_url: '/uploads/collections/seed-may-09.jpg', tags: '["黑胶","Billie Holiday","爵士","新奥尔良","人声"]' },
  { month: '2024-05', title: 'Bob Dylan — Highway 61 Revisited', category: 'vinyl',
    date_acquired: '2024-05-14', location: 'Minneapolis, USA',
    story: '在明尼阿波利斯的一家独立唱片店找到的1965年原版。封面上Dylan穿着那件标志性的彩虹色衬衫，眼神里满是年轻的反叛。Like A Rolling Stone就是从这张唱片开始改变摇滚乐历史的。',
    image_url: '/uploads/collections/seed-may-10.jpg', tags: '["黑胶","Bob Dylan","民谣摇滚","美国","经典"]' },
  { month: '2024-05', title: 'Radiohead — OK Computer', category: 'vinyl',
    date_acquired: '2024-05-19', location: 'Oxford, UK',
    story: '1997年的神专，在牛津一家唱片店找到的双LP版本。黑色封面上那些扭曲的白色线条，和专辑里描绘的现代疏离感完美契合。在店里试听时正好播到No Surprises，那个叮叮当当的吉他前奏让整个店都安静下来了。',
    image_url: '/uploads/collections/seed-may-11.jpg', tags: '["黑胶","Radiohead","另类摇滚","英国","九十年代"]' },
  // --- postcard (明信片) x4 ---
  { month: '2024-05', title: '巴黎塞纳河畔明信片', category: 'postcard',
    date_acquired: '2024-05-06', location: 'Paris, France',
    story: '五月初的巴黎，塞纳河畔的旧书摊边上有卖老明信片的小贩。这张是1960年代的黑白照片明信片，画面是雨后的塞纳河和远处的圣母院。明信片背面有前任主人写的几行法文，笔迹优雅而匆忙——它让这张明信片有了一段我不知道的故事。',
    image_url: '/uploads/collections/seed-may-12.jpg', tags: '["明信片","巴黎","塞纳河","法国","五月"]' },
  { month: '2024-05', title: '威尼斯水城明信片', category: 'postcard',
    date_acquired: '2024-05-11', location: 'Venice, Italy',
    story: '在威尼斯圣马可广场旁的小巷里，一家开了几十年的明信片店。店主是一位老太太，店里全是她收藏的各地明信片。这张是手绘风格的威尼斯，画面是夕阳下的运河和贡多拉，色调温暖得像威尼斯的黄昏。老太太用意大利味的英语说"this one, special"。',
    image_url: '/uploads/collections/seed-may-13.jpg', tags: '["明信片","威尼斯","意大利","手绘","运河"]' },
  { month: '2024-05', title: '布拉格查理大桥明信片', category: 'postcard',
    date_acquired: '2024-05-16', location: 'Prague, Czech Republic',
    story: '五月中旬的布拉格，查理大桥上的晨雾还没有散尽。桥头的小摊上，一位画家在卖自己画的布拉格明信片。挑了这张铅笔素描风格的查理大桥，画面上圣维特大教堂的尖顶在远处若隐若现。画家在背面用捷克语写了"Krásná Praha"——美丽的布拉格。',
    image_url: '/uploads/collections/seed-may-14.jpg', tags: '["明信片","布拉格","查理大桥","捷克","素描"]' },
  { month: '2024-05', title: '旧金山金门大桥明信片', category: 'postcard',
    date_acquired: '2024-05-20', location: 'San Francisco, USA',
    story: '在旧金山渔人码头的一家纪念品店买的。明信片是日落时分从马林县一侧拍摄的金门大桥，桥身被夕阳染成了橙红色，背景是太平洋无边的蓝色。五月的旧金山海风很大，但日落美得让人不想离开。背后写着：世界很大，能亲眼看到真好。',
    image_url: '/uploads/collections/seed-may-15.jpg', tags: '["明信片","旧金山","金门大桥","美国","日落"]' },
];

async function seed() {
  console.log('Seeding database...');
  const db = await getDb();

  // Clear existing data (order matters due to FK)
  db.run('DELETE FROM collections');
  db.run('DELETE FROM rooms');
  db.run('DELETE FROM categories');
  db.run('DELETE FROM users');
  db.run('DELETE FROM ai_usage_logs');
  db.run("DELETE FROM sqlite_sequence WHERE name IN ('collections', 'users', 'rooms')");

  // --- Insert user ---
  const insertUser = db.prepare('INSERT INTO users (username, email, avatar_url, bio) VALUES (?, ?, ?, ?)');
  insertUser.run(['collector_demo', 'demo@collection-journey.app', '/uploads/avatars/default.png', '热爱收藏生活中的每一个美好瞬间。矿石、唱片、票根、明信片——每件小物背后都有一段旅程。']);
  insertUser.free();
  const userIdResult = db.exec('SELECT last_insert_rowid()');
  const userId = userIdResult[0].values[0][0];
  console.log('  Inserted 1 user (id=' + userId + ')');

  // --- Insert categories ---
  const insertCategory = db.prepare('INSERT INTO categories (id, name, icon, fields, display_priority) VALUES (?, ?, ?, ?, ?)');
  categories.forEach((c) => { insertCategory.run([c.id, c.name, c.icon, c.fields, c.display_priority]); });
  insertCategory.free();
  console.log('  Inserted ' + categories.length + ' categories');

  // --- Insert rooms ---
  const insertRoom = db.prepare('INSERT INTO rooms (month, label) VALUES (?, ?)');
  rooms.forEach((r) => { insertRoom.run([r.month, r.label]); });
  insertRoom.free();
  console.log('  Inserted ' + rooms.length + ' rooms');

  // Build month → room_id map
  const roomRows = db.exec('SELECT id, month FROM rooms');
  const roomMap = {};
  roomRows[0].values.forEach((row) => { roomMap[row[1]] = row[0]; });

  // --- Insert all collections ---
  const allCollections = [...originalCollections, ...newMayCollections];
  const insertCollection = db.prepare(
    'INSERT INTO collections (title, category, date_acquired, location, story, image_url, tags, user_id, visibility, room_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
  );
  let publicCounter = 0;
  allCollections.forEach((c) => {
    const visibility = publicCounter % 3 === 0 ? 'public' : 'private';
    const roomId = roomMap[c.month];
    insertCollection.run([c.title, c.category, c.date_acquired, c.location, c.story, c.image_url, c.tags, userId, visibility, roomId]);
    publicCounter++;
  });
  insertCollection.free();
  console.log('  Inserted ' + allCollections.length + ' collections (' + originalCollections.length + ' original + ' + newMayCollections.length + ' new May)');

  // --- Summary ---
  const mayCount = db.exec("SELECT COUNT(*) FROM collections c JOIN rooms r ON c.room_id = r.id WHERE r.month = '2024-05'");
  console.log('  May 2024 room: ' + mayCount[0].values[0][0] + ' items');

  // Category breakdown for May
  const mayCats = db.exec("SELECT c.category, COUNT(*) FROM collections c JOIN rooms r ON c.room_id = r.id WHERE r.month = '2024-05' GROUP BY c.category ORDER BY COUNT(*) DESC");
  if (mayCats.length) {
    mayCats[0].values.forEach((row) => { console.log('    ' + row[0] + ': ' + row[1]); });
  }

  saveDb();
  closeDb();
  console.log('Seed completed successfully.');
  console.log('Database file: backend/data/collections.db');
}

seed().catch((err) => { console.error('Seed failed:', err); process.exit(1); });
