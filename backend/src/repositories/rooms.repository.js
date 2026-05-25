const { getDb } = require('../db/connection');

async function findAll() {
  const db = await getDb();
  const result = db.exec(`
    SELECT
      rooms.*,
      COUNT(collections.id) AS collection_count
    FROM rooms
    LEFT JOIN collections ON collections.room_id = rooms.id
    GROUP BY rooms.id
    ORDER BY rooms.month DESC
  `);
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
  const result = db.exec('SELECT * FROM rooms WHERE id = ' + Number(id));
  if (!result.length || !result[0].values.length) return null;
  const cols = result[0].columns;
  const vals = result[0].values[0];
  const row = {};
  cols.forEach((c, i) => { row[c] = vals[i]; });
  return row;
}

async function findByMonth(month) {
  const db = await getDb();
  const result = db.exec("SELECT * FROM rooms WHERE month = '" + month.replace(/'/g, "''") + "'");
  if (!result.length || !result[0].values.length) return null;
  const cols = result[0].columns;
  const vals = result[0].values[0];
  const row = {};
  cols.forEach((c, i) => { row[c] = vals[i]; });
  return row;
}

async function getCollectionsByRoomId(roomId) {
  const db = await getDb();
  const result = db.exec('SELECT * FROM collections WHERE room_id = ' + Number(roomId) + ' ORDER BY created_at DESC');
  if (!result.length || !result[0].values.length) return [];
  const cols = result[0].columns;
  return result[0].values.map((vals) => {
    const row = {};
    cols.forEach((c, i) => { row[c] = vals[i]; });
    return row;
  });
}

module.exports = { findAll, findById, findByMonth, getCollectionsByRoomId };
