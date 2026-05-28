const repo = require('../repositories/categories.repository');

const FIELD_MAP = {
  display_priority: 'displayPriority',
  created_at: 'createdAt',
};

function toCamelCase(dbRow) {
  if (!dbRow) return null;
  const result = {};
  for (const [key, value] of Object.entries(dbRow)) {
    const apiKey = FIELD_MAP[key] || key;
    result[apiKey] = value;
  }
  if (typeof result.fields === 'string') {
    try {
      result.fields = JSON.parse(result.fields);
    } catch {
      result.fields = [];
    }
  }
  return result;
}

async function list() {
  const rows = await repo.findAll();
  return rows.map(toCamelCase);
}

async function getById(id) {
  const row = await repo.findById(id);
  return toCamelCase(row);
}

module.exports = { list, getById };
