import 'package:flutter/material.dart';
import 'package:smart_aquarium/ui/SensorsPage.dart';


class DetailsPage extends StatelessWidget {
  final int aquariumId;
  final String aquariumName;

  DetailsPage(this.aquariumId, this.aquariumName);


  void _measurements(BuildContext context) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SensorsPage(this.aquariumId)),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Twoje akwarium',
        ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              aquariumName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(

              'assets/aqua.png',
              height: 200,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ElevatedButton(
              onPressed: () {
              },
              child: Text(
                'Alarmy',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ElevatedButton(
              onPressed: () {
              },
              child: Text(
                'Zarządzaj akwarium',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ElevatedButton(
              onPressed: () => _measurements(context),
              child: Text(
                'Pomiary',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ElevatedButton(
              onPressed: () {
              },
              child: Text(
                'Rybki',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ElevatedButton(
              onPressed: () {
              },
              child: Text(
                'Ustawienia',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
