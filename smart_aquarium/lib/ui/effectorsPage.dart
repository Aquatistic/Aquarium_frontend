// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/config.dart';
import 'package:smart_aquarium/ui/LightEffectorPage.dart';
import 'package:smart_aquarium/ui/FeederEffectorPage.dart';
import 'package:smart_aquarium/ui/SwitchEffectorPage.dart';

class EffectorsPage extends StatefulWidget {
  final int aquariumId;
  @override
  _EffectorsPageState createState() => _EffectorsPageState();

  const EffectorsPage(this.aquariumId, {super.key});
}

class _EffectorsPageState extends State<EffectorsPage> {
  List<dynamic> validUserEffectors = [];

  @override
  void initState() {
    super.initState();
    _fetchEffectors();
  }

  Future<List<dynamic>> _fetchEffectors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int aquariumId = prefs.getInt('aquarium_id') ?? 0;
    String token = prefs.getString('token') ?? '';

    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/userEffector'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      debugPrint('UserEffectors data successfully fetched');
      final List<dynamic> userEffectors = jsonDecode(response.body);
      validUserEffectors = userEffectors
          .where((effector) => effector['aquarium']['aquariumId'] == aquariumId)
          .toList();
    } else {
      debugPrint('Error when fetching userEffectors: ${response.statusCode}');
    }
    return validUserEffectors;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchEffectors(),
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
                      itemCount: validUserEffectors.length,
                      itemBuilder: (context, index) {
                        String buttonText;
                        switch (validUserEffectors[index]['effectorType']
                            ['effectorTypeId']) {
                          case 1:
                            buttonText = 'Oświetlenie';
                            break;
                          case 2:
                            buttonText = 'Karmnik';
                            break;
                          case 3:
                            buttonText = 'Włącznik';
                            break;
                          default:
                            buttonText = 'Inny efektor';
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
                                  if (validUserEffectors[index]['effectorType']
                                          ['effectorTypeId'] ==
                                      1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LightEffectorPage(
                                            widget.aquariumId,
                                            validUserEffectors[index]
                                                ['userEffectorTypeId']),
                                      ),
                                    );
                                  } else if (validUserEffectors[index]
                                          ['effectorType']['effectorTypeId'] ==
                                      2) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FeederEffectorPage(
                                                widget.aquariumId,
                                                validUserEffectors[index]
                                                    ['userEffectorTypeId']),
                                      ),
                                    );
                                  } else if (validUserEffectors[index]
                                          ['effectorType']['effectorTypeId'] ==
                                      3) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SwitchEffectorPage(
                                                widget.aquariumId,
                                                validUserEffectors[index]
                                                    ['userEffectorTypeId']),
                                      ),
                                    );
                                  }
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
