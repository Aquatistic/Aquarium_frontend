import 'package:flutter/material.dart';


class DetailsPage extends StatelessWidget {
  final String imagePath;
  final String imageName;

  DetailsPage(this.imagePath, this.imageName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły akwarium'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              imageName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Image.asset(
              imagePath,
              width: 300, // Ustaw szerokość obrazka na ekranie
              height: 300, // Ustaw wysokość obrazka na ekranie
            ),
          ],
        ),
      ),
    );
  }
}