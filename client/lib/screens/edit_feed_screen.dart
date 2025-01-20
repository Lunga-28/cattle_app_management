import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EditFeedScreen extends StatefulWidget {
  final Map<String, dynamic> feed;

  const EditFeedScreen({
    super.key,
    required this.feed,
  });

  @override
  _EditFeedScreenState createState() => _EditFeedScreenState();
}

class _EditFeedScreenState extends State<EditFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController costController;
  late final TextEditingController stockAlertController;
  late final TextEditingController supplierController;
  late final TextEditingController notesController;
  
  String? selectedType;
  String? selectedUnit;
  DateTime? expiryDate;
  
  final List<String> feedTypes = [
    'Fodder',
    'Concentrate',
    'Mineral',
    'Supplement'
  ];
  
  final List<String> units = ['kg', 'g', 'lbs', 'tons'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    nameController = TextEditingController(text: widget.feed['name']);
    quantityController = TextEditingController(text: widget.feed['quantity'].toString());
    costController = TextEditingController(text: widget.feed['cost'].toString());
    stockAlertController = TextEditingController(text: widget.feed['stockAlert'].toString());
    supplierController = TextEditingController(text: widget.feed['supplier'] ?? '');
    notesController = TextEditingController(text: widget.feed['notes'] ?? '');
    selectedType = widget.feed['type'];
    selectedUnit = widget.feed['unit'];
    expiryDate = widget.feed['expiryDate'] != null 
        ? DateTime.parse(widget.feed['expiryDate']) 
        : null;
  }

  Future<void> _updateFeed() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/feed/${widget.feed['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': nameController.text,
          'type': selectedType,
          'quantity': double.parse(quantityController.text),
          'unit': selectedUnit,
          'cost': double.parse(costController.text),
          'stockAlert': double.parse(stockAlertController.text),
          'supplier': supplierController.text,
          'expiryDate': expiryDate?.toIso8601String(),
          'notes': notesController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feed updated successfully')),
        );
      } else {
        throw Exception('Failed to update feed');
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
        title: const Text('Edit Feed'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Feed Name*',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter feed name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Feed Type*',
                  prefixIcon: Icon(Icons.category),
                ),
                items: feedTypes.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select feed type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity*',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit*',
                      ),
                      items: units.map((String unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select unit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost per Unit*',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: stockAlertController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Alert Threshold*',
                  prefixIcon: Icon(Icons.warning),
                  helperText: 'You will be notified when stock falls below this level',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock alert threshold';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: supplierController,
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiry Date'),
                subtitle: Text(
                  expiryDate != null 
                    ? DateFormat('MMM dd, yyyy').format(expiryDate!)
                    : 'Not set'
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) {
                    setState(() {
                      expiryDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _updateFeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Feed',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    costController.dispose();
    stockAlertController.dispose();
    supplierController.dispose();
    notesController.dispose();
    super.dispose();
  }
}