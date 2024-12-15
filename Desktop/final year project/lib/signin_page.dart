import 'package:flutter/material.dart';
import 'dart:convert'; // JSON işlemleri için
import 'package:http/http.dart' as http; // Backend bağlantısı için
import 'forgot_password_page.dart'; // Şifremi unuttum sayfası
import 'signup_page.dart'; // Kayıt sayfası
import 'validation_service.dart'; // Doğrulama işlemleri için
import 'my_child_page.dart'; // Çocuk sayfası
import 'constants.dart'; // Backend URL için constants
import 'package:logger/logger.dart'; // Loglama için logger paketi

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final validationService = ValidationService();
  final logger = Logger(); // Logger örneği oluşturuldu

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Backend'e POST isteği gönderiliyor
        final response = await http.post(
          Uri.parse('$baseUrl/login'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": _emailController.text.trim(),
            "password": _passwordController.text.trim(),
          }),
        );

        // Gelen yanıtın loglanması (Hata ayıklama için)
        logger.i('Response Code: ${response.statusCode}');
        logger.i('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          // Başarılı giriş
          final responseData = json.decode(response.body);
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyChildrenPage(
                children: responseData['children'] ?? [],
              ),
            ),
          );
        } else if (response.statusCode == 401) {
          // Hatalı giriş
          final responseData = json.decode(response.body);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error'] ?? 'Invalid credentials!'),
            ),
          );
        } else {
          // Diğer hata durumları
          if (!mounted) return;

          logger.w('Unexpected response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unexpected error occurred.'),
            ),
          );
        }
      } catch (e, stackTrace) {
        // Bağlantı hatası veya diğer hatalar
        if (!mounted) return;

        logger.e('Error occurred during login: $e',
            error: e, stackTrace: stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please check your connection.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    validator: validationService.validateEmail,
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
                    validator: validationService.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text('Forgot your password?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sign In Button
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.pinkAccent,
                    ),
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'or',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Navigate to Sign Up Page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
