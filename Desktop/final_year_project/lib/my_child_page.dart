import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'child_detail_page.dart'; // Detay sayfası import

class MyChildrenPage extends StatefulWidget {
  final int parentId;

  const MyChildrenPage({super.key, required this.parentId});

  @override
  State<MyChildrenPage> createState() => _MyChildrenPageState();
}

class _MyChildrenPageState extends State<MyChildrenPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> children = [];
  bool isLoading = true;
  String errorMessage = '';
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    fetchChildren();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.forward();
  }

  Future<void> fetchChildren() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/children/${widget.parentId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          children = List<Map<String, dynamic>>.from(data['children'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load children profiles.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  : _buildChildrenGrid(),
        ],
      ),
    );
  }

  /// Gradient Arka Plan
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE4E1), Color(0xFFFAFAD2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// Çocukları GridView ile Göster
  Widget _buildChildrenGrid() {
    return FadeTransition(
      opacity: _controller,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.9,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildDetailPage(
                    childId: child['id'],
                    childName: child['child_name'],
                    childImage: child['child_image'] ?? 'assets/default.png',
                  ),
                ),
              );
            },
            child: _buildChildCard(child),
          );
        },
      ),
    );
  }

  /// Çocuk Kart Tasarımı
  Widget _buildChildCard(Map<String, dynamic> child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: child['child_gender'] == 'Male'
              ? [Colors.blue[100]!, Colors.blue[300]!]
              : [Colors.pink[100]!, Colors.pink[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                child['child_image'] ?? 'assets/default.png',
              ),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            child['child_name'] ?? 'Unknown',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
