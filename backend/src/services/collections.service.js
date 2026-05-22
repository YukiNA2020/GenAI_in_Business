const repo = require('../repositories/collections.repository');

const FIELD_MAP = {
  dateAcquired: 'date_acquired',
  imageUrl: 'image_url',
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  userId: 'user_id',
  categoryTemplate: 'category_template',
  customFields: 'custom_fields',
};

function toSnakeCase(apiData) {
  const record = {};
  for (const [key, value] of Object.entries(apiData)) {
    const dbKey = FIELD_MAP[key] || key;
    record[dbKey] = value;
  }
  if (Array.isArray(record.tags)) {
    record.tags = JSON.stringify(record.tags);
  }
  return record;
}

function toCamelCase(dbRow) {
  if (!dbRow) return null;
  const reverseMap = {};
  for (const [camel, snake] of Object.entries(FIELD_MAP)) {
    reverseMap[snake] = camel;
  }
  const result = {};
  for (const [key, value] of Object.entries(dbRow)) {
    const apiKey = reverseMap[key] || key;
    result[apiKey] = value;
  }
  if (typeof result.tags === 'string') {
    try {
      result.tags = JSON.parse(result.tags);
    } catch {
      result.tags = [];
    }
  }
  if (!Array.isArray(result.tags)) {
    result.tags = [];
  }
  return result;
}

async function create(data) {
  const record = toSnakeCase(data);
  const created = await repo.insert(record);
  return toCamelCase(created);
}

async function list({ page, pageSize, keyword, category, tag, sort, visibility, year, month } = {}) {
  const { items, total } = await repo.findAll({
    page,
    pageSize,
    keyword,
    category,
    tag,
    sort,
    visibility,
    year,
    month,
  });
  return {
    items: items.map(toCamelCase),
    total,
    page: Number(page) || 1,
    pageSize: Number(pageSize) || 20,
  };
}

async function getById(id) {
  const row = await repo.findById(id);
  return toCamelCase(row);
}

async function update(id, data) {
  const exists = await repo.findById(id);
  if (!exists) return null;
  const changes = toSnakeCase(data);
  const updated = await repo.update(id, changes);
  return toCamelCase(updated);
}

async function remove(id) {
  const exists = await repo.findById(id);
  if (!exists) return false;
  return await repo.remove(id);
}

async function listDistinctTags() {
  return repo.findDistinctTags();
}

module.exports = { create, list, getById, update, remove, listDistinctTags };
