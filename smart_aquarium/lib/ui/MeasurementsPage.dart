// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_aquarium/config.dart';

class MeasurementsPage extends StatefulWidget {
  final int userSensorId;
  final int sensorTypeId;

  const MeasurementsPage(this.userSensorId, this.sensorTypeId, {super.key});

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  List<dynamic> measurements = [];

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/measurements'));
    if (response.statusCode == 200) {
      debugPrint('Measurements data successfully fetched');
      final List<dynamic> fetchedMeasurements = jsonDecode(response.body);
      setState(() {
        measurements = fetchedMeasurements
            .where((measurement) =>
                measurement['userSensor']['userSensorId'] ==
                widget.userSensorId)
            .toList();
      });
    } else {
      debugPrint('Error when fetching measurements: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomiary'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
        child: measurements.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: measurements.map((measurement) {
                    return Text(
                      '${measurement['measurementValue']} ${measurement['userSensor']['sensorType']['outputUnit']}',
                      style: const TextStyle(fontSize: 20),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
