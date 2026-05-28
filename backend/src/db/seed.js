const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const { getDb, saveDb, closeDb } = require('./connection');

const CATEGORY_COLORS = {
  crystal: [216, 209, 232],
  mineral: [85, 116, 106],
  vinyl: [199, 166, 121],
  ticket: [201, 130, 80],
  postcard: [201, 217, 213],
  souvenir: [232, 220, 200],
  stamp: [212, 198, 176],
  other: [235, 228, 216],
};

function crc32(buf) {
  let crc = 0xffffffff;
  if (!crc32.table) {
    crc32.table = new Uint32Array(256);
    for (let i = 0; i < 256; i += 1) {
      let c = i;
      for (let k = 0; k < 8; k += 1) {
        c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      }
      crc32.table[i] = c;
    }
  }
  for (let i = 0; i < buf.length; i += 1) {
    crc = crc32.table[(crc ^ buf[i]) & 0xff] ^ (crc >>> 8);
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data) {
  const typeBuf = Buffer.from(type, 'ascii');
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const payload = Buffer.concat([typeBuf, data]);
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(payload), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

/** Solid-color PNG for seed thumbnails (visible in gallery cards). */
function createSolidPng(width, height, rgb) {
  const [r, g, b] = rgb;
  const stride = width * 3 + 1;
  const raw = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y += 1) {
    const row = y * stride;
    raw[row] = 0;
    for (let x = 0; x < width; x += 1) {
      const i = row + 1 + x * 3;
      raw[i] = r;
      raw[i + 1] = g;
      raw[i + 2] = b;
    }
  }
  const compressed = zlib.deflateSync(raw, { level: 9 });
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;
  return Buffer.concat([
    signature,
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', compressed),
    pngChunk('IEND', Buffer.alloc(0)),
  ]);
}

/** Write `collections[].image_url` files under uploads/collections/ */
function ensureSeedUploadAssets(collections) {
  const uploadsRoot = path.join(__dirname, '..', '..', 'uploads');
  const collectionsDir = path.join(uploadsRoot, 'collections');
  const avatarsDir = path.join(uploadsRoot, 'avatars');
  fs.mkdirSync(collectionsDir, { recursive: true });
  fs.mkdirSync(avatarsDir, { recursive: true });

  collections.forEach((c, index) => {
    const rgb = CATEGORY_COLORS[c.category] || CATEGORY_COLORS.other;
    const png = createSolidPng(480, 360, rgb);
    const file = path.join(
      collectionsDir,
      `seed-${String(index + 1).padStart(2, '0')}.png`,
    );
    fs.writeFileSync(file, png);
    c.image_url = `/uploads/collections/seed-${String(index + 1).padStart(2, '0')}.png`;
  });

  const avatarPath = path.join(avatarsDir, 'default.png');
  if (!fs.existsSync(avatarPath)) {
    fs.writeFileSync(avatarPath, createSolidPng(64, 64, [168, 100, 58]));
  }

  console.log(`  Wrote ${collections.length} collection seed image(s) (480×360 PNG)`);
}

const seedData = {
  users: [
    {
      username: 'collector_demo',
      email: 'demo@collection-journey.app',
      avatar_url: '/uploads/avatars/default.png',
      bio: 'Collecting small objects that carry memory—minerals, vinyl, tickets, and postcards from everyday journeys.',
    },
  ],

  categories: [
    { id: 'mineral', name: 'Minerals', icon: 'diamond', fields: '["weight","size","origin","color"]', display_priority: 1 },
    { id: 'crystal', name: 'Crystals', icon: 'auto_awesome', fields: '["type","color","origin","uses"]', display_priority: 2 },
    { id: 'vinyl', name: 'Vinyl Records', icon: 'album', fields: '["artist","album","year","genre"]', display_priority: 3 },
    { id: 'postcard', name: 'Postcards', icon: 'mail', fields: '["from","to","postmark_date"]', display_priority: 4 },
    { id: 'ticket', name: 'Tickets', icon: 'confirmation_number', fields: '["event","venue","date","seat"]', display_priority: 5 },
    { id: 'souvenir', name: 'Travel Souvenirs', icon: 'flight_takeoff', fields: '["destination","trip_date","material"]', display_priority: 6 },
    { id: 'stamp', name: 'Stamps', icon: 'stamp', fields: '["country","year","denomination"]', display_priority: 7 },
    { id: 'other', name: 'Other Collections', icon: 'favorite', fields: '[]', display_priority: 99 },
  ],

  collections: [
    {
      title: 'Amethyst cluster — Argentina',
      category: 'crystal',
      date_acquired: '2026-05-03',
      location: 'Buenos Aires, Argentina',
      story: 'Found this amethyst cluster in a small mineral shop on a side street in Buenos Aires. The owner, a silver-haired gentleman, spent twenty minutes explaining where it was mined. Under the lamp the crystals throw a soft violet glow; every time I see it I remember that quiet afternoon.',
      image_url: '/uploads/collections/seed-01.png',
      tags: '["crystal","amethyst","Argentina","travel","nature"]',
    },
    {
      title: 'Fluorite cube — Chenzhou',
      category: 'mineral',
      date_acquired: '2026-05-05',
      location: 'Chenzhou, China',
      story: 'This fluorite came from a mine near Chenzhou, with green and purple bands across cubic faces. I bought it at my first mineral show; the seller told how it was extracted. The green zones are fluorine-rich; manganese tints the purple layers.',
      image_url: '/uploads/collections/seed-02.png',
      tags: '["mineral","fluorite","Chenzhou","mineral show","China"]',
    },
    {
      title: 'Pink Floyd — The Dark Side of the Moon',
      category: 'vinyl',
      date_acquired: '2026-05-07',
      location: 'London, UK',
      story: 'A 1973 UK pressing from a Notting Hill second-hand shop. The prism cover has yellowed slightly but the vinyl is remarkably clean. The shopkeeper said it once belonged to a retired BBC engineer. Playing it still fills the room with warm analog sound.',
      image_url: '/uploads/collections/seed-03.png',
      tags: '["vinyl","Pink Floyd","rock","classic","UK"]',
    },
    {
      title: 'Kinkaku-ji postcard',
      category: 'postcard',
      date_acquired: '2026-05-08',
      location: 'Kyoto, Japan',
      story: 'Mailed to myself from the post office by Kinkaku-ji during spring break. The pavilion mirrored in the pond made time feel slower. I scribbled a short poem on the back—awkward Japanese, but honest.',
      image_url: '/uploads/collections/seed-04.png',
      tags: '["postcard","Kyoto","Kinkaku-ji","Japan","travel"]',
    },
    {
      title: 'Ryuichi Sakamoto concert stub — Tokyo',
      category: 'ticket',
      date_acquired: '2026-05-09',
      location: 'Tokyo, Japan',
      story: 'At Tokyo Opera City he played Merry Christmas Mr. Lawrence. The hall was so still you could hear only the piano. The stub still shows the handwritten seat number and a light crease from the usher’s tear.',
      image_url: '/uploads/collections/seed-05.png',
      tags: '["ticket","concert","Sakamoto","Tokyo","music"]',
    },
    {
      title: 'Black sand pebbles — Iceland',
      category: 'souvenir',
      date_acquired: '2026-05-10',
      location: 'Reynisfjara, Iceland',
      story: 'Smooth black pebbles from Reynisfjara beach, polished by North Atlantic surf. Basalt columns rose behind me while the wind stung my eyes. They have rested in my box ever since, cool reminders of a beach at the edge of the world.',
      image_url: '/uploads/collections/seed-06.png',
      tags: '["souvenir","Iceland","black sand","nature","pebble"]',
    },
    {
      title: 'Pyrite sun — Peru',
      category: 'mineral',
      date_acquired: '2026-05-11',
      location: 'Lima, Peru',
      story: 'Bought at a mineral market in Lima. Peruvian pyrite is famous for its metallic shine; this disc looks like a tiny sun. Cubic crystal hints catch the light whenever I lift it from the shelf.',
      image_url: '/uploads/collections/seed-07.png',
      tags: '["mineral","pyrite","Peru","travel","specimen"]',
    },
    {
      title: 'West Lake Leifeng Pagoda postcard',
      category: 'postcard',
      date_acquired: '2026-05-12',
      location: 'Hangzhou, China',
      story: 'Picked up below Leifeng Pagoda during a crowded holiday weekend in Hangzhou. The card shows the pagoda and West Lake at sunset. I have visited many times, yet the light on the water is never quite the same.',
      image_url: '/uploads/collections/seed-08.png',
      tags: '["postcard","West Lake","Hangzhou","China","travel"]',
    },
    {
      title: 'Miles Davis — Kind of Blue',
      category: 'vinyl',
      date_acquired: '2026-05-14',
      location: 'New York, USA',
      story: 'Found in a Greenwich Village jazz shop: a 1959 pressing with a faded blue sleeve and barely played grooves. The owner said it came from an old musician’s estate, with a note inside reading “for the quiet nights”.',
      image_url: '/uploads/collections/seed-09.png',
      tags: '["vinyl","jazz","Miles Davis","USA","classic"]',
    },
    {
      title: 'Shanghai International Film Festival ticket',
      category: 'ticket',
      date_acquired: '2026-05-15',
      location: 'Shanghai, China',
      story: 'A restored black-and-white Fellini film at the Grand Cinema. Middle seat on the balcony, perfect view. Afterward we talked for hours in a café while rain fell on the street—this stub marks that night.',
      image_url: '/uploads/collections/seed-10.png',
      tags: '["ticket","film festival","Shanghai","cinema","Fellini"]',
    },
    {
      title: 'Rose quartz — Madagascar',
      category: 'crystal',
      date_acquired: '2026-05-16',
      location: 'Antananarivo, Madagascar',
      story: 'Madagascar rose quartz in a natural hexagonal column, soft pink in daylight. Locals call it a love stone; to me it is quiet company on the desk—I smile whenever my eyes pass over it.',
      image_url: '/uploads/collections/seed-11.png',
      tags: '["crystal","rose quartz","Madagascar","travel","nature"]',
    },
    {
      title: 'Geirangerfjord cruise magnet',
      category: 'souvenir',
      date_acquired: '2026-05-18',
      location: 'Geirangerfjord, Norway',
      story: 'A fridge magnet from a fjord cruise: cliffs, waterfalls, and the Norwegian flag on the print. It still sits on my refrigerator door and brings back a cool Nordic summer.',
      image_url: '/uploads/collections/seed-12.png',
      tags: '["souvenir","Norway","fjord","cruise","Nordic"]',
    },
    {
      title: '1980s Chinese zodiac stamp — Dragon',
      category: 'stamp',
      date_acquired: '2026-05-20',
      location: 'Beijing, China',
      story: 'A first-issue dragon stamp from Panjiayuan market, slightly yellowed but crisp. The seller said his father kept it in an album. Not the rarest stamp, yet it matches my birth year—a small coincidence worth keeping.',
      image_url: '/uploads/collections/seed-13.png',
      tags: '["stamp","zodiac","dragon","China","collecting"]',
    },
    {
      title: 'Dried lavender bundle — Provence',
      category: 'souvenir',
      date_acquired: '2026-05-22',
      location: 'Provence, France',
      story: 'Fresh-cut lavender from a field that looked like a purple sea. A farmer in a straw hat sold the bundle; she wished me bon voyage. It is fully dry now but still scents the wardrobe when I open the door.',
      image_url: '/uploads/collections/seed-14.png',
      tags: '["souvenir","lavender","France","Provence","summer"]',
    },
    {
      title: 'Azurite with malachite — Congo',
      category: 'mineral',
      date_acquired: '2026-05-25',
      location: 'Kinshasa, Congo',
      story: 'Deep blue azurite embedded in green malachite matrix, like a natural abstract painting from a Congolese copper district. A geologist friend brought it back; guests always ask about the striking color contrast.',
      image_url: '/uploads/collections/seed-15.png',
      tags: '["mineral","azurite","malachite","Congo","nature"]',
    },
  ],

  rooms: [
    { month: '2026-03', label: 'March Room' },
    { month: '2026-04', label: 'April Room' },
    { month: '2026-05', label: 'May Room' },
  ],
};

async function seed() {
  console.log('Seeding database...');

  ensureSeedUploadAssets(seedData.collections);

  const db = await getDb();

  // Clear existing data
  db.run('DELETE FROM collections');
  db.run('DELETE FROM categories');
  db.run('DELETE FROM users');
  db.run('DELETE FROM rooms');

  // Reset AUTOINCREMENT counters
  db.run("DELETE FROM sqlite_sequence WHERE name IN ('collections', 'users', 'rooms')");

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

  // Insert rooms first to get their IDs
  const insertRoom = db.prepare(
    'INSERT INTO rooms (month, label) VALUES (?, ?)'
  );
  const roomMonthToId = {};
  seedData.rooms.forEach((r) => {
    insertRoom.run([r.month, r.label]);
    const idResult = db.exec('SELECT last_insert_rowid()');
    roomMonthToId[r.month] = idResult[0].values[0][0];
  });
  insertRoom.free();
  console.log(`  Inserted ${seedData.rooms.length} rooms`);

  // Insert collections with room assignment
  const insertCollection = db.prepare(
    `INSERT INTO collections (title, category, date_acquired, location, story, image_url, tags, user_id, visibility, room_id)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  );
  seedData.collections.forEach((c, i) => {
    const visibility = i % 3 === 0 ? 'public' : 'private';
    // Extract YYYY-MM from date_acquired
    const dateMatch = c.date_acquired.match(/^(\d{4}-\d{2})/);
    const roomMonth = dateMatch ? dateMatch[1] : null;
    const roomId = roomMonth ? (roomMonthToId[roomMonth] || null) : null;
    insertCollection.run([
      c.title, c.category, c.date_acquired, c.location,
      c.story, c.image_url, c.tags, userId, visibility, roomId,
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
