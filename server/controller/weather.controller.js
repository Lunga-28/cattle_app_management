const express = require('express');
const axios = require('axios');
require('dotenv').config();

const API_KEY = process.env.OPENWEATHER_API_KEY;
const BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast';

// Add debug logging
console.log('Environment variables loaded:');
console.log('OPENWEATHER_API_KEY:', API_KEY ? 'Exists' : 'Not found');

const router = express.Router();

const processWeatherData = (data) => {
    const forecast = data.list.map(item => ({
        date: item.dt_txt,
        temperature: item.main.temp,
        weather: item.weather[0].description,
        humidity: item.main.humidity,
        windSpeed: item.wind.speed
    }));

    return {
        city: data.city.name,
        country: data.city.country,
        forecast: forecast
    };
};

router.get('/', async (req, res) => {
    const { city } = req.query;

    if (!city) {
        return res.status(400).json({ 
            error: 'Please enter a city name'
        });
    }

    if (!API_KEY) {
        console.error('API key is missing or invalid');
        return res.status(500).json({
            error: 'Server configuration error'
        });
    }

    try {
 
        console.log(`Making request to OpenWeather API for city: ${city}`);
        
        const response = await axios.get(BASE_URL, {
            params: {
                q: city,
                appid: API_KEY,
                units: 'metric'
            }
        });

        const processedData = processWeatherData(response.data);
        res.json(processedData);

    } catch (error) {
        console.error('Error details:', {
            status: error.response?.status,
            message: error.response?.data?.message,
            config: {
                url: error.config?.url,
                params: {
                    ...error.config?.params,
                    appid: 'HIDDEN' // Hide API key in logs
                }
            }
        });
        
        if (error.response) {
            if (error.response.status === 404) {
                return res.status(404).json({
                    error: 'City not found'
                });
            } else if (error.response.status === 401) {
                return res.status(401).json({
                    error: 'Invalid API key. Please check server configuration.'
                });
            }
            return res.status(error.response.status).json({
                error: 'Failed to fetch weather data'
            });
        }

        res.status(500).json({
            error: 'Network error occurred'
        });
    }
});

module.exports = router;