import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MeasurementsPage extends StatefulWidget {
  final int aquariumId;

  MeasurementsPage(this.aquariumId);

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  bool _isLoading = true;
  double _temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:6868/api/v1/measurements'));
      if (response.statusCode == 200) {
        final List<dynamic> measurements = jsonDecode(response.body);
        final latestMeasurement = _findLatestMeasurement(measurements);
        setState(() {
          _temperature = latestMeasurement['measurementValue'].toDouble();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load measurement data');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _findLatestMeasurement(List<dynamic> measurements) {
    Map<String, dynamic> latestMeasurement = measurements[0];
    for (var measurement in measurements) {
      if (DateTime.parse(measurement['measurementTimestamp']).isAfter(
          DateTime.parse(latestMeasurement['measurementTimestamp']))) {
        latestMeasurement = measurement;
      }
    }
    return latestMeasurement;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomiary'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Temperatura:',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    '$_temperature °C',
                    style: TextStyle(fontSize: 24.0, color: Colors.blue),
                  ),
                ],
              ),
            ),
    );
  }
}