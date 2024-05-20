import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeasurementsPage extends StatefulWidget {
  final int userSensorId;
  final int sensorTypeId;

  MeasurementsPage(this.userSensorId, this.sensorTypeId);
  

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
    final response = await http.get(Uri.parse('http://localhost:6868/api/v1/measurements'));
    if (response.statusCode == 200) {
      final List<dynamic> fetchedMeasurements = jsonDecode(response.body);
      setState(() {
        measurements = fetchedMeasurements.where((measurement) => measurement['userSensor']['userSensorId'] == widget.userSensorId).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomiary'),
      ),
       body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
      child: measurements.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: measurements.map((measurement) {
                  return Text(
                    '${measurement['measurementValue']} ${measurement['userSensor']['sensorType']['outputUnit']}',
                    style: TextStyle(fontSize: 20),
                  );
                }).toList(),
              ),
            ),
    ),
    );
  }
}