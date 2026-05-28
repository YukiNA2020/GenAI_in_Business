const { Router } = require('express');
const controller = require('../controllers/rooms.controller');

const router = Router();

router.get('/', controller.listRooms);
router.get('/:id', controller.getRoom);

module.exports = router;