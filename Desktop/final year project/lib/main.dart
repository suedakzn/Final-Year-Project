import 'package:flutter/material.dart';
import 'signin_page.dart'; // Login sayfasını import edin.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInPage(), // İlk olarak login sayfası açılacak.
    );
  }
}
