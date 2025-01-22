import 'package:cattle_management_app/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  List<Finance> finances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFinances();
  }

  Future<void> fetchFinances() async {
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
        Uri.parse(ApiConfig.finances),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          finances = data.map((json) => Finance.fromJson(json)).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized access (expired token)
        await prefs.remove('access_token'); // Clear the invalid token
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to load finances');
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

  Future<void> addFinanceRecord(Finance newFinance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.finances),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': newFinance.type,
          'amount': newFinance.amount,
          'description': newFinance.description,
          'date': newFinance.date.toIso8601String(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // Refresh the finances list
        fetchFinances();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finance record added successfully')),
        );
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Failed to add finance record');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFinancesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () => _showAddFinanceDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    double totalIncome = finances
        .where((f) => f.type == 'Income')
        .fold(0, (sum, item) => sum + item.amount);
    double totalExpense = finances
        .where((f) => f.type == 'Expense')
        .fold(0, (sum, item) => sum + item.amount);
    double balance = totalIncome - totalExpense;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Income', totalIncome, Colors.green),
            _buildSummaryItem('Expense', totalExpense, Colors.red),
            _buildSummaryItem(
                'Balance', balance, balance >= 0 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancesList() {
    if (finances.isEmpty) {
      return const Center(
        child: Text('No finance records found'),
      );
    }

    return ListView.builder(
      itemCount: finances.length,
      itemBuilder: (context, index) {
        final finance = finances[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: finance.type == 'Income'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              child: Icon(
                finance.type == 'Income'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: finance.type == 'Income' ? Colors.green : Colors.red,
              ),
            ),
            title: Text(finance.description),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(finance.date)),
            trailing: Text(
              '\$${finance.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: finance.type == 'Income' ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddFinanceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFinanceForm(onSubmit: addFinanceRecord),
    );
  }
}

class AddFinanceForm extends StatefulWidget {
  final Function(Finance) onSubmit;

  const AddFinanceForm({super.key, required this.onSubmit});

  @override
  State<AddFinanceForm> createState() => _AddFinanceFormState();
}

class _AddFinanceFormState extends State<AddFinanceForm> {
  final _formKey = GlobalKey<FormState>();
  String type = 'Income';
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newFinance = Finance(
        id: '', // ID will be assigned by the server
        type: type,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        date: selectedDate,
      );

      widget.onSubmit(newFinance);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Income', label: Text('Income')),
                ButtonSegment(value: 'Expense', label: Text('Expense')),
              ],
              selected: {type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  type = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
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
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

class Finance {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime date;

  Finance({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      id: json['_id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}
