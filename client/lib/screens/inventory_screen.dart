import 'package:cattle_management_app/screens/add_cattle.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> cattle = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCattle();
  }

  Future<void> fetchCattle() async {
    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        // If no token, redirect to login
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/cattle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          cattle = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized access (expired token)
        await prefs.remove('access_token'); // Clear the invalid token
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to load cattle');
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

  Future<void> _deleteCattle(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/cattle/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Refresh the cattle list
        fetchCattle();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle deleted successfully')),
        );
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to delete cattle');
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
        title: const Text('Cattle Inventory'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchCattle,
              child: cattle.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/empty_cattle.png',
                            height: 120,
                            width: 120,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No cattle added yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the + button to add your first cattle',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: cattle.length,
                      itemBuilder: (context, index) {
                        final animal = cattle[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF4CAF50),
                              child: Text(
                                animal['tag_number']
                                        ?.toString()
                                        .substring(0, 1) ??
                                    '#',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              'Tag #${animal['tag_number']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Breed: ${animal['breed'] ?? 'N/A'}'),
                                Text(
                                    'Age: ${animal['age'] ?? 'N/A'} ${animal['age'] == 1 ? 'year' : 'years'}'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
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
                                if (value == 'edit') {
                                  // TODO: Implement edit functionality
                                } else if (value == 'delete') {
                                  _deleteCattle(animal['_id']);
                                }
                              },
                            ),
                            onTap: () {
                              // TODO: Navigate to cattle detail screen
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCattleScreen(),
            ),
          ).then((value) {
            if (value == true) {
              fetchCattle(); // Refresh the list if a new cattle was added
            }
          });
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }
}
