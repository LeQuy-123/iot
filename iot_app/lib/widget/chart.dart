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
    // while (lineFl.length > limitCount) {
    //   lineFl.removeAt(0);
    // }
    // setState(() {
    //   lineFl.add(FlSpot(xValue, double.parse(widget.temperature)));
    // });
    // xValue += step;
  }

  Future<void> fetchData(String attributeId, DateTime fromTimestamp) async {
    final String apiUrl =
        'https://${widget.ipAddress}/api/master/asset/datapoint/$attributeId/attribute/temperature';
    String interval = '';
    if (widget.selectedDateTimeType == 'H') {
      interval = '5 MINUTE';
    } else if (widget.selectedDateTimeType == 'D') {
      interval = '1 HOUR';
    }
    final Map<String, dynamic> requestBody = {
      "type": "interval",
      "fromTimestamp": fromTimestamp.millisecondsSinceEpoch,
      "toTimestamp": DateTime.now().millisecondsSinceEpoch,
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
        List<DataPoint> dataPoints =
            responseData.map((json) => DataPoint.fromJson(json)).toList();
        dataPoints.sort((a, b) => a.x.compareTo(b.x));
        final List<FlSpot> lf = dataPoints.map((dataPoint) {
          return FlSpot(dataPoint.x, dataPoint.y);
        }).toList();
        setState(() {
          listData = dataPoints;
          lineFl = lf;
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
    return lineFl.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.5,
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
              )
            ],
          )
        : Container();
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
