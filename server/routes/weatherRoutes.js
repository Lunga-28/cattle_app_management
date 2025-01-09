const express = require('express');
const weatherController = require('../controller/weather.controller');

const router = express.Router();


router.get('/', weatherController.getWeatherForecast);

module.exports = router;
