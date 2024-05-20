import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_aquarium/ui/loginPage.dart';
import 'package:smart_aquarium/ui/aquariumsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "Wszystkie pola muszą być wypełnione.");
      return;
    }

    if (!isValidEmail(email)) {
      _showErrorDialog(context, "Niepoprawny adres e-mail.");
      return;
    }

    if (!isStrongPassword(password)) {
      _showErrorDialog(
          context,
          "Hasło musi zawierać co najmniej 8 znaków, w tym jedną wielką literę, jedną małą literę, jedną cyfrę i jeden znak specjalny.");
      return;
    }

    bool isUsernameTaken = await checkIfUsernameExists(username);
    if (isUsernameTaken) {
      _showErrorDialog(context, "Podana nazwa użytkownika jest już zajęta.");
      return;
    }
    int userId =await registerUser(username, email, password);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('logged_in_user', userId);
        

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AquariumsPage()),
    );
  }

  bool isValidEmail(String email) {
    String emailRegex =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(emailRegex).hasMatch(email);
  }

  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Błąd"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  void _login(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
    'Stwórz konto',
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
                controller: _usernameController,
                style: TextStyle(color: Color(0xFF828282)),
                decoration: InputDecoration(
                  labelText: 'Nazwa',
                  labelStyle: TextStyle(color: Color(0xFF828282)),
                  prefixIcon: Icon(Icons.person, color: Color(0xFF828282)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF828282)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Color(0xFF828282)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF828282)),
                  prefixIcon: Icon(Icons.email, color: Color(0xFF828282)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF828282)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
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
            onPressed: () => _register(context),
            child: Text(
              'Stwórz konto',
              style: TextStyle(fontSize: 20.0, color: Colors.white), // Rozmiar tekstu w przycisku
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, 
              elevation: 0, 
    ),
  ),
),
SizedBox(height: 20.0),
TextButton(
  onPressed: () => _login(context),
  child: Text(
    'Masz już konto?',
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

Future<int> registerUser(String username, String email, String password) async {
  try {
    var url = Uri.parse('http://localhost:6868/api/v1/users/add');

    var body = jsonEncode({
      'userName': username,
      'userEmail': email,
      'userPassword': password,
    });

    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      int userId = responseData['userId'];
      return userId;
    } else {
      print('Błąd podczas rejestracji użytkownika: ${response.statusCode}');
      return -1;
    }
  } catch (e) {
    print('Wystąpił błąd: $e');
    return -1;
  }
}

Future<bool> checkIfUsernameExists(String username) async {
  try {
    var url = Uri.parse('http://localhost:6868/api/v1/users');
    var response = await http.get(url);

    if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
      for (dynamic user in users) {
        if (user['userName'] == username) {
            return true;
        }
      } return false;

    } else {
      print('Błąd podczas wysyłania żądania: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Wystąpił błąd: $e');
    return false;
  }
}