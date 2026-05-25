const repo = require('../repositories/rooms.repository');

async function list() {
  const rooms = await repo.findAll();
  return rooms.map((r) => ({
    id: r.id,
    month: r.month,
    label: r.label,
    createdAt: r.created_at,
    collectionCount: r.collection_count,
  }));
}

async function getById(id) {
  const room = await repo.findById(id);
  if (!room) return null;
  const collections = await repo.getCollectionsByRoomId(id);
  return {
    id: room.id,
    month: room.month,
    label: room.label,
    createdAt: room.created_at,
    collections: collections.map((c) => ({
      id: c.id,
      title: c.title,
      category: c.category,
      dateAcquired: c.date_acquired,
      location: c.location,
      story: c.story,
      imageUrl: c.image_url,
      tags: (() => { try { return JSON.parse(c.tags); } catch { return []; } })(),
      userId: c.user_id,
      visibility: c.visibility,
      categoryTemplate: c.category_template,
      customFields: c.custom_fields,
      roomId: c.room_id,
      createdAt: c.created_at,
      updatedAt: c.updated_at,
    })),
  };
}

module.exports = { list, getById };
