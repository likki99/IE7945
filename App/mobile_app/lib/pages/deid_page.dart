import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DEIDPage extends StatefulWidget {
  const DEIDPage({Key? key}) : super(key: key);

  @override
  _DEIDPageState createState() => _DEIDPageState();
}

class _DEIDPageState extends State<DEIDPage> {
  String _deidData = 'Initial DEID Data';
  String converted_file_path = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('DEID'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRowItem(
            title: 'Load Image',
            onTap: () async {
              // setState(() {
              //   _isLoading = true;
              // });
              try {
                await Future.delayed(const Duration(seconds: 1));

                final response = await http.post(
                  Uri.parse('http://127.0.0.1:8001/convert'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'sc_file_path':
                        "/Users/likhithravula/Documents/NEU/Northeastern/Capstone/1-1.dcm",
                  }),
                );

                final Map<String, dynamic> responseData =
                    jsonDecode(response.body);
                print(responseData);
                if (response.statusCode == 200) {
                  // Login successful
                  converted_file_path = responseData['image_path'];
                  print(converted_file_path);
                } else {
                  // Show error message
                  final String errorMessage =
                      responseData['message'] ?? response.reasonPhrase;
                  print(
                      'Conversion failed. Please try again. Status: ${response.statusCode} - $errorMessage');
                }
              } catch (e) {
                // Show error message
                print('Conversion failed. Please try again. Status: $e');
              }
            },
          ),
          _buildRowItem(
            title: 'Mask Image',
            onTap: () async {
              // setState(() {
              //   _isLoading = true;
              // });
              try {
                await Future.delayed(const Duration(seconds: 1));

                final response = await http.post(
                  Uri.parse('http://127.0.0.1:8001/convert'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'sc_file_path':
                        "/Users/likhithravula/Documents/NEU/Northeastern/Capstone/1-1.dcm",
                  }),
                );

                final Map<String, dynamic> responseData =
                    jsonDecode(response.body);
                print(responseData);
                if (response.statusCode == 200) {
                  // Login successful
                  converted_file_path = responseData['image_path'];
                  print(converted_file_path);
                } else {
                  // Show error message
                  final String errorMessage =
                      responseData['message'] ?? response.reasonPhrase;
                  print(
                      'Conversion failed. Please try again. Status: ${response.statusCode} - $errorMessage');
                }
              } catch (e) {
                // Show error message
                print('Conversion failed. Please try again. Status: $e');
              }
            },
          ),
          _buildRowItem(
            title: 'Save DICOM image',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem({required String title, required VoidCallback onTap}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 19.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : const Text(
                            'start',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 8.0),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.autorenew,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
