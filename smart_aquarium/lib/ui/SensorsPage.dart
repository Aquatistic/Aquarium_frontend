import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/ui/MeasurementsPage.dart';

class SensorsPage extends StatefulWidget {
  final int aquariumId;
    @override
  _SensorsPageState createState() => _SensorsPageState();

  SensorsPage(this.aquariumId);
}
  class _SensorsPageState extends State<SensorsPage> {
    List<dynamic> validUserSensors = [];

     @override
  void initState() {
    super.initState();
    _fetchSensors(); 
  }

Future<List<dynamic>> _fetchSensors() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int aquariumId = prefs.getInt('aquarium_id') ?? 0;
    
      final response = await http.get(Uri.parse('http://localhost:6868/api/v1/userSensor'));
      if (response.statusCode == 200) {
        final List<dynamic> userSensors = jsonDecode(response.body);
      validUserSensors = userSensors.where((sensor) => sensor['aquarium']['aquariumId'] == aquariumId).toList();
      }
        return validUserSensors;
  }
 @override
  Widget build(BuildContext context) {
      return FutureBuilder<List<dynamic>>(
    future: _fetchSensors(),
    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
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
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: validUserSensors.length,
                itemBuilder: (context, index) {
                      String buttonText;
                  if (validUserSensors[index]['sensorType']['sensorTypeId'] == 1) {
                    buttonText = 'Temperatura';
                  } else if (validUserSensors[index]['sensorType']['sensorTypeId'] == 2) {
                    buttonText = 'Poziom wody';
                  } else if (validUserSensors[index]['sensorType']['sensorTypeId'] == 3) {
                    buttonText = 'Kolor';
                   }else if (validUserSensors[index]['sensorType']['sensorTypeId'] == 4) {
                    buttonText = 'PH';
                   } else {
                    buttonText = 'Inny sensor';
                  }
return Column(
    children: [
      Container(
        height: 50.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeasurementsPage(validUserSensors[index]['userSensorId'], validUserSensors[index]['sensorType']['sensorTypeId']),
              ),
            );
          },
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            elevation: 0,
          ),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
                  
                },
              ),
            ),
          ],
        ),
      ),
    );
          }
    },
  );

  }
}
