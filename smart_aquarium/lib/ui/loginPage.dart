// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_aquarium/ui/registerPage.dart';
import 'package:smart_aquarium/ui/aquariumsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/config.dart';

Future<String> authUser(String username, String password) async {
  try {
    var url = Uri.parse('$baseUrl/api/v1/auth/authenticate');

    var body = jsonEncode({
      'username': username,
      'password': password,
    });

    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      debugPrint('User successfully authenticated');
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String token = responseData['token'];
      return token;
    } else {
      throw Exception('Error when authenticating user: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error during logging: $e');
    return '';
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "Wszystkie pola muszą być wypełnione.");
      return;
    }

    try {
      String token = await authUser(username, password);

      if (token.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);

        int userId = await saveUserId(username, token);
        if (userId == 0) {
          debugPrint('Error when saving user id');
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AquariumsPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Błąd logowania'),
              content: const Text('Niepoprawne dane logowania.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error when logging: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Błąd"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Logowanie',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/login_logo.png',
                        height: 150,
                      ),
                      const SizedBox(height: 100.0),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Color(0xFF828282)),
                        decoration: const InputDecoration(
                          labelText: 'Login',
                          labelStyle: TextStyle(color: Color(0xFF828282)),
                          prefixIcon:
                              Icon(Icons.login, color: Color(0xFF828282)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF828282)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Color(0xFF828282)),
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Hasło',
                          labelStyle: TextStyle(color: Color(0xFF828282)),
                          prefixIcon:
                              Icon(Icons.lock, color: Color(0xFF828282)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF828282)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () => _login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Zaloguj',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextButton(
                        onPressed: () => _register(context),
                        child: const Text(
                          'Zarejestruj się',
                          style: TextStyle(fontSize: 20.0, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<int> saveUserId(String username, String token) async {
  try {
    var url = Uri.parse('$baseUrl/api/v1/users');
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      debugPrint('Users data successfully fetched');
      List<dynamic> users = jsonDecode(response.body);
      for (dynamic user in users) {
        if (user['username'] == username) {
          int userId = user['userId'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('userId', userId);
          return userId;
        }
      }
      return 0;
    } else {
      debugPrint('Error when fetching users: ${response.statusCode}');
      return 0;
    }
  } catch (e) {
    debugPrint('Error when fetching users: $e');
    return 0;
  }
}
