const { getDb } = require('../db/connection');

/** YYYY-MM from date_acquired or created_at — matches rooms.month */
const COLLECTION_MONTH_SQL =
  "strftime('%Y-%m', COALESCE(collections.date_acquired, collections.created_at))";

async function findAll() {
  const db = await getDb();
  const result = db.exec(`
    SELECT
      rooms.*,
      COUNT(collections.id) AS collection_count
    FROM rooms
    LEFT JOIN collections ON ${COLLECTION_MONTH_SQL} = rooms.month
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
  const room = await findById(roomId);
  if (!room) return [];
  const month = String(room.month).replace(/'/g, "''");
  const result = db.exec(
    `SELECT * FROM collections WHERE ${COLLECTION_MONTH_SQL} = '${month}' ORDER BY created_at DESC`
  );
  if (!result.length || !result[0].values.length) return [];
  const cols = result[0].columns;
  return result[0].values.map((vals) => {
    const row = {};
    cols.forEach((c, i) => { row[c] = vals[i]; });
    return row;
  });
}

module.exports = { findAll, findById, findByMonth, getCollectionsByRoomId };
