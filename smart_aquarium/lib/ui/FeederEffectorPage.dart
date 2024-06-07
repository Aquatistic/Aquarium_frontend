import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smart_aquarium/config.dart';

class FeederEffectorPage extends StatefulWidget {
  final int aquariumId;
  final int effectorId;

  const FeederEffectorPage(this.aquariumId, this.effectorId, {super.key});

  @override
  _FeederEffectorPageState createState() => _FeederEffectorPageState();
}

class _FeederEffectorPageState extends State<FeederEffectorPage> {
  DateTime? _controlActivationMoment;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('pl_PL', null);
    setState(() {}); // Refresh the UI after initialization
  }

  Future<void> _feedFish() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz ilość karmy')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(DateTime.now());
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    debugPrint('Amount: $amount');
    debugPrint('Date: $formattedDate');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/userEffector/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'aquariumId': widget.aquariumId,
        'effectorId': widget.effectorId,
        'value': amount,
        'controllActivationMoment': formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Fish fed successfully');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ryby nakarmione pomyślnie')));
    } else {
      debugPrint('Error feeding fish: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd podczas karmienia ryb')));
    }
  }

  Future<void> _scheduleFeeding() async {
    if (_amountController.text.isEmpty || _controlActivationMoment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz ilość karmy i wybierz datę')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(_controlActivationMoment!);
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    debugPrint('Amount: $amount');
    debugPrint('Date: $formattedDate');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/userEffector/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'aquariumId': widget.aquariumId,
        'effectorId': widget.effectorId,
        'value': amount,
        'controllActivationMoment': formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Feeding scheduled successfully');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karmienie zaplanowane pomyślnie')));
    } else {
      debugPrint('Error scheduling feeding: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd podczas planowania karmienia')));
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wpisz ilość karmy w gramach',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _feedFish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Nakarm teraz',
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
                onPressed: (_amountController.text.isNotEmpty &&
                        _dateController.text.isNotEmpty)
                    ? _scheduleFeeding
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
                  'Zaplanuj karmienie',
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
