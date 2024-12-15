import 'package:flutter/material.dart';
import 'home_page.dart';

class MyChildrenPage extends StatelessWidget {
  final List<Map<String, String>> children;

  // Constructor
  const MyChildrenPage({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Children'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: children.isEmpty
            ? Center(
                child: Text(
                  'No children profiles yet!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 sütunlu grid
                  childAspectRatio: 1, // Kare hücreler
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomePage(childName: child['name'] ?? 'Unknown'),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            child['name'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
