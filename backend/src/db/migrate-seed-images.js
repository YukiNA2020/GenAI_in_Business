const { getDb, saveDb } = require('./connection');

/** Sync DB `image_url` to `.png` seed files (safe after `npm run seed`). */
async function migrateSeedImagePaths() {
  const db = await getDb();
  db.run(
    `UPDATE collections
     SET image_url = REPLACE(image_url, '.jpg', '.png')
     WHERE image_url LIKE '/uploads/collections/seed-%.jpg'`,
  );
  saveDb();
}

module.exports = { migrateSeedImagePaths };
