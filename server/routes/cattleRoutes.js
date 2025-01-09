const express = require('express');
const cattleController = require('../controller/cattle.controller');
const authenticate = require('../middleware/authenticate');

const router = express.Router();


router.post('/', authenticate, cattleController.addCattle);
router.get('/', authenticate, cattleController.getCattle);
router.get('/:id', authenticate, cattleController.getCattleById);
router.put('/:id', authenticate, cattleController.updateCattle);
router.delete('/:id', authenticate, cattleController.deleteCattle);
router.post('/:id/health-records', authenticate, cattleController.addHealthRecord);

module.exports = router;
