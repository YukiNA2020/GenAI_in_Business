const { Router } = require('express');
const controller = require('../controllers/users.controller');

const router = Router();

router.get('/:id/stats', controller.getStats);

module.exports = router;
