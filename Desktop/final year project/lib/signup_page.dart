import 'dart:convert'; // JSON işlemleri için
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP istekleri için
import 'parent_info.dart'; // ParentInfoPage dosyanızı buraya ekleyin
import 'constants.dart'; // Backend URL için constants.dart

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? emailErrorMessage; // Dinamik hata mesajı için
  bool isLoading = false; // Yükleme durumu

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için dispose çağrılır.
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // E-posta geçerliliğini kontrol eden backend isteği
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/check_email'), // Backend'de e-posta kontrol endpointi
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['exists'] ?? false; // True/False döner
      }
    } catch (e) {
      debugPrint("Email check failed: $e");
    }
    return false;
  }

  // Şifre geçerliliğini kontrol eden fonksiyon
  bool isPasswordValid(String value) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(value);
  }

  // Kullanıcı kayıt fonksiyonu
  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'), // Backend'deki kayıt endpointi
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        int userId = responseData['user_id']; // Backend'den dönen user_id

        // ParentInfoPage'e yönlendirme
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ParentInfoPage(userId: userId),
            ),
          );
        }
      } else {
        // Hata durumunda mesaj göster
        final errorMessage = json.decode(response.body)['error'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMessage')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Email alanı için validasyon ve renk değişikliği
  Future<void> validateEmail(String email) async {
    bool exists = await checkEmailExists(email);
    if (mounted) {
      setState(() {
        emailErrorMessage = exists ? 'This email is already registered' : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Create a new account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    errorText: emailErrorMessage,
                  ),
                  onChanged: validateEmail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (emailErrorMessage != null) {
                      return emailErrorMessage;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (!isPasswordValid(value)) {
                      return '''
                      Password must contain at least:
                      - 8 characters
                      - 1 uppercase letter
                      - 1 lowercase letter
                      - 1 number
                      - 1 special character (@, #, \$, etc.)
                      ''';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Input
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.pinkAccent,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Next'),
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
