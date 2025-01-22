import 'package:cattle_management_app/config/api_config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

  @override
  _AddFeedScreenState createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  
  // Form controllers
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final costController = TextEditingController();
  final stockAlertController = TextEditingController();
  final supplierController = TextEditingController();
  final notesController = TextEditingController();
  
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

  Future<void> _addFinanceRecord(double cost) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/finances'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': 'Expense',
          'amount': cost,
          'description': 'Feed purchase: ${nameController.text} (${selectedType}) - ${quantityController.text} ${selectedUnit}',
          'date': DateTime.now().toIso8601String(),
          'category': 'Feed',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add finance record');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding finance record: ${e.toString()}')),
      );
      rethrow;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.feeds),
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

      if (response.statusCode == 201) {
        // Calculate total cost
        final quantity = double.parse(quantityController.text);
        final unitCost = double.parse(costController.text);
        final totalCost = quantity * unitCost;
        
        // Add corresponding finance record
        await _addFinanceRecord(totalCost);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feed and finance record added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to add feed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Feed'),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: ListTile(
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
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add Feed',
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