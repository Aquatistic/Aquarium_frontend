import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/config.dart';

class WaterLevelPage extends StatefulWidget {
  final int sensorId;

  const WaterLevelPage(this.sensorId, {super.key});

  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  double _waterLevel = 0.0;
  final double maxLoweringInCm = 50.0;

  @override
  void initState() {
    super.initState();
    _fetchWaterLevel();
  }

  Future<void> _fetchWaterLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/v1/measurements/last/${widget.sensorId}/1'), // Pobierz najnowszy poziom wody
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        if (data.isNotEmpty) {
          double measuredValue = data[0]['measurementValue'];
          _waterLevel = (maxLoweringInCm - measuredValue) / maxLoweringInCm;
        }
      });
    } else {
      debugPrint('Error fetching water level: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poziom Wody'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aktualny Poziom Wody:',
                style: TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 20),
              _buildWaterLevelIndicator(),
              const SizedBox(height: 20),
              Text(
                '${_waterLevel * 100}%', // Przedstawienie poziomu wody jako procent
                style: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Obniżenie poziomu wody: ${(maxLoweringInCm - _waterLevel * maxLoweringInCm).toStringAsFixed(2)} cm',
                style: const TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterLevelIndicator() {
    return Container(
      width: 100,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            height: _waterLevel * 300, // Adjust height based on water level
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
