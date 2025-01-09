import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AddCattleScreen extends StatefulWidget {
  const AddCattleScreen({super.key});

  @override
  _AddCattleScreenState createState() => _AddCattleScreenState();
}

class _AddCattleScreenState extends State<AddCattleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male';
  bool isLoading = false;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Retrieved token: ${token?.substring(0, 10) ?? 'null'}...');
    return token;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final token = await _getToken();
    if (token == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showError('Not authenticated. Please sign in again.');
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final cattleData = {
      'name': _nameController.text,
      'tag_number': _tagController.text,
      'breed': _breedController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _selectedGender,
    };

    try {
      print('Sending request to add cattle...'); // Debug log
      print(
          'Token: ${token.substring(0, 10)}...'); // Show first 10 chars of token
      print('Request data: $cattleData'); // Debug log

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/cattle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(cattleData),
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (!mounted) {
        print('Widget not mounted, returning early');
        return;
      }

      if (response.statusCode == 201) {
        // Clear form fields and reset gender
        _formKey.currentState?.reset();
        setState(() {
          _selectedGender = 'Male';
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cattle added successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          isLoading = false;
        });

        final errorData = json.decode(response.body);
        if (response.statusCode == 401) {
          _showError('Session expired. Please sign in again.');
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          _showError(errorData['error'] ?? 'Failed to add cattle');
        }
      }
    } on SocketException catch (e) {
      print('SocketException: $e'); // Debug log
      setState(() {
        isLoading = false;
      });
      _showError('Network error: Please check your internet connection.');
    } catch (e) {
      print('Unexpected error: $e'); // Debug log
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final isFormDirty = _nameController.text.isNotEmpty ||
        _tagController.text.isNotEmpty ||
        _breedController.text.isNotEmpty ||
        _ageController.text.isNotEmpty;

    if (!isFormDirty) return true;

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content:
                const Text('You have unsaved changes. Do you want to leave?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Cattle'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  icon: Icons.pets,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _tagController,
                  labelText: 'Tag Number',
                  icon: Icons.tag,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a tag number';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                      return 'Tag number can only contain alphanumeric characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _breedController,
                  labelText: 'Breed',
                  icon: Icons.category,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a breed' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageController,
                  labelText: 'Age (in years)',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter the age';
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 50) {
                      return 'Age must be a valid number between 0 and 50';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(),
                const SizedBox(height: 24),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Add Cattle',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      textCapitalization: TextCapitalization.words,
      validator: validator,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value!;
        });
      },
      validator: (value) => value!.isEmpty ? 'Please select a gender' : null,
    );
  }
}
