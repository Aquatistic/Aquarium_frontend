import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeasurementsPage extends StatefulWidget {
  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  String measurementValue = '';

  Future<void> fetchMeasurementValue() async {
    var url = Uri.parse('http://localhost:6868/api/v1/measurements');

    var response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        measurementValue = jsonData['measurementValue'].toString();
      });
    } else {
      throw Exception('Failed to load measurement value');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMeasurementValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomiary'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Odczytana wartość: $measurementValue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
                  var url = Uri.parse('http://localhost:6868/api/v1/userSensor/add?sensorTypeId=1&aquariumId=1');
                  var response = await http.post(url);
              
              if (response.statusCode == 200) {
                // Wysłano pomyślnie
              } else {
                throw Exception('Failed to add sensor');
              }
            },
            child: Text('Dodaj nowy czujnik'),
          ),
          SizedBox(height: 20),
          // Tutaj możesz wyświetlać przyciski z czujnikami odczytanymi za pomocą GET z adresu http://localhost:6868/api/v1/userSensor
          // Każdy przycisk powinien mieć odpowiednie dane czujnika
        ],
      ),
    );
  }
}
