import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aquarium/config.dart';
import 'package:flutter/widgets.dart';

class FishPage extends StatefulWidget {
  final int aquariumId;

  const FishPage(this.aquariumId, {super.key});

  @override
  _FishPageState createState() => _FishPageState();
}

class _FishPageState extends State<FishPage> {
  List<Map<String, dynamic>> _fishList = [];
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchFish();
  }

  Future<void> _fetchFish() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/fish/aquarium/${widget.aquariumId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      Map<int, Map<String, dynamic>> fishMap = {};

      for (var item in data) {
        int fishTypeId = item['fishType']['fishTypeId'];
        if (fishMap.containsKey(fishTypeId)) {
          fishMap[fishTypeId]!['count'] += item['count'];
        } else {
          fishMap[fishTypeId] = {
            'fishId': item['fishId'],
            'fishTypeId': fishTypeId,
            'fishName': item['fishType']['name'],
            'count': item['count'],
            'imagePath': 'assets/${_getFishName(fishTypeId)}.png',
          };
        }
      }

      setState(() {
        _fishList = fishMap.values.toList();
        _dataFetched = true;
      });
    } else {
      debugPrint('Error fetching fish: ${response.statusCode}');
    }
  }

  Future<void> _addFish(int fishTypeId, int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse(
          '$baseUrl/api/v1/fish/add?fishTypeId=$fishTypeId&aquariumId=${widget.aquariumId}&count=$count'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      _fetchFish();
    } else {
      debugPrint('Error adding fish: ${response.statusCode}');
    }
  }

  void _showAddFishDialog() {
    int _selectedFishTypeId = 1;
    int _fishCount = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Dodaj rybki"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Typ Rybki:'),
                  const SizedBox(width: 10),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButton<int>(
                        value: _selectedFishTypeId,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedFishTypeId = newValue!;
                          });
                        },
                        items: <int>[1, 2, 3, 4, 5, 6, 7, 8]
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(_getFishName(value)),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Ilość:'),
                  const SizedBox(width: 10),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButton<int>(
                        value: _fishCount,
                        onChanged: (int? newValue) {
                          setState(() {
                            _fishCount = newValue!;
                          });
                        },
                        items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Dodaj"),
              onPressed: () {
                _addFish(_selectedFishTypeId, _fishCount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getFishName(int fishTypeId) {
    switch (fishTypeId) {
      case 1:
        return 'Guppy';
      case 2:
        return 'Neon Tetra';
      case 3:
        return 'Molly';
      case 4:
        return 'Swordtail';
      case 5:
        return 'Platy';
      case 6:
        return 'Zebrafish';
      case 7:
        return 'Barb';
      case 8:
        return 'Ram Cichlid';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Rybki'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 190, 230, 255)],
          ),
        ),
        child: _dataFetched
            ? Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: _fishList.length,
                      itemBuilder: (context, index) {
                        final fish = _fishList[index];
                        return Card(
                          elevation: 4,
                          child: Column(
                            children: [
                              Text(
                                fish['fishName'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ilość: ${fish['count']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Expanded(
                                child: Image.asset(
                                  fish['imagePath'],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFishDialog,
        tooltip: 'Dodaj rybki',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
