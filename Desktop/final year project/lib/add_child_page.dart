import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'my_child_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class AddChildPage extends StatefulWidget {
  final int userId; // Kullanıcı ID'si

  const AddChildPage(
      {super.key, required this.userId}); // Constructor ile userId alıyoruz.

  @override
  // ignore: library_private_types_in_public_api
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  List<Map<String, String>> children = [];

  Future<void> _submitChildData(String name, String age, String gender) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_child'), // Backend URL
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.userId, // Backend'e userId gönderiyoruz.
          "name": name,
          "age": age,
          "gender": gender,
        }),
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Child added successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to add child: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding child: $e');
      }
    }
  }

  void _addChild() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController childNameController =
            TextEditingController();
        final TextEditingController childAgeController =
            TextEditingController();
        String selectedGender = 'Male';

        return AlertDialog(
          title: Text('Add Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: childNameController,
                decoration: InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: childAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Child Age',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: ['Male', 'Female']
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedGender = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (childNameController.text.isNotEmpty &&
                    childAgeController.text.isNotEmpty) {
                  setState(() {
                    children.add({
                      'name': childNameController.text,
                      'age': childAgeController.text,
                      'gender': selectedGender,
                    });
                  });

                  // Backend'e çocuk bilgisini gönder
                  _submitChildData(
                    childNameController.text,
                    childAgeController.text,
                    selectedGender,
                  );

                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Children'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        'No children added yet!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: children.length + 1,
                      itemBuilder: (context, index) {
                        if (index == children.length) {
                          return GestureDetector(
                            onTap: _addChild,
                            child: Card(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                        final child = children[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                child['gender'] == 'Male'
                                    ? Icons.male
                                    : Icons.female,
                                size: 48,
                                color: child['gender'] == 'Male'
                                    ? Colors.blue
                                    : Colors.pink,
                              ),
                              SizedBox(height: 8),
                              Text(
                                child['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Age: ${child['age'] ?? ''}'),
                              SizedBox(height: 4),
                              Text('Gender: ${child['gender'] ?? ''}'),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyChildrenPage(children: children),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Complete'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChild,
        child: Icon(Icons.add),
      ),
    );
  }
}
