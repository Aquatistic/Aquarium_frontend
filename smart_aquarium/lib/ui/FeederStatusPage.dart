import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/config.dart';

class FeederStatusPage extends StatefulWidget {
  final int sensorId;

  const FeederStatusPage(this.sensorId, {super.key});

  @override
  _FeederStatusPageState createState() => _FeederStatusPageState();
}

class _FeederStatusPageState extends State<FeederStatusPage> {
  bool _isFeederFull = false;
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchFeederStatus();
  }

  Future<void> _fetchFeederStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    debugPrint(widget.sensorId.toString());

    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/v1/measurements/last/${widget.sensorId}/1'), // Pobierz status karmnika
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
          _isFeederFull = measuredValue == 1;
          _dataFetched = true;
        }
      });
    } else {
      debugPrint('Error fetching feeder status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Karmnika'),
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
          child: _dataFetched
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isFeederFull
                        ? Icon(Icons.check_circle,
                            color: Colors.green, size: 100)
                        : Icon(Icons.error, color: Colors.red, size: 100),
                    const SizedBox(height: 20),
                    Text(
                      _isFeederFull
                          ? 'Karmnik jest pełny'
                          : 'Karmnik jest pusty',
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
