import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/ui/aquaPage.dart';


class AquariumsPage extends StatefulWidget {
  @override
  State<AquariumsPage> createState() => _AquariumsPageState();
}

class _AquariumsPageState extends State<AquariumsPage> {
  List<Map<String, dynamic>> _aquariums = [];

  @override
  void initState() {
    super.initState();
    _loadAquariums(); 
  }

  Future<void> _loadAquariums() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int loggedInUserId = prefs.getInt('logged_in_user') ?? 0; 
    if (loggedInUserId != 0) {
      final response = await http.get(Uri.parse('http://localhost:6868/api/v1/aquarium/users/$loggedInUserId'));

    if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _aquariums = data.map((item) => {
            'aquariumId': item['aquariumId'],
            'aquariumName': item['aquariumName'],
            'aquariumCapacity': item['aquariumCapacity'],
            'imagePath': 'assets/aqua.png', 
          }).toList();
        });
      } else {
        print('Błąd podczas ładowania akwariów: ${response.statusCode}');
      }
    } else {
      print('Błąd podczas ładowania użytkownika');
    }
  }

  Future<void> _addAquarium(String aquariumName, int aquariumCapacity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int loggedInUserId = prefs.getInt('logged_in_user') ?? 0;

    if (loggedInUserId != 0) {
      final response = await http.post(
        Uri.parse('http://localhost:6868/api/v1/aquarium/add'),
        body: jsonEncode({

          'aquariumName': aquariumName,
          'aquariumCapacity': aquariumCapacity,
          'userId': loggedInUserId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Akwarium zostało pomyślnie dodane.');
        _loadAquariums(); 
      } else {
        print('Błąd podczas dodawania akwarium: ${response.statusCode}');
      }
    } else {
      print("brak zalogowanego usera");
    }
  }

  void _showAddAquariumDialog() {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _capacityController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Dodaj akwarium"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: "Nazwa akwarium"),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _capacityController,
              decoration: InputDecoration(hintText: "Pojemność akwarium"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Dodaj"),
            onPressed: () {
              String aquariumName = _nameController.text;
              int aquariumCapacity = int.tryParse(_capacityController.text) ?? 0;
              if (aquariumName.isNotEmpty && aquariumCapacity > 0) {
                _addAquarium(aquariumName, aquariumCapacity);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  void _navigateToDetailsPage(int aquariumId, String aquariumName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('aquarium_id', aquariumId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(aquariumId, aquariumName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Twoje akwaria',
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
        child: ListView.builder(
          itemCount: _aquariums.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _navigateToDetailsPage(
                _aquariums[index]['aquariumId']!,
                _aquariums[index]['aquariumName']!,
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      _aquariums[index]['aquariumName']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Pojemność: ${_aquariums[index]['aquariumCapacity']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Image.asset(
                      _aquariums[index]['imagePath']!,
                      width: 200, 
                      height: 200, 
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAquariumDialog,
        tooltip: 'Dodaj akwarium',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
