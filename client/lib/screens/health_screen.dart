import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'add_health_record.dart';
import 'edit_health_record.dart';
import 'health_record_details.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<dynamic> healthRecords = [];
  bool isLoading = true;
  String? selectedType;
  String sortOrder = 'recent';

  final List<String> healthTypes = [
    'Vaccination',
    'Treatment',
    'Check-up',
    'Disease',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    fetchHealthRecords();
  }

  Future<void> fetchHealthRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      String url = 'http://10.0.2.2:3000/api/health?sort=$sortOrder';
      if (selectedType != null) {
        url += '&type=$selectedType';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          healthRecords = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to load health records');
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

  Future<void> deleteHealthRecord(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/health/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchHealthRecords();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record deleted successfully')),
        );
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to delete health record');
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
        title: const Text('Health Records'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                sortOrder = value;
              });
              fetchHealthRecords();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Text('Most Recent'),
              ),
              const PopupMenuItem(
                value: 'old',
                child: Text('Oldest First'),
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
                    onRefresh: fetchHealthRecords,
                    child: healthRecords.isEmpty
                        ? _buildEmptyState()
                        : _buildHealthRecordsList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHealthRecordScreen(),
            ),
          ).then((value) {
            if (value == true) {
              fetchHealthRecords();
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
              fetchHealthRecords();
            },
          ),
          ...healthTypes.map((type) => FilterChip(
                label: Text(type),
                selected: selectedType == type,
                onSelected: (bool selected) {
                  setState(() {
                    selectedType = selected ? type : null;
                  });
                  fetchHealthRecords();
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
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No health records found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add a new health record',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: healthRecords.length,
      itemBuilder: (context, index) {
        final record = healthRecords[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(record['type']),
              child: Icon(
                _getTypeIcon(record['type']),
                color: Colors.white,
              ),
            ),
            title: Text(
              'Tag #${record['cattleId']['tag_number']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['type']),
                Text(
                  DateFormat('MMM d, yyyy').format(
                    DateTime.parse(record['date']),
                  ),
                ),
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
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
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
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HealthRecordDetailsScreen(record: record),
                      ),
                    );
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditHealthRecordScreen(record: record),
                      ),
                    ).then((value) {
                      if (value == true) {
                        fetchHealthRecords();
                      }
                    });
                    break;
                  case 'delete':
                    deleteHealthRecord(record['_id']);
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
      case 'Vaccination':
        return Colors.blue;
      case 'Treatment':
        return Colors.orange;
      case 'Check-up':
        return Colors.green;
      case 'Disease':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Vaccination':
        return Icons.vaccines;
      case 'Treatment':
        return Icons.medical_services;
      case 'Check-up':
        return Icons.health_and_safety;
      case 'Disease':
        return Icons.sick;
      default:
        return Icons.more_horiz;
    }
  }
}
