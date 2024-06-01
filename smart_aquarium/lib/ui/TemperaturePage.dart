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
  int _days = 1;

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

  String _getLatestMeasurement() {
    if (_measurements.isEmpty) return 'Brak danych';
    final latestMeasurement = _measurements.first;
    final latestDate = DateFormat('yyyy-MM-dd HH:mm:ss')
        .parse(latestMeasurement['measurementTimestamp']);
    final latestValue = latestMeasurement['measurementValue'];
    return '${latestValue}°C\n${DateFormat('dd/MM/yyyy HH:mm').format(latestDate)}';
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
            Text(
              'Najnowsza zmierzona wartość:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              _getLatestMeasurement(),
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 30.0, left: 6.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '${value.toInt()}°C',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final List<FlSpot> spots = _getFilteredSpots();
                            if (spots.isEmpty) {
                              return const Text('');
                            }
                            final DateTime date =
                                DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt());

                            final double firstX = spots.first.x;
                            final double lastX = spots.last.x;
                            final double middleX =
                                firstX + (lastX - firstX) / 2;

                            double closestToMiddleX = firstX;
                            for (final spot in spots) {
                              if ((spot.x - middleX).abs() <
                                  (closestToMiddleX - middleX).abs()) {
                                closestToMiddleX = spot.x;
                              }
                            }

                            if (value == firstX ||
                                value == closestToMiddleX ||
                                value == lastX) {
                              return Text(
                                  DateFormat('dd/MM HH:mm').format(date),
                                  style: const TextStyle(fontSize: 10));
                            } else {
                              return const Text('');
                            }
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
                    // minX: _getFilteredSpots().isNotEmpty
                    //     ? _getFilteredSpots().first.x - 3600000 // Safe offset of 1 hour in milliseconds
                    //     : 0,
                    // maxX: _getFilteredSpots().isNotEmpty
                    //     ? _getFilteredSpots().last.x + 3600000 // Safe offset of 1 hour in milliseconds
                    //     : 0,
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
