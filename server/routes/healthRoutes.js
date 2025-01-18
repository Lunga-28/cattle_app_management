const express = require('express');
const healthController = require('../controller/health.controller');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

router.post('/', authenticate, healthController.addHealthRecord);
router.get('/', authenticate, healthController.getHealthRecords);
router.get('/cattle/:cattleId', authenticate, healthController.getHealthRecordsByCattle);
router.get('/:id', authenticate, healthController.getHealthRecordById);
router.put('/:id', authenticate, healthController.updateHealthRecord);
router.delete('/:id', authenticate, healthController.deleteHealthRecord);

module.exports = router;
