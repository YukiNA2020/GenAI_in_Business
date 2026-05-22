const service = require('../services/users.service');
const { success, error } = require('../utils/response');

async function getStats(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return error(res, 'INVALID_ID', 'User id must be a number', 400);
    }

    const stats = await service.getStats(id);
    if (!stats) {
      return error(res, 'NOT_FOUND', 'User not found', 404);
    }

    return success(res, stats);
  } catch (err) {
    next(err);
  }
}

module.exports = { getStats };
