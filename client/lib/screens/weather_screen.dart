import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cattle_management_app/config/api_config.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchWeatherData(String city) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.weather}?city=${Uri.encodeComponent(city)}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'City not found';
          _isLoading = false;
        });
      } else if (response.statusCode == 400) {
        setState(() {
          _error = 'Please enter a city name';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error occurred';
        _isLoading = false;
      });
      print('Error details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_cityController.text.isNotEmpty) {
                _fetchWeatherData(_cityController.text);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _weatherData != null
                        ? _buildWeatherContent()
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Enter a city to see weather forecast',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _fetchWeatherData(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  _fetchWeatherData(_cityController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Search', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final forecast = _weatherData!['forecast'] as List;
    final today = DateTime.now().day;

    final todayHourly = forecast.where((item) {
      final date = DateTime.parse(item['date']);
      return date.day == today;
    }).toList();

    final dailyForecasts = forecast
        .where((item) {
          final date = DateTime.parse(item['date']);
          return date.day != today;
        })
        .fold<Map<String, dynamic>>({}, (map, item) {
          final date = DateTime.parse(item['date']);
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          if (!map.containsKey(dateStr)) {
            map[dateStr] = item;
          }
          return map;
        })
        .values
        .toList();

    return RefreshIndicator(
      onRefresh: () => _fetchWeatherData(_cityController.text),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_weatherData!['city']}, ${_weatherData!['country']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Today's Hourly Forecast",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: todayHourly.length,
                  itemBuilder: (context, index) {
                    final item = todayHourly[index];
                    return _buildHourlyCard(item);
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '5-Day Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyForecasts.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final item = dailyForecasts[index];
                  return _buildDailyCard(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyCard(Map<String, dynamic> item) {
    final date = DateTime.parse(item['date']);
    final hour = DateFormat('HH:mm').format(date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hour,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              _getWeatherIcon(item['weather']),
              color: const Color(0xFF4CAF50),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '${item['temperature'].round()}°C',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 14,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['humidity']}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyCard(Map<String, dynamic> item) {
    final date = DateTime.parse(item['date']);
    final dayName = DateFormat('EEEE').format(date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['weather'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  _getWeatherIcon(item['weather']),
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '${item['temperature'].round()}°C',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weather) {
    weather = weather.toLowerCase();
    if (weather.contains('cloud')) {
      return Icons.cloud_outlined;
    } else if (weather.contains('rain')) {
      return Icons.water_drop_outlined;
    } else if (weather.contains('snow')) {
      return Icons.ac_unit_outlined;
    } else if (weather.contains('thunder')) {
      return Icons.flash_on_outlined;
    } else {
      return Icons.wb_sunny_outlined;
    }
  }
}