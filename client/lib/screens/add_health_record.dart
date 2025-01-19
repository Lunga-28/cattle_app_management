import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddHealthRecordScreen extends StatefulWidget {
  const AddHealthRecordScreen({super.key});

  @override
  _AddHealthRecordScreenState createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> cattleList = [];
  bool isLoading = true;

  // Form fields
  String? selectedCattleId;
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
    fetchCattleList();
  }

  Future<void> fetchCattleList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/cattle'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cattleList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cattle');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/health'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'cattleId': selectedCattleId,
          'type': selectedType,
          'description': descriptionController.text,
          'veterinarian': veterinarianController.text,
          'cost': double.tryParse(costController.text),
          'nextCheckupDate': nextCheckupDate?.toIso8601String(),
          'medicines': medicines,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record added successfully')),
        );
      } else {
        throw Exception('Failed to add health record');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Record'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCattleId,
                      decoration: const InputDecoration(
                        labelText: 'Select Cattle',
                      ),
                      items: cattleList.map<DropdownMenuItem<String>>((cattle) {
                        return DropdownMenuItem<String>(
                          value: cattle['_id'],
                          child: Text(cattle['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCattleId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a cattle';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a veterinarian';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a cost';
                        }
                        return null;
                      },
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
                              initialDate: DateTime.now(),
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
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _addMedicine();
                      },
                      child: const Text('Add Medicine'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Add Health Record'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
