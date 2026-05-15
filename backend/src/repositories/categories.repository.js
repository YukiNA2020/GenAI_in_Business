const { getDb, saveDb } = require('../db/connection');

async function findAll() {
  const db = await getDb();
  const result = db.exec('SELECT * FROM categories ORDER BY display_priority ASC');
  if (!result.length || !result[0].values.length) return [];
  const cols = result[0].columns;
  return result[0].values.map((vals) => {
    const row = {};
    cols.forEach((c, i) => { row[c] = vals[i]; });
    return row;
  });
}

async function findById(id) {
  const db = await getDb();
  const safeId = String(id).replace(/'/g, "''");
  const result = db.exec(`SELECT * FROM categories WHERE id = '${safeId}'`);
  if (!result.length || !result[0].values.length) return null;
  const cols = result[0].columns;
  const vals = result[0].values[0];
  const row = {};
  cols.forEach((c, i) => { row[c] = vals[i]; });
  return row;
}

module.exports = { findAll, findById };
