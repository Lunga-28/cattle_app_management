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
  bool isSubmitting = false;

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

  @override
  void dispose() {
    descriptionController.dispose();
    veterinarianController.dispose();
    costController.dispose();
    super.dispose();
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          cattleList = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
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

  Future<void> _addFinanceRecord(double cost, String cattleName) async {
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
          'description':
              'Health expense for ${cattleName} - ${selectedType} (${descriptionController.text})',
          'date': DateTime.now().toIso8601String(),
          'category': 'Health',
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
      rethrow; // Rethrow to handle in the calling function
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

      // Get the selected cattle's name
      final selectedCattle = cattleList.firstWhere(
        (cattle) => cattle['_id'] == selectedCattleId,
        orElse: () => {'name': 'Unknown Cattle'},
      );
      final cattleName = selectedCattle['name'];

      // Add health record
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

      if (!mounted) return;

      if (response.statusCode == 201) {
        // Add corresponding finance record
        final cost = double.tryParse(costController.text) ?? 0;
        await _addFinanceRecord(cost, cattleName);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Health record and finance record added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to add health record');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a cost';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Checkup Date',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  nextCheckupDate == null
                                      ? 'Not set'
                                      : DateFormat.yMMMd()
                                          .format(nextCheckupDate!),
                                ),
                                const Spacer(),
                                TextButton.icon(
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
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text('Set Date'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Medicines',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _addMedicine,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Medicine'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: medicines.length,
                              itemBuilder: (context, index) {
                                final medicine = medicines[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Medicine ${index + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  medicines.removeAt(index);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Name',
                                            border: OutlineInputBorder(),
                                          ),
                                          initialValue: medicine['name'],
                                          onChanged: (value) {
                                            setState(() {
                                              medicine['name'] = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Dosage',
                                            border: OutlineInputBorder(),
                                          ),
                                          initialValue: medicine['dosage'],
                                          onChanged: (value) {
                                            setState(() {
                                              medicine['dosage'] = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Duration',
                                            border: OutlineInputBorder(),
                                          ),
                                          initialValue: medicine['duration'],
                                          onChanged: (value) {
                                            setState(() {
                                              medicine['duration'] = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitForm,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
