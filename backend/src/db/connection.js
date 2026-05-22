const initSqlJs = require('sql.js');
const fs = require('fs');
const path = require('path');

let db = null;
let SQL = null;

const DB_PATH = path.join(__dirname, '..', '..', 'data', 'collections.db');

async function getDb() {
  if (db) return db;

  SQL = await initSqlJs();

  // Load existing database file or create new one
  if (fs.existsSync(DB_PATH)) {
    const buffer = fs.readFileSync(DB_PATH);
    db = new SQL.Database(buffer);
  } else {
    db = new SQL.Database();
  }

  // Run schema (safe to re-run: IF NOT EXISTS + duplicate column catches)
  const schemaPath = path.join(__dirname, 'schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf-8');

  // Strip comments, split by semicolons, run each statement
  const cleanSchema = schema
    .split('\n')
    .filter(line => !line.trim().startsWith('--'))
    .join('\n');
  const statements = cleanSchema
    .split(/;\s*\n/)
    .map(s => s.trim())
    .filter(s => s.length > 0);

  for (const stmt of statements) {
    try {
      db.run(stmt + ';');
    } catch (err) {
      // ALTER TABLE ADD COLUMN duplicate → safe to ignore
      if (err.message && err.message.includes('duplicate column name')) {
        continue;
      }
      throw err;
    }
  }

  saveDb();
  return db;
}

function saveDb() {
  if (!db) return;
  const data = db.export();
  const buffer = Buffer.from(data);
  fs.mkdirSync(path.dirname(DB_PATH), { recursive: true });
  fs.writeFileSync(DB_PATH, buffer);
}

function closeDb() {
  if (db) {
    db.close();
    db = null;
  }
}

module.exports = { getDb, saveDb, closeDb };
