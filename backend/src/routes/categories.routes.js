const { Router } = require('express');
const controller = require('../controllers/categories.controller');

const router = Router();

router.get('/', controller.listCategories);
router.get('/:id', controller.getCategory);

module.exports = router;
