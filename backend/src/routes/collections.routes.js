const { Router } = require('express');
const { z } = require('zod');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { validate } = require('../middlewares/validate.middleware');
const controller = require('../controllers/collections.controller');

const router = Router();

// Ensure uploads/collections directory exists
const uploadsDir = path.join(__dirname, '..', '..', 'uploads', 'collections');
fs.mkdirSync(uploadsDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `collection-${req.params.id}-${Date.now()}${ext}`);
  },
});

const fileFilter = (_req, file, cb) => {
  const allowed = /\.(jpg|jpeg|png|gif|webp)$/i;
  const ext = path.extname(file.originalname);
  cb(null, allowed.test(ext));
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });

const createSchema = z.object({
  title: z.string({ required_error: 'title is required' }).min(1, 'title is required'),
  category: z.string().optional(),
  dateAcquired: z.string().optional(),
  location: z.string().optional(),
  story: z.string().optional(),
  imageUrl: z.string().optional(),
  tags: z.array(z.string()).optional(),
  userId: z.number().int().optional(),
  visibility: z.string().optional(),
  categoryTemplate: z.string().optional(),
  customFields: z.string().optional(),
  roomId: z.number().int().optional(),
});

const updateSchema = z.object({
  title: z.string().min(1).optional(),
  category: z.string().optional().nullable(),
  dateAcquired: z.string().optional().nullable(),
  location: z.string().optional().nullable(),
  story: z.string().optional().nullable(),
  imageUrl: z.string().optional().nullable(),
  tags: z.array(z.string()).optional().nullable(),
  userId: z.number().int().optional().nullable(),
  visibility: z.string().optional().nullable(),
  categoryTemplate: z.string().optional().nullable(),
  customFields: z.string().optional().nullable(),
  roomId: z.number().int().optional().nullable(),
});

router.post('/', validate(createSchema), controller.createCollection);
router.get('/', controller.listCollections);
router.get('/tags', controller.listTags);
router.get('/:id/image', controller.getCollectionImage);
router.get('/:id', controller.getCollection);
router.put('/:id', validate(updateSchema), controller.updateCollection);
router.delete('/:id', controller.deleteCollection);
router.post('/:id/image', upload.single('image'), controller.uploadImage);
router.delete('/:id/image', controller.deleteImage);

module.exports = router;
