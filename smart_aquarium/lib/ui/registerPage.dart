import 'package:flutter/material.dart';
import 'package:smart_aquarium/ui/loginPage.dart';


class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _register(BuildContext context) {
    // Tutaj dodaj kod logiki uwierzytelniania
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

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
  onPressed: () => _register(context),
  child: Text(
    'Masz już konto?',
    style: TextStyle(fontSize: 20.0, color: Colors.blue), // Styl tekstu przycisku
  ),
),
            ],
          ),
        ),
      ),
            // Figma Flutter Generator CreatteaccountWidget - FRAME
    );
  }
}


