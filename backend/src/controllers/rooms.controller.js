const service = require('../services/rooms.service');
const { success, error } = require('../utils/response');

async function listRooms(_req, res, next) {
  try {
    const rooms = await service.list();
    return success(res, rooms);
  } catch (err) {
    next(err);
  }
}

async function getRoom(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return error(res, 'INVALID_ID', 'Room id must be a number', 400);
    }
    const room = await service.getById(id);
    if (!room) {
      return error(res, 'NOT_FOUND', 'Room not found', 404);
    }
    return success(res, room);
  } catch (err) {
    next(err);
  }
}

module.exports = { listRooms, getRoom };