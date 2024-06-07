import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:smart_aquarium/config.dart';

class SwitchEffectorPage extends StatefulWidget {
  final int aquariumId;
  final int effectorId;

  const SwitchEffectorPage(this.aquariumId, this.effectorId, {super.key});

  @override
  _SwitchEffectorPageState createState() => _SwitchEffectorPageState();
}

class _SwitchEffectorPageState extends State<SwitchEffectorPage> {
  DateTime? _controlActivationMoment;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _switchEffector() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(DateTime.now());

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
      debugPrint('Switched successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Włącznik włączony pomyślnie')),
      );
    } else {
      debugPrint('Error in switching: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas włączania włącznika')),
      );
    }
  }

  Future<void> _scheduleSwitchEffector() async {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz datę i godzinę')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(_controlActivationMoment!);

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
      debugPrint('Switch scheduled successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planowanie włącznika pomyślnie')),
      );
    } else {
      debugPrint('Error scheduling switch: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas planowania włącznika')),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _controlActivationMoment = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(_controlActivationMoment!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Włącznik'),
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
              'Włącznik',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _switchEffector,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Włącz',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDateTime(context),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wybierz datę i godzinę',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: (_dateController.text.isNotEmpty)
                    ? _scheduleSwitchEffector
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Zaplanuj włączenie',
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
