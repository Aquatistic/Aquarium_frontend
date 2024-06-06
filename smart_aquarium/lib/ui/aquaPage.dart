// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:smart_aquarium/ui/SensorsPage.dart';
import 'package:smart_aquarium/ui/FishPage.dart';
import 'package:smart_aquarium/ui/effectorsPage.dart';

class DetailsPage extends StatelessWidget {
  final int aquariumId;
  final String aquariumName;

  const DetailsPage(this.aquariumId, this.aquariumName, {super.key});

  void _sensorsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SensorsPage(aquariumId)),
    );
  }

  void _fishPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FishPage(aquariumId)),
    );
  }

  void _effectorsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EffectorsPage(aquariumId)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                aquariumName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/aqua.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () => _effectorsPage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                child: const Text(
                  'Zarządzaj akwarium',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () => _sensorsPage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                child: const Text(
                  'Pomiary',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () => _fishPage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                child: const Text(
                  'Rybki',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
