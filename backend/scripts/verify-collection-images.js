/**
 * 检查 collections.db 的 image_url 是否能在磁盘上找到对应文件。
 * 用法: node scripts/verify-collection-images.js
 */
const fs = require('fs');
const path = require('path');
const { getDb, closeDb } = require('../src/db/connection');

async function main() {
  const db = await getDb();
  const result = db.exec(
    'SELECT id, title, image_url FROM collections ORDER BY id',
  );
  if (!result.length) {
    console.log('No collections in database.');
    closeDb();
    return;
  }

  const rows = result[0].values;
  let ok = 0;
  let missing = 0;
  let empty = 0;

  console.log(`Checking ${rows.length} collections...\n`);

  for (const [id, title, imageUrl] of rows) {
    if (!imageUrl) {
      empty += 1;
      console.log(`[${id}] NO image_url — ${title}`);
      continue;
    }
    if (
      imageUrl.startsWith('http://') ||
      imageUrl.startsWith('https://')
    ) {
      console.log(`[${id}] external URL — ${imageUrl}`);
      ok += 1;
      continue;
    }
    const rel = imageUrl.replace(/^\/+/, '').replace(/\\/g, '/');
    const filePath = path.join(__dirname, '..', rel);
    if (fs.existsSync(filePath)) {
      const stat = fs.statSync(filePath);
      console.log(`[${id}] OK (${stat.size} bytes) — ${imageUrl}`);
      ok += 1;
    } else {
      console.log(`[${id}] MISSING FILE — ${imageUrl} — ${title}`);
      missing += 1;
    }
  }

  console.log(`\nSummary: ${ok} ok, ${missing} missing file, ${empty} no url`);
  closeDb();
  process.exit(missing > 0 ? 1 : 0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
