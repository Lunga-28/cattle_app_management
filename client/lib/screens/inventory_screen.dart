import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/cattle'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add your authentication token here
          'Authorization': 'cattle_mosaicbytes',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cattle = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cattle');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
        backgroundColor: const Color(0xffB81736),
        elevation: 0,
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
                            'assets/empty_cattle.png', // Add your placeholder image
                            height: 120,
                            width: 120,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No cattle added yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the + button to add your first cattle',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
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
                              backgroundColor: const Color(0xffB81736),
                              child: Text(
                                animal['tag_number']?.toString().substring(0, 1) ??
                                    '#',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              'Tag #${animal['tag_number']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  // TODO: Implement delete functionality
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
          // TODO: Navigate to add cattle screen
        },
        backgroundColor: const Color(0xffB81736),
        child: const Icon(Icons.add),
      ),
    );
  }
}