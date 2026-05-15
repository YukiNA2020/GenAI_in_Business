const service = require('../services/collections.service');
const { success, created, error } = require('../utils/response');
const path = require('path');
const fs = require('fs');

async function createCollection(req, res, next) {
  try {
    const collection = await service.create(req.validatedBody);
    return created(res, collection, 'Collection created');
  } catch (err) {
    next(err);
  }
}

async function listCollections(req, res, next) {
  try {
    const { page, pageSize, keyword, category, tag, sort } = req.query;
    const data = await service.list({ page, pageSize, keyword, category, tag, sort });
    return success(res, data);
  } catch (err) {
    next(err);
  }
}

async function getCollection(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return error(res, 'INVALID_ID', 'Collection id must be a number', 400);
    }
    const collection = await service.getById(id);
    if (!collection) {
      return error(res, 'NOT_FOUND', 'Collection not found', 404);
    }
    return success(res, collection);
  } catch (err) {
    next(err);
  }
}

async function updateCollection(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return error(res, 'INVALID_ID', 'Collection id must be a number', 400);
    }
    const collection = await service.update(id, req.validatedBody);
    if (!collection) {
      return error(res, 'NOT_FOUND', 'Collection not found', 404);
    }
    return success(res, collection, 'Collection updated');
  } catch (err) {
    next(err);
  }
}

async function deleteCollection(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return error(res, 'INVALID_ID', 'Collection id must be a number', 400);
    }
    const deleted = await service.remove(id);
    if (!deleted) {
      return error(res, 'NOT_FOUND', 'Collection not found', 404);
    }
    return success(res, null, 'Collection deleted');
  } catch (err) {
    next(err);
  }
}

async function uploadImage(req, res, next) {
  try {
    if (!req.file) {
      return error(res, 'NO_FILE', 'No image file provided or unsupported file type', 400);
    }

    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      if (req.file) fs.unlinkSync(req.file.path);
      return error(res, 'INVALID_ID', 'Collection id must be a number', 400);
    }

    const collection = await service.getById(id);
    if (!collection) {
      if (req.file) fs.unlinkSync(req.file.path);
      return error(res, 'NOT_FOUND', 'Collection not found', 404);
    }

    if (collection.imageUrl) {
      const oldPath = path.join(__dirname, '..', '..', collection.imageUrl);
      try { fs.unlinkSync(oldPath); } catch { /* old file may not exist */ }
    }

    const imageUrl = `/uploads/collections/${req.file.filename}`;
    const updated = await service.update(id, { imageUrl });
    return success(res, updated, 'Image uploaded');
  } catch (err) {
    next(err);
  }
}

async function deleteImage(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return error(res, 'INVALID_ID', 'Collection id must be a number', 400);
    }

    const collection = await service.getById(id);
    if (!collection) {
      return error(res, 'NOT_FOUND', 'Collection not found', 404);
    }

    if (!collection.imageUrl) {
      return error(res, 'NO_IMAGE', 'Collection has no image to delete', 400);
    }

    const filePath = path.join(__dirname, '..', '..', collection.imageUrl);
    try {
      fs.unlinkSync(filePath);
    } catch {
      return error(res, 'FILE_NOT_FOUND', 'Image file not found on disk, but database record cleared', 404);
    }

    await service.update(id, { imageUrl: null });
    return success(res, null, 'Image deleted');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createCollection, listCollections, getCollection,
  updateCollection, deleteCollection, uploadImage, deleteImage,
};
