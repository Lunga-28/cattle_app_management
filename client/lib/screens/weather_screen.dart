import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
      // Updated URL to include the city query parameter
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/weather?city=${Uri.encodeComponent(city)}'),
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
      print('Error details: $e'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _weatherData != null
                          ? _buildWeatherContent()
                          : const Center(
                              child: Text('Enter a city to see weather forecast'),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                prefixIcon: const Icon(Icons.search),
              ),
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
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    final forecast = _weatherData!['forecast'] as List;
    final today = DateTime.now().day;
    
    // Separate today's hourly forecast
    final todayHourly = forecast.where((item) {
      final date = DateTime.parse(item['date']);
      return date.day == today;
    }).toList();

    // Group remaining forecast by day
    final dailyForecasts = forecast.where((item) {
      final date = DateTime.parse(item['date']);
      return date.day != today;
    }).fold<Map<String, dynamic>>({}, (map, item) {
      final date = DateTime.parse(item['date']);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      if (!map.containsKey(dateStr)) {
        map[dateStr] = item;
      }
      return map;
    }).values.toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_weatherData!['city']}, ${_weatherData!['country']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildHourlyCard(Map<String, dynamic> item) {
    final date = DateTime.parse(item['date']);
    final hour = DateFormat('HH:mm').format(date);

    return Card(
      elevation: 2,
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
            Text(
              '${item['humidity']}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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