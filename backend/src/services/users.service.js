const repo = require('../repositories/users.repository');

const FIELD_MAP = {
  date_acquired: 'dateAcquired',
  image_url: 'imageUrl',
  created_at: 'createdAt',
  updated_at: 'updatedAt',
  user_id: 'userId',
  category_template: 'categoryTemplate',
  custom_fields: 'customFields',
};

function toCamelCase(dbRow) {
  if (!dbRow) return null;
  const result = {};
  for (const [key, value] of Object.entries(dbRow)) {
    const apiKey = FIELD_MAP[key] || key;
    result[apiKey] = value;
  }
  if (typeof result.tags === 'string') {
    try {
      result.tags = JSON.parse(result.tags);
    } catch {
      result.tags = [];
    }
  }
  return result;
}

async function getStats(userId) {
  const exists = await repo.findById(userId);
  if (!exists) return null;

  const stats = await repo.getStats(userId);
  return {
    totalCollections: stats.totalCollections,
    categoryCount: stats.categoryCount,
    publicCollections: stats.publicCollections,
    recentCollections: stats.recentCollections.map(toCamelCase),
  };
}

module.exports = { getStats };
