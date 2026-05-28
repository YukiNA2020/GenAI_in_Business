const repo = require('../repositories/collections.repository');
const roomsRepo = require('../repositories/rooms.repository');

const FIELD_MAP = {
  dateAcquired: 'date_acquired',
  imageUrl: 'image_url',
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  userId: 'user_id',
  categoryTemplate: 'category_template',
  customFields: 'custom_fields',
  roomId: 'room_id',
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

async function assertRoomExists(roomId) {
  if (roomId === undefined || roomId === null) return;
  const room = await roomsRepo.findById(roomId);
  if (!room) {
    const err = new Error('Room not found');
    err.code = 'ROOM_NOT_FOUND';
    err.statusCode = 404;
    throw err;
  }
}

/** Assign room from dateAcquired YYYY-MM when a matching room exists. */
async function resolveRoomIdFromDate(dateAcquired) {
  if (!dateAcquired || typeof dateAcquired !== 'string') return undefined;
  const match = dateAcquired.match(/^(\d{4}-\d{2})/);
  if (!match) return undefined;
  const room = await roomsRepo.findByMonth(match[1]);
  return room ? room.id : undefined;
}

async function applyRoomFromDate(apiData) {
  const roomId = await resolveRoomIdFromDate(apiData.dateAcquired);
  if (roomId !== undefined) {
    apiData.roomId = roomId;
  }
  return apiData;
}

async function create(data) {
  await applyRoomFromDate(data);
  await assertRoomExists(data.roomId);
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
  if (data.dateAcquired !== undefined) {
    await applyRoomFromDate(data);
  }
  await assertRoomExists(data.roomId);
  const changes = toSnakeCase(data);
  // Per API Contract: roomId=null means "don't change", not "clear"
  if (changes.room_id === null) {
    delete changes.room_id;
  }
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
