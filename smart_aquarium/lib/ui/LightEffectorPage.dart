import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:smart_aquarium/config.dart';

class LightEffectorPage extends StatefulWidget {
  final int aquariumId;
  final int effectorId;

  const LightEffectorPage(this.aquariumId, this.effectorId, {super.key});

  @override
  _LightEffectorPageState createState() => _LightEffectorPageState();
}

class _LightEffectorPageState extends State<LightEffectorPage> {
  double _lightIntensity = 0.0;

  Future<void> _updateLightIntensity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    DateTime _controlActivationMoment = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(_controlActivationMoment);

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/userEffector/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'aquariumId': widget.aquariumId,
        'effectorId': widget.effectorId,
        'value': _lightIntensity,
        "controllActivationMoment": formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Light intensity updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oświetlenie zaktualizowane pomyślnie')),
      );
    } else {
      debugPrint('Error updating light intensity: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas aktualizacji oświetlenia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzaj oświetleniem'),
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
            const Text(
              'Ustaw intensywność światła',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            Slider(
              value: _lightIntensity,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: _lightIntensity.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _lightIntensity = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Container(
              height: 50.0,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _updateLightIntensity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                child: const Text(
                  'Aktualizuj oświetlenie',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
