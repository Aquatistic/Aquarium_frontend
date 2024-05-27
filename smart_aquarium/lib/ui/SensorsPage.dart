// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/ui/MeasurementsPage.dart';
import 'package:smart_aquarium/config.dart';

class SensorsPage extends StatefulWidget {
  final int aquariumId;
  @override
  _SensorsPageState createState() => _SensorsPageState();

  const SensorsPage(this.aquariumId, {super.key});
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
    String token = prefs.getString('token') ?? '';

    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/userSensor'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      debugPrint('UserSensors data successfully fetched');
      final List<dynamic> userSensors = jsonDecode(response.body);
      validUserSensors = userSensors
          .where((sensor) => sensor['aquarium']['aquariumId'] == aquariumId)
          .toList();
    } else {
      debugPrint('Error when fetching userSensors: ${response.statusCode}');
    }
    return validUserSensors;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSensors(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Twoje akwarium',
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: validUserSensors.length,
                      itemBuilder: (context, index) {
                        String buttonText;
                        switch (validUserSensors[index]['sensorType']
                            ['sensorTypeId']) {
                          case 1:
                            buttonText = 'Temperatura';
                            break;
                          case 2:
                            buttonText = 'Poziom wody';
                            break;
                          case 3:
                            buttonText = 'Napełnienie Karmnika';
                            break;
                          case 4:
                            buttonText = 'PH';
                            break;
                          default:
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
                                      builder: (context) => MeasurementsPage(
                                          validUserSensors[index]
                                              ['userSensorId'],
                                          validUserSensors[index]['sensorType']
                                              ['sensorTypeId']),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  elevation: 0,
                                ),
                                child: Text(
                                  buttonText,
                                  style: const TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
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
