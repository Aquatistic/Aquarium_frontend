import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_aquarium/ui/registerPage.dart';
import 'package:smart_aquarium/ui/aquariumsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<User?> fetchUser(String login, String userEmail) async {
  final response = await http.get(Uri.parse('http://localhost:6868/api/v1/users'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    for (var item in data) {
      User user = User.fromJson(item);
      if (user.userName == login && user.userEmail == userEmail) {
        return user;
      }
    }
    return null;
  } else {
    throw Exception('Błąd podczas pobierania danych użytkownika: ${response.statusCode}');
  }
}

class User {
  final String userName;
  final int userId;
  final String userEmail;

  const User({
    required this.userName,
    required this.userId,
    required this.userEmail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'userName': String userName,
        'userId': int userId,
        'userEmail': String userEmail,
      } =>
        User(
          userName: userName,
          userId: userId,
          userEmail: userEmail,
        ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();

  void _login(BuildContext context) async {
    String login = _loginController.text;
    String userEmail = _userEmailController.text;

    try {
      User? user = await fetchUser(login, userEmail);

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('logged_in_user', user.userId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AquariumsPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Błąd logowania'),
              content: Text('Niepoprawne dane logowania.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Wystąpił błąd podczas logowania: $e');
    }
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
        title: Text(
    'Logowanie',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
  ),
  centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/login_logo.png',
                height: 150,
              ),
              
              SizedBox(height: 100.0),
              TextField(
                controller: _loginController,
                style: TextStyle(color: Color(0xFF828282)),
                decoration: InputDecoration(
                  labelText: 'login',
                  labelStyle: TextStyle(color: Color(0xFF828282)),
                  prefixIcon: Icon(Icons.login, color: Color(0xFF828282)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF828282)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _userEmailController,
                style: TextStyle(color: Color(0xFF828282)),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  labelStyle: TextStyle(color: Color(0xFF828282)),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF828282)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF828282)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
        Container(
          height: 50.0, 
          width: double.infinity, 
          decoration: BoxDecoration(
            color: Colors.transparent, 
            borderRadius: BorderRadius.circular(10.0), 
          ),
          child: ElevatedButton(
            onPressed: () => _login(context),
            child: Text(
              'Zaloguj',
              style: TextStyle(fontSize: 20.0, color: Colors.white), 
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, 
              elevation: 0, 
    ),
  ),
),
SizedBox(height: 20.0),
TextButton(
  onPressed: () => _register(context),
  child: Text(
    'Zarejestruj się',
    style: TextStyle(fontSize: 20.0, color: Colors.blue), 
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}


