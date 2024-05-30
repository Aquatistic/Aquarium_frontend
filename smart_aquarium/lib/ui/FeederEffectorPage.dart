import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:smart_aquarium/config.dart';

class FeederEffectorPage extends StatefulWidget {
  final int aquariumId;
  final int effectorId;

  const FeederEffectorPage(this.aquariumId, this.effectorId, {super.key});

  @override
  _FeederEffectorPageState createState() => _FeederEffectorPageState();
}

class _FeederEffectorPageState extends State<FeederEffectorPage> {
  DateTime _controlActivationMoment = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _feedFish() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

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
        'value': 1.0,
        'controllActivationMoment': formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Fish fed successfully');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fish fed successfully')));
    } else {
      debugPrint('Error feeding fish: ${response.statusCode}');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error feeding fish')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karmnik'),
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
              'Nakarm ryby',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/fish.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Container(
              height: 50.0,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _feedFish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Nakarm',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
