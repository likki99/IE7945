import 'dart:async';
// ignore: unused_import
import 'dart:io';

import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _password;
  bool _isLoading = false;
  String? _errorMessage;

  int _dotIndex = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotIndex = (_dotIndex + 1) % 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('assets/images/logo.jpg'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged: (value) {
                  _username = value;
                },
                // style: TextStyle(fontSize: 20.0),
                maxLines: 1,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) {
                  _password = value;
                },
                maxLines: 1,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  _errorMessage = null;
                  print("Error: $_errorMessage");

                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true; // Start showing the loading indicator
                    });

                    try {
                      await Future.delayed(const Duration(seconds: 1));

                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8001/login'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, String>{
                          'username': _username,
                          'password': _password,
                        }),
                      );

                      final Map<String, dynamic> responseData =
                          jsonDecode(response.body);
                      print(responseData);
                      if (response.statusCode == 200) {
                        // Login successful
                        final String userName = responseData['name'] ?? "User";
                        setState(() {
                          _isLoading = false; // Hide the loading indicator
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Dashboard(
                                    userName: userName,
                                  )),
                        );
                      } else {
                        // Show error message
                        final String errorMessage =
                            responseData['message'] ?? response.reasonPhrase;
                        print(
                            'Login failed. Please try again. Status: ${response.statusCode} - $errorMessage');
                        setState(() {
                          _isLoading = false; // Hide the loading indicator
                          _errorMessage = errorMessage;
                        });
                      }
                    } catch (e) {
                      // Show error message
                      setState(() {
                        _isLoading = false; // Hide the loading indicator
                        _errorMessage = 'Network error. Please try again.';
                      });
                    }
                    print(_errorMessage);
                  }
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  child: AnimatedOpacity(
                    opacity: _isLoading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return SizedBox(
                                width: 6,
                                height: 6,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: index == _dotIndex
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          )
                        : const Center(child: Text('Login')),
                  ),
                ),
              ),
              _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
