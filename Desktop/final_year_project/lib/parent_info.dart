import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'add_child_page.dart';
import 'constants.dart';

class ParentInfoPage extends StatefulWidget {
  final int userId;

  const ParentInfoPage({super.key, required this.userId});

  @override
  State<ParentInfoPage> createState() => _ParentInfoPageState();
}

class _ParentInfoPageState extends State<ParentInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;
  String _selectedCountryCode = "+90";

  final List<Map<String, String>> _countries = [
    {'name': 'Turkey', 'code': '+90'},
    {'name': 'United States', 'code': '+1'},
    {'name': 'Germany', 'code': '+49'},
    {'name': 'France', 'code': '+33'}
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Tarih Seçici
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Ülkeye Göre Telefon Kodu Ayarı
  void _updateCountryCode(String? selectedCountry) {
    setState(() {
      _selectedCountry = selectedCountry;
      _selectedCountryCode = _countries.firstWhere(
              (country) => country['name'] == selectedCountry,
              orElse: () => {'code': '+90'})['code'] ??
          '+90';
    });
  }

  // Backend'e veri gönderme
  Future<void> submitParentInfo() async {
    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.userId,
          "first_name": _firstNameController.text,
          "last_name": _lastNameController.text,
          "birth_date": _birthDateController.text,
          "country": _selectedCountry,
          "phone_number":
              '$_selectedCountryCode ${_phoneNumberController.text}',
          "gender": _selectedGender,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddChildPage(userId: widget.userId),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'An error occurred')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
          child: ListView(
            children: [
              const Text(
                'Complete Parent Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField('First Name', _firstNameController),
              _buildTextField('Last Name', _lastNameController),
              _buildDatePickerField('Birth Date', _birthDateController),
              _buildCountryDropdown(),
              _buildPhoneField(),
              _buildDropdownField('Gender', _genders, _selectedGender,
                  (value) => setState(() => _selectedGender = value)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitParentInfo();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField Helper Widget
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  // Dropdown Helper Widget
  Widget _buildDropdownField(String label, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(labelText: label),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  // Country Dropdown
  Widget _buildCountryDropdown() {
    return _buildDropdownField(
      'Country',
      _countries.map((country) => country['name']!).toList(),
      _selectedCountry,
      _updateCountryCode,
    );
  }

  // Phone Number Field with Country Code
  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 80,
          child: TextFormField(
            readOnly: true,
            initialValue: _selectedCountryCode,
            decoration: const InputDecoration(labelText: 'Code'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            validator: (value) => value == null || value.length != 10
                ? 'Enter 10-digit phone number'
                : null,
          ),
        ),
      ],
    );
  }

  // DatePicker Field
  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }
}
