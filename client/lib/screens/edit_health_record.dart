import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cattle_management_app/config/api_config.dart';

class EditHealthRecordScreen extends StatefulWidget {
  final Map<String, dynamic> record;

  const EditHealthRecordScreen({super.key, required this.record});

  @override
  _EditHealthRecordScreenState createState() => _EditHealthRecordScreenState();
}

class _EditHealthRecordScreenState extends State<EditHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? selectedType;
  final descriptionController = TextEditingController();
  final veterinarianController = TextEditingController();
  final costController = TextEditingController();
  DateTime? nextCheckupDate;
  List<Map<String, String>> medicines = [];

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
    // Initialize form fields with existing data
    selectedType = widget.record['type'];
    descriptionController.text = widget.record['description'];
    veterinarianController.text = widget.record['veterinarian'] ?? '';
    costController.text = widget.record['cost']?.toString() ?? '';
    nextCheckupDate = widget.record['nextCheckupDate'] != null
        ? DateTime.parse(widget.record['nextCheckupDate'])
        : null;
    medicines = List<Map<String, String>>.from(
      (widget.record['medicines'] ?? []).map((medicine) => {
            'name': medicine['name'] ?? '',
            'dosage': medicine['dosage'] ?? '',
            'duration': medicine['duration'] ?? '',
          }),
    );
  }

  Future<void> _updateRecord() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.healthRecordById(widget.record['_id'])),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': selectedType,
          'description': descriptionController.text,
          'veterinarian': veterinarianController.text,
          'cost': double.tryParse(costController.text),
          'nextCheckupDate': nextCheckupDate?.toIso8601String(),
          'medicines': medicines,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record updated successfully')),
        );
      } else {
        throw Exception('Failed to update health record');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _addMedicine() {
    setState(() {
      medicines.add({
        'name': '',
        'dosage': '',
        'duration': '',
      });
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Health Record'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cattle: Tag #${widget.record['cattleId']['tag_number']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: healthTypes.map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: veterinarianController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Next Checkup Date: ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    nextCheckupDate == null
                        ? 'Not set'
                        : DateFormat.yMMMd().format(nextCheckupDate!),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: nextCheckupDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        setState(() {
                          nextCheckupDate = date;
                        });
                      }
                    },
                    child: const Text('Set Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Medicines',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: medicine['name'],
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicine['name'] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: medicine['dosage'],
                              decoration: const InputDecoration(
                                labelText: 'Dosage',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicine['dosage'] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: medicine['duration'],
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicine['duration'] = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeMedicine(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addMedicine,
                child: const Text('Add Medicine'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateRecord,
                child: const Text('Update Health Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
