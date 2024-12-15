import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String? childName; // Opsiyonel olarak tanımlanıyor

  const HomePage({super.key, this.childName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(
          childName != null ? 'Welcome, $childName!' : 'Welcome to Home Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
