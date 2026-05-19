const { getDb } = require('../db/connection');

async function findById(id) {
  const db = await getDb();
  const result = db.exec('SELECT * FROM users WHERE id = ' + Number(id));
  if (!result.length || !result[0].values.length) return null;
  const cols = result[0].columns;
  const vals = result[0].values[0];
  const row = {};
  cols.forEach((c, i) => { row[c] = vals[i]; });
  return row;
}

async function getStats(userId) {
  const db = await getDb();
  const uid = Number(userId);

  const totalResult = db.exec('SELECT COUNT(*) FROM collections WHERE user_id = ' + uid);
  const totalCollections = totalResult[0].values[0][0];

  const catResult = db.exec(
    'SELECT COUNT(DISTINCT category) FROM collections WHERE user_id = ' + uid + ' AND category IS NOT NULL'
  );
  const categoryCount = catResult[0].values[0][0];

  const recentResult = db.exec(
    'SELECT * FROM collections WHERE user_id = ' + uid + ' ORDER BY created_at DESC LIMIT 5'
  );
  let recentCollections = [];
  if (recentResult.length && recentResult[0].values.length) {
    const cols = recentResult[0].columns;
    recentCollections = recentResult[0].values.map((vals) => {
      const row = {};
      cols.forEach((c, i) => { row[c] = vals[i]; });
      return row;
    });
  }

  const publicResult = db.exec(
    "SELECT COUNT(*) FROM collections WHERE user_id = " + uid + " AND visibility = 'public'"
  );
  const publicCollections = publicResult[0].values[0][0];

  return { totalCollections, categoryCount, recentCollections, publicCollections };
}

module.exports = { findById, getStats };
