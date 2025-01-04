import 'package:flutter/material.dart';
import 'my_child_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class AddChildPage extends StatefulWidget {
  final int userId;

  const AddChildPage({super.key, required this.userId});

  @override
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  List<Map<String, String>> children = []; // Eklenen çocukları tutar

  Future<void> _submitChildData(String name, String age, String gender) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_child'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.userId,
          "name": name,
          "age": age,
          "gender": gender,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child added successfully!')),
        );
        setState(() {
          children.add({
            'name': name,
            'age': age,
            'gender': gender,
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add child.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _addChild() {
    showDialog(
      context: context,
      builder: (context) {
        final childNameController = TextEditingController();
        final childAgeController = TextEditingController();
        String selectedGender = 'Male';

        return AlertDialog(
          title: const Text('Add Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: childNameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: childAgeController,
                decoration: const InputDecoration(labelText: 'Child Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: ['Male', 'Female']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedGender = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (childNameController.text.isNotEmpty &&
                    childAgeController.text.isNotEmpty) {
                  await _submitChildData(
                    childNameController.text,
                    childAgeController.text,
                    selectedGender,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: children.isEmpty
                  ? const Center(
                      child: Text(
                        'No children added yet! Please add at least one child.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              child['gender'] == 'Male'
                                  ? Icons.male
                                  : Icons.female,
                              color: child['gender'] == 'Male'
                                  ? Colors.blue
                                  : Colors.pink,
                            ),
                            title: Text(child['name'] ?? 'No Name'),
                            subtitle: Text('Age: ${child['age']}'),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Complete tuşu sadece en az 1 çocuk eklenince görünür
            if (children.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyChildrenPage(
                        parentId: widget.userId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Complete'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChild,
        child: const Icon(Icons.add),
      ),
    );
  }
}
