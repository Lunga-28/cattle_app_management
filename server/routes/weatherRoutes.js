const express = require('express');
const router = express.Router();
const weatherController = require('../controller/weather.controller');

router.use('/', weatherController);


module.exports = router;
