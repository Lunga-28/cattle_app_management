import 'package:cattle_management_app/screens/add_feed_screen.dart';
import 'package:cattle_management_app/screens/lowstock_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'adjust_feedstock.dart';
import 'feed_detail_screen.dart';
import 'edit_feed_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> feeds = [];
  bool isLoading = true;
  String? selectedType;
  String sortOrder = 'recent';

  final List<String> feedTypes = [
    'Fodder',
    'Concentrate',
    'Mineral',
    'Supplement'
  ];

  @override
  void initState() {
    super.initState();
    fetchFeeds();
  }

  Future<void> fetchFeeds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      String url = 'http://10.0.2.2:3000/api/feed?sort=$sortOrder';
      if (selectedType != null) {
        url += '&type=$selectedType';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          feeds = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load feeds');
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

  Future<void> deleteFeed(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/feed/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchFeeds();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feed deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete feed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Inventory'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LowStockFeedsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                sortOrder = value;
              });
              fetchFeeds();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Text('Most Recent'),
              ),
              const PopupMenuItem(
                value: 'quantity',
                child: Text('Quantity (Low to High)'),
              ),
              const PopupMenuItem(
                value: 'expiry',
                child: Text('Expiry Date'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchFeeds,
                    child: feeds.isEmpty
                        ? _buildEmptyState()
                        : _buildFeedList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFeedScreen(),
            ),
          ).then((value) {
            if (value == true) {
              fetchFeeds();
            }
          });
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedType == null,
            onSelected: (bool selected) {
              setState(() {
                selectedType = null;
              });
              fetchFeeds();
            },
          ),
          ...feedTypes.map((type) => FilterChip(
                label: Text(type),
                selected: selectedType == type,
                onSelected: (bool selected) {
                  setState(() {
                    selectedType = selected ? type : null;
                  });
                  fetchFeeds();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No feed items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add new feed',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        final feed = feeds[index];
        final isLowStock = feed['quantity'] <= feed['stockAlert'];

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
                if (isLowStock)
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
                Text('${feed['quantity']} ${feed['unit']}'),
                Text('\$${feed['cost'].toStringAsFixed(2)} per ${feed['unit']}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'adjust',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Adjust Stock'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FeedDetailsScreen(feed: feed),
                      ),
                    );
                    break;
                  case 'adjust':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdjustFeedStockScreen(feed: feed),
                      ),
                    ).then((value) {
                      if (value == true) {
                        fetchFeeds();
                      }
                    });
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditFeedScreen(feed: feed),
                      ),
                    ).then((value) {
                      if (value == true) {
                        fetchFeeds();
                      }
                    });
                    break;
                  case 'delete':
                    final confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                            'Are you sure you want to delete this feed item?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      deleteFeed(feed['_id']);
                    }
                    break;
                }
              },
            ),
          ),
        );
      },
    );
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
}