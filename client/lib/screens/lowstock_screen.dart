import 'package:cattle_management_app/screens/adjust_feedstock.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LowStockFeedsScreen extends StatefulWidget {
  const LowStockFeedsScreen({super.key});

  @override
  _LowStockFeedsScreenState createState() => _LowStockFeedsScreenState();
}

class _LowStockFeedsScreenState extends State<LowStockFeedsScreen> {
  List<dynamic> lowStockFeeds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLowStockFeeds();
  }

  Future<void> fetchLowStockFeeds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/feed/low-stock'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          lowStockFeeds = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load low stock feeds');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Fodder':
        return Colors.green;
      case 'Concentrate':
        return Colors.orange;
      case 'Mineral':
        return Colors.blue;
      case 'Supplement':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Fodder':
        return Icons.grass;
      case 'Concentrate':
        return Icons.grain;
      case 'Mineral':
        return Icons.science;
      case 'Supplement':
        return Icons.medication;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Feeds'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchLowStockFeeds,
              child: lowStockFeeds.isEmpty
                  ? _buildEmptyState()
                  : _buildLowStockList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No low stock items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All feed items are above alert threshold',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lowStockFeeds.length,
      itemBuilder: (context, index) {
        final feed = lowStockFeeds[index];
        final percentageOfThreshold = 
            (feed['quantity'] / feed['stockAlert'] * 100).toStringAsFixed(1);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(feed['type']),
              child: Icon(
                _getTypeIcon(feed['type']),
                color: Colors.white,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    feed['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 20,
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current: ${feed['quantity']} ${feed['unit']}'),
                Text(
                  'Alert Threshold: ${feed['stockAlert']} ${feed['unit']}',
                  style: const TextStyle(color: Colors.red),
                ),
                LinearProgressIndicator(
                  value: feed['quantity'] / feed['stockAlert'],
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    feed['quantity'] / feed['stockAlert'] < 0.5
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
                Text(
                  '$percentageOfThreshold% of threshold',
                  style: TextStyle(
                    color: feed['quantity'] / feed['stockAlert'] < 0.5
                        ? Colors.red
                        : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdjustFeedStockScreen(feed: feed),
                  ),
                ).then((value) {
                  if (value == true) {
                    fetchLowStockFeeds();
                  }
                });
              },
              tooltip: 'Adjust Stock',
            ),
          ),
        );
      },
    );
  }
}