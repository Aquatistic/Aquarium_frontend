import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_aquarium/config.dart';

class TemperaturePage extends StatefulWidget {
  final int sensorId;

  const TemperaturePage(this.sensorId, {super.key});

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  List<dynamic> _measurements = [];
  int _days = 1; // Default to last 1 day

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/v1/measurements/last/${widget.sensorId}/30'), // Pobierz dane z ostatnich 30 dni
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _measurements = jsonDecode(response.body);
      });
    } else {
      debugPrint('Error fetching measurements: ${response.statusCode}');
    }
  }

  List<FlSpot> _getFilteredSpots() {
    final now = DateTime.now();
    final filteredMeasurements = _measurements.where((measurement) {
      final DateTime date = DateFormat('yyyy-MM-dd HH:mm:ss')
          .parse(measurement['measurementTimestamp']);
      return date.isAfter(now.subtract(Duration(days: _days)));
    }).toList();

    return filteredMeasurements.map((measurement) {
      final DateTime date = DateFormat('yyyy-MM-dd HH:mm:ss')
          .parse(measurement['measurementTimestamp']);
      final double value = measurement['measurementValue'];
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wykres Temperatury'),
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
              'Wybierz zakres dni:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_days > 1) {
                        _days--;
                      }
                    });
                  },
                ),
                Text(
                  '$_days dni',
                  style: const TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _days++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5, // Adjust the interval to avoid clutter
                          getTitlesWidget: (value, meta) {
                            return Text('$value°C',
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval:
                              60000000, // Adjust the interval to show appropriate number of labels
                          getTitlesWidget: (value, meta) {
                            final DateTime date =
                                DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt());
                            return Text(DateFormat('dd/MM HH:mm').format(date),
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getFilteredSpots(),
                        isCurved: false, // Set to false for straight lines
                        barWidth: 2,
                        color: Colors.blue,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final DateTime date =
                                DateTime.fromMillisecondsSinceEpoch(
                                    spot.x.toInt());
                            return LineTooltipItem(
                              '${spot.y}°C\n${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
