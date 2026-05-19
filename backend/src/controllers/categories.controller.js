const service = require('../services/categories.service');
const { success, error } = require('../utils/response');

async function listCategories(_req, res, next) {
  try {
    const categories = await service.list();
    return success(res, categories);
  } catch (err) {
    next(err);
  }
}

async function getCategory(req, res, next) {
  try {
    const category = await service.getById(req.params.id);
    if (!category) {
      return error(res, 'NOT_FOUND', 'Category not found', 404);
    }
    return success(res, category);
  } catch (err) {
    next(err);
  }
}

module.exports = { listCategories, getCategory };
