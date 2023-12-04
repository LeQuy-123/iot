import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_app/model/data_point_model.dart';
import 'package:iot_app/provider/log_provider.dart';
import 'package:http/http.dart' as http;
import 'package:iot_app/provider/token_provider.dart';
import 'dart:math';

import 'package:iot_app/widget/weather_info.dart';

class LineChartSample10 extends StatefulWidget {
  const LineChartSample10(
      {super.key,
      required this.selectedDateTime,
      required this.selectedAssetId,
      required this.ipAddress,
      required this.temperature,
      required this.selectedDateTimeType});
  final DateTime? selectedDateTime;
  final String selectedAssetId;
  final String ipAddress;
  final String temperature;
  final String? selectedDateTimeType;
  final Color sinColor = Colors.redAccent;
  final Color cosColor = Colors.blueAccent;

  @override
  State<LineChartSample10> createState() => _LineChartSample10State();
}

class _LineChartSample10State extends State<LineChartSample10> {
  final limitCount = 100;
  List<DataPoint> listData = [];
  List<FlSpot> lineFl = <FlSpot>[];
  List<dynamic> lineFlFuture = [];

  double xValue = 0;
  double step = 0.05;

  @override
  void didUpdateWidget(covariant LineChartSample10 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if selectedDateTime or selectedAssetId has changed
    if (widget.selectedDateTime != oldWidget.selectedDateTime ||
        widget.selectedAssetId != oldWidget.selectedAssetId) {
      // Call your function here
      fetchData(
          widget.selectedAssetId, widget.selectedDateTime ?? DateTime.now());
    }
    // Check if selectedDateTime or selectedAssetId has changed
    // onTempChanged();
  }

  void onTempChanged() {
    Log.print('onTempChanged changed: ${widget.temperature}');
  }

  Future<void> fetchData(String attributeId, DateTime fromTimestamp) async {
    String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String apiUrl =
        'https://${widget.ipAddress}/api/master/asset/datapoint/$attributeId/attribute/temperature';
    final String apiPredict =
        'https://iot-seven-olive.vercel.app/api/linear-regression?timestamp=$currentTime';
    String interval = '';
    if (widget.selectedDateTimeType == 'H') {
      interval = '5 MINUTE';
    } else if (widget.selectedDateTimeType == 'D') {
      interval = '1 HOUR';
    }
    final Map<String, dynamic> requestBody = {
      "type": "interval",
      "fromTimestamp": fromTimestamp.millisecondsSinceEpoch,
      "toTimestamp": currentTime,
      "interval": interval,
      "gapFill": false,
      "formula": "AVG",
    };
    // Encode the request body to JSON
    final String requestBodyJson = json.encode(requestBody);

    try {
      String? token = await TokenProvider.getToken(widget.ipAddress);
      // Make the POST request
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the access token here
        },
        body: requestBodyJson,
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final List<dynamic> responseData = json.decode(response.body);

        final http.Response futureRes = await http.post(
          Uri.parse(apiPredict),
          headers: {
            'Content-Type': 'application/json',
          },
          body: response.body,
        );
        final Map<String, dynamic> futureResData = json.decode(futureRes.body);
        List<DataPoint> dataPoints =
            responseData.map((json) => DataPoint.fromJson(json)).toList();
        dataPoints.sort((a, b) => a.x.compareTo(b.x));

        List<dynamic> dataPointsFuture = futureResData["body"]
            .map((json) => DataPoint.fromJson(json))
            .toList();
        final List<FlSpot> lf = dataPoints.map((dataPoint) {
          return FlSpot(dataPoint.x, dataPoint.y);
        }).toList();

        setState(() {
          listData = dataPoints;
          lineFl = lf;
          lineFlFuture = dataPointsFuture;
        });
        // Handle the response data as needed
        Log.print('Response Data: $responseData');
      } else {
        Log.print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      Log.print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lineFl.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: ChartData(
                        listData: listData,
                        lineFl: lineFl,
                        interval: widget.selectedDateTimeType),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 15, 0, 0),
                    child: AverageValueWidget(
                      temperature: calculateAverageY(listData).toStringAsFixed(2),
                    ),
                  ),
                  
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 65,
              width: MediaQuery.of(context).size.width - 20,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: lineFlFuture.length,
                itemBuilder: (context, index) {
                  final weather = lineFlFuture[index];
                  // Create a DateTime object from the timestamp
                  DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(weather.x.toInt());
                  // Format the DateTime to a local time string
                  return Container(
                    // width: 70,
                    margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.09, -1.00),
                        end: Alignment(-0.09, 1),
                        colors: [Color(0xFF66E0D1), Color(0xFF579FF1)],
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(children: [
                      Text(
                        formatterH.format(dateTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                        Text(
                        '${weather.y.toStringAsFixed(2)} \u2103',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]),
                  );
                },
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

double calculateAverageY(List<DataPoint> data) {
  if (data.isEmpty) {
    return 0.0; // Return 0 if the list is empty to avoid division by zero
  }

  double sumY = 0;

  for (var dataPoint in data) {
    sumY += dataPoint.y;
  }

  double averageY = sumY / data.length;
  return averageY;
}

class ChartData extends StatelessWidget {
  const ChartData({
    super.key,
    required this.listData,
    required this.lineFl,
    required this.interval,
  });

  final List<DataPoint> listData;
  final List<FlSpot> lineFl;
  final String? interval;

  @override
  Widget build(BuildContext context) {
    double it = 60000;
    if (interval == 'H') {
      it = 60000 * 10;
    } else if (interval == 'D') {
      it = 60000 * 60 * 4;
    }
    return LayoutBuilder(builder: (context, constraints) {
      return LineChart(
        LineChartData(
            minY: 20,
            maxY: 40,
            // minX: listData.first.x,
            // maxX: listData.last.x,
            lineTouchData: const LineTouchData(enabled: false),
            clipData: const FlClipData.all(),
            gridData: const FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: lineFl,
                dotData: const FlDotData(
                  show: false,
                ),
                isCurved: true,
                isStrokeCapRound: true,
                barWidth: 2,
              )
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value % 1 != 0 ||
                        value == meta.max ||
                        value == meta.min) {
                      return Container();
                    }
                    final style = TextStyle(
                      color: Colors.blueAccent,
                      fontSize: min(11, 11 * constraints.maxWidth / 300),
                    );
                    DateTime dateTime =
                        DateTime.fromMillisecondsSinceEpoch((value).toInt());
                    String formattedTime = DateFormat.Hm().format(dateTime);
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 5,
                      child: Text(formattedTime, style: style),
                    );
                  },
                  interval: it,
                ),
                drawBelowEverything: true,
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles()),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                showTitles: false,
              )),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final style = TextStyle(
                      color: Colors.blueAccent,
                      fontSize: min(10, 10 * constraints.maxWidth / 300),
                    );
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 16,
                      child: Text('${meta.formattedValue}\u2103', style: style),
                    );
                  },
                  reservedSize: 56,
                ),
                drawBelowEverything: true,
              ),
            )),
      );
    });
  }
}

class AverageValueWidget extends StatelessWidget {
  final String temperature;

  const AverageValueWidget({Key? key, required this.temperature})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade500],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Average Value:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              '$temperature \u2103',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
