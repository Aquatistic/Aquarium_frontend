import 'package:flutter/material.dart';
import 'package:smart_aquarium/ui/aquaPage.dart';

class aquariumsPage extends StatefulWidget {
  @override
  State<aquariumsPage> createState() => _aquariumsPageState();
}

class _aquariumsPageState extends State<aquariumsPage> {
  List<Map<String, String>> _images = [];
  int _counter = 0;
  TextEditingController _textFieldController = TextEditingController();

  void _addImage(String imageName) {
    setState(() {
      _counter++;
      _images.add({
        'name': imageName,
        'path': 'assets/aqua.png',
      });
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Dodaj akwarium"),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Nazwa akwarium"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Dodaj"),
              onPressed: () {
                String imageName = _textFieldController.text;
                if (imageName.isNotEmpty) {
                  _addImage(imageName);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetailsPage(String imagePath, String imageName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(imagePath, imageName),
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
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _navigateToDetailsPage(
                _images[index]['path']!,
                _images[index]['name']!,
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      _images[index]['name']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      _images[index]['path']!,
                      width: 200, // Ustaw szerokość obrazka na ekranie
                      height: 200, // Ustaw wysokość obrazka na ekranie
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Dodaj obrazek',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
