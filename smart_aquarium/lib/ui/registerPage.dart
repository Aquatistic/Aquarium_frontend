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
    // Tutaj dodaj kod logiki uwierzytelniania
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    // Walidacja pól tekstowych
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      // Jeśli którekolwiek pole jest puste, wyświetl komunikat
      _showErrorDialog(context, "Wszystkie pola muszą być wypełnione.");
      return;
    }

    if (!isValidEmail(email)) {
      // Jeśli adres e-mail jest niepoprawny, wyświetl komunikat
      _showErrorDialog(context, "Niepoprawny adres e-mail.");
      return;
    }

    if (!isStrongPassword(password)) {
      // Jeśli hasło nie spełnia wymagań co do złożoności, wyświetl komunikat
      _showErrorDialog(
          context,
          "Hasło musi zawierać co najmniej 8 znaków, w tym jedną wielką literę, jedną małą literę, jedną cyfrę i jeden znak specjalny.");
      return;
    }


    // Sprawdzenie, czy użytkownik o podanej nazwie już istnieje
    bool isUsernameTaken = await checkIfUsernameExists(username);
    if (isUsernameTaken) {
      // Jeśli login jest już zajęty, wyświetl komunikat
      _showErrorDialog(context, "Podana nazwa użytkownika jest już zajęta.");
      return;
    }
      // Rejestracja użytkownika
    int userId =await registerUser(username, email, password);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('logged_in_user', userId);
        

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AquariumsPage()),
    );
  }

  bool isValidEmail(String email) {
    // Prosta walidacja adresu e-mail przy użyciu wyrażenia regularnego
    // Tutaj można użyć bardziej złożonego wyrażenia regularnego do bardziej zaawansowanej walidacji
    String emailRegex =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(emailRegex).hasMatch(email);
  }

  bool isStrongPassword(String password) {
    // Walidacja złożoności hasła
    // Tutaj można dodać bardziej złożone kryteria, takie jak minimalna długość, wymóg wielkiej litery, cyfry i znaku specjalnego
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

    // Tutaj można wykonać logikę uwierzytelniania, np. zapytanie do serwera
    // Jeśli uwierzytelnienie się powiedzie, możesz przejść do następnego ekranu
    // W przeciwnym razie możesz wyświetlić komunikat o błędzie lub inny odpowiedni komunikat
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
    'Stwórz konto',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Ustawienie większej czcionki i pogrubienie tekstu
  ),
  centerTitle: true, // Wyśrodkowanie tekstu w pasku aplikacji
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
          height: 50.0, // Ustawienie wysokości przycisku
          width: double.infinity, // Rozciągnięcie przycisku na całą szerokość dostępnej przestrzeni
          decoration: BoxDecoration(
            color: Colors.transparent, // Kolor tła przycisku
            borderRadius: BorderRadius.circular(10.0), // Zaokrąglenie rogów przycisku
          ),
          child: ElevatedButton(
            onPressed: () => _register(context),
            child: Text(
              'Stwórz konto',
              style: TextStyle(fontSize: 20.0, color: Colors.white), // Rozmiar tekstu w przycisku
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Przezroczysty kolor tła przycisku
              elevation: 0, // Usunięcie cienia przycisku
    ),
  ),
),
SizedBox(height: 20.0),
TextButton(
  onPressed: () => _login(context),
  child: Text(
    'Masz już konto?',
    style: TextStyle(fontSize: 20.0, color: Colors.blue), // Styl tekstu przycisku
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
    // Tworzymy adres URL z zapytaniem do API
    var url = Uri.parse('http://localhost:6868/api/v1/users/add');

    // Tworzymy ciało żądania w formacie JSON
    var body = jsonEncode({
      'userName': username,
      'userEmail': email,
      'userPassword': password,
    });

    // Wysyłamy żądanie POST do API
    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Parsujemy odpowiedź jako mapę
      Map<String, dynamic> responseData = jsonDecode(response.body);
      // Wyciągamy id nowoutworzonego użytkownika z odpowiedzi
      int userId = responseData['userId'];
      // Zwracamy id użytkownika
      return userId;
    } else {
      print('Błąd podczas rejestracji użytkownika: ${response.statusCode}');
      // W przypadku niepowodzenia zwracamy null
      return -1;
    }
  } catch (e) {
    print('Wystąpił błąd: $e');
    // W przypadku wystąpienia wyjątku zwracamy null
    return -1;
  }
}

Future<bool> checkIfUsernameExists(String username) async {
  try {
    // Tworzymy adres URL z zapytaniem do API
    var url = Uri.parse('http://localhost:6868/api/v1/users');

    // Wysyłamy żądanie GET do API
    var response = await http.get(url);

    // Sprawdzamy kod odpowiedzi - 200 oznacza sukces
    if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
      for (dynamic user in users) {
        if (user['userName'] == username) {
            return true;
        }
      } return false;

    } else {
      // Obsługa błędu w przypadku niepowodzenia żądania
      print('Błąd podczas wysyłania żądania: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    // Obsługa błędu w przypadku wystąpienia wyjątku
    print('Wystąpił błąd: $e');
    return false;
  }
}