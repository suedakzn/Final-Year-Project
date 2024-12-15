import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_child_page.dart';
import 'constants.dart';

class ParentInfoPage extends StatefulWidget {
  final int userId;

  const ParentInfoPage({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _ParentInfoPageState createState() => _ParentInfoPageState();
}

class _ParentInfoPageState extends State<ParentInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;
  String _selectedCountryCode = '+90';

  final List<String> _countries = [
    'United States',
    'Turkey',
    'Germany',
    'France',
    'India',
    'China',
    'Japan',
    'Canada'
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  Future<void> submitParentInfo() async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String birthDate = _birthDateController.text;
    final String phoneNumber =
        '$_selectedCountryCode ${_phoneNumberController.text}';
    final String address = _addressController.text;
    final String email = _emailController.text;
    final String occupation = _occupationController.text;
    final String? gender = _selectedGender;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_child'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.userId,
          "first_name": firstName,
          "last_name": lastName,
          "birth_date": birthDate,
          "country": _selectedCountry,
          "phone_number": phoneNumber,
          "address": address,
          "email": email,
          "occupation": occupation,
          "gender": gender,
        }),
      );

      if (!mounted) return; // Async işlem sonrası güvenliğe dikkat edin
      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddChildPage(userId: widget.userId),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(responseData['error'] ?? 'Unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // Async işlem sonrası güvenliğe dikkat edin
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complete Your Profile',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your first name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your last name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Birth Date
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your birth date'
                      : null,
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Gender'),
                  items: _genders
                      .map((gender) => DropdownMenuItem<String>(
                          value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 16),

                // Country Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Select Country',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Country'),
                  items: _countries
                      .map((country) => DropdownMenuItem<String>(
                          value: country, child: Text(country)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a country' : null,
                ),
                const SizedBox(height: 16),

                // Phone Number
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedCountryCode,
                      items: [
                        '+1',
                        '+90',
                        '+49',
                        '+33',
                        '+91',
                        '+86',
                        '+81',
                        '+1'
                      ]
                          .map((code) => DropdownMenuItem<String>(
                              value: code, child: Text(code)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your phone number'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your address'
                      : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your email address'
                      : null,
                ),
                const SizedBox(height: 16),

                // Occupation
                TextFormField(
                  controller: _occupationController,
                  decoration: const InputDecoration(
                    labelText: 'Occupation',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your occupation'
                      : null,
                ),
                const SizedBox(height: 32),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        submitParentInfo();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
