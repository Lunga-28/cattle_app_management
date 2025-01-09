const axios = require('axios');

const API_KEY = process.env.OPENWEATHER_API_KEY;
const BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast';

exports.getWeatherForecast = async (req, res) => {
    const { city } = req.query;

    if (!city) {
        return res.status(400).json({ error: 'City is required' });
    }

    try {
        const response = await axios.get(BASE_URL, {
            params: {
                q: city,
                appid: API_KEY,
                units: 'metric',
            },
        });

        const data = response.data;
        const forecast = data.list.map(item => ({
            date: item.dt_txt,
            temperature: item.main.temp,
            weather: item.weather[0].description,
            humidity: item.main.humidity,
            windSpeed: item.wind.speed,
        }));

        res.json({
            city: data.city.name,
            country: data.city.country,
            forecast: forecast,
        });
    } catch (error) {
        console.error('Error fetching weather forecast data:', error);
        if (error.response && error.response.status === 404) {
            res.status(404).json({ error: 'City not found' });
        } else {
            res.status(500).json({ error: 'Failed to fetch weather forecast data' });
        }
    }
};
