const express = require('express');
const financeController = require('../controller/finances.controller');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

router.post('/', authenticate, financeController.addFinance);
router.get('/', authenticate, financeController.getFinances);

module.exports = router;
