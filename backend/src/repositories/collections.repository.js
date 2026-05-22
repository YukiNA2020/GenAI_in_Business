const { getDb, saveDb } = require('../db/connection');

async function insert(record) {
  const db = await getDb();

  const fields = [];
  const placeholders = [];
  const values = [];

  const allFields = ['title', 'category', 'date_acquired', 'location', 'story', 'image_url', 'tags', 'user_id', 'visibility', 'category_template', 'custom_fields', 'room_id'];
  for (const f of allFields) {
    if (record[f] !== undefined) {
      fields.push(f);
      placeholders.push('?');
      values.push(record[f]);
    }
  }

  if (fields.length === 0) {
    throw new Error('No fields to insert');
  }

  const sql = `INSERT INTO collections (${fields.join(', ')}) VALUES (${placeholders.join(', ')})`;
  db.run(sql, values);

  // Must get last_insert_rowid BEFORE saveDb() — db.export() resets it to 0
  const result = db.exec('SELECT last_insert_rowid()');
  const lastId = result[0].values[0][0];

  saveDb();

  return await findById(lastId);
}

async function findById(id) {
  const db = await getDb();
  const result = db.exec('SELECT * FROM collections WHERE id = ' + Number(id));
  if (!result.length || !result[0].values.length) return null;
  const cols = result[0].columns;
  const vals = result[0].values[0];
  const row = {};
  cols.forEach((c, i) => { row[c] = vals[i]; });
  return row;
}

function escapeSql(value) {
  return String(value).replace(/'/g, "''");
}

const SORT_MAP = {
  created_desc: 'created_at DESC',
  created_asc: 'created_at ASC',
  date_desc: 'date_acquired DESC',
  date_asc: 'date_acquired ASC',
};

async function findAll({ page = 1, pageSize = 20, keyword, category, tag, sort } = {}) {
  const db = await getDb();

  const offset = (page - 1) * pageSize;
  const orderBy = SORT_MAP[sort] || 'created_at DESC';
  const conditions = [];

  if (keyword) {
    const like = escapeSql(keyword);
    conditions.push(
      `(title LIKE '%${like}%' OR story LIKE '%${like}%' OR location LIKE '%${like}%' OR tags LIKE '%${like}%')`
    );
  }

  if (category) {
    conditions.push(`category = '${escapeSql(category)}'`);
  }

  if (tag) {
    conditions.push(`tags LIKE '%${escapeSql(tag)}%'`);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countSql = `SELECT COUNT(*) FROM collections ${whereClause}`;
  const countResult = db.exec(countSql);
  const total = countResult[0].values[0][0];

  const dataSql = `SELECT * FROM collections ${whereClause} ORDER BY ${orderBy} LIMIT ${pageSize} OFFSET ${offset}`;
  const result = db.exec(dataSql);

  if (!result.length || !result[0].values.length) {
    return { items: [], total };
  }

  const cols = result[0].columns;
  const items = result[0].values.map((vals) => {
    const row = {};
    cols.forEach((c, i) => { row[c] = vals[i]; });
    return row;
  });

  return { items, total };
}

async function update(id, changes) {
  const db = await getDb();

  const setClauses = [];
  const values = [];

  const updatableFields = ['title', 'category', 'date_acquired', 'location', 'story', 'image_url', 'tags', 'user_id', 'visibility', 'category_template', 'custom_fields', 'room_id'];
  for (const f of updatableFields) {
    if (changes[f] !== undefined) {
      setClauses.push(`${f} = ?`);
      values.push(changes[f]);
    }
  }

  if (setClauses.length === 0) return await findById(id);

  setClauses.push("updated_at = datetime('now')");
  values.push(id);

  const sql = `UPDATE collections SET ${setClauses.join(', ')} WHERE id = ?`;
  db.run(sql, values);
  saveDb();

  return await findById(id);
}

async function remove(id) {
  const db = await getDb();
  const exists = db.exec('SELECT id FROM collections WHERE id = ' + Number(id));
  if (!exists.length || !exists[0].values.length) return false;
  db.run('DELETE FROM collections WHERE id = ' + Number(id));
  saveDb();
  return true;
}

module.exports = { insert, findById, findAll, update, remove };
