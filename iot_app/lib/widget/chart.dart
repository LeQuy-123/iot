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
      required this.temperature});
  final DateTime? selectedDateTime; 
  final String selectedAssetId; 
  final String ipAddress;
  final String temperature;

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

  late Timer timer;
  double interval = 60000;
  @override
  void didUpdateWidget(covariant LineChartSample10 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if selectedDateTime or selectedAssetId has changed
    if (widget.selectedDateTime != oldWidget.selectedDateTime ||
        widget.selectedAssetId != oldWidget.selectedAssetId) {
      // Call your function here
      onDataChanged();
    }
     // Check if selectedDateTime or selectedAssetId has changed
    onTempChanged();

  }

  // Function to be called when selectedDateTime or selectedAssetId changes
  void onDataChanged() {
    Log.print(
        'Data changed: ${widget.selectedDateTime}, ${widget.selectedAssetId}');
    if(widget.selectedDateTime != null) {
      fetchData(widget.selectedAssetId, widget.selectedDateTime ?? DateTime.now());
      // Check if selectedDateTime is in the last hour
      if (widget.selectedDateTime!.isAfter(DateTime.now().subtract(const Duration(hours: 1)))) {
        setState(() {
          interval =  60000;
        });
      }

      if (widget.selectedDateTime!.day == DateTime.now().day &&
          widget.selectedDateTime!.month == DateTime.now().month &&
          widget.selectedDateTime!.year == DateTime.now().year) {
        setState(() {
          interval = 60000 * 60;
        });
      }

      // Check if selectedDateTime is in the last week
      if (widget.selectedDateTime!.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        setState(() {
          interval = 60000 * 60 *24;
        });
      }

      // Check if selectedDateTime is in the last month
      if (widget.selectedDateTime!.month ==
              DateTime.now().subtract(const Duration(days: 30)).month &&
          widget.selectedDateTime!.year ==
              DateTime.now().subtract(const Duration(days: 30)).year) {
        setState(() {
          interval = 60000 * 60 * 24 * 7;
        });
      }
    }
  }
  void onTempChanged() {
    Log.print(
        'onTempChanged changed: ${widget.temperature}');
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
    final Map<String, dynamic> requestBody = {
      "type": "lttb",
      "fromTimestamp": fromTimestamp.millisecondsSinceEpoch,
      "toTimestamp": DateTime.now().millisecondsSinceEpoch,
      "amountOfPoints": 30,
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
        final List<FlSpot> lf = dataPoints.map((dataPoint) {
          return FlSpot(dataPoint.x - dataPoints.first.x, dataPoint.y);
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 50,
                        minX: 0,
                        maxX: listData.last.x -  listData.first.x,
                        lineTouchData: const LineTouchData(enabled: false),
                        clipData: const FlClipData.all(),
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          sinLine(lineFl),
                        ],
                        
                        titlesData: FlTitlesData( 
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) =>
                                  bottomTitleWidgets(
                                      value, meta, constraints.maxWidth),
                              interval: interval,
                            ),
                            drawBelowEverything: true,
                          ),
                          rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                            )),
                          topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: false,
                            )),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) =>
                                  leftTitleWidgets(
                                      value, meta, constraints.maxWidth),
                              reservedSize: 56,
                            ),
                            drawBelowEverything: true,
                          ),
                          
                        )
                        
                      ),
                    );
                  }
                ),
              )
            ],
          )
        : Container();
  }

  LineChartBarData sinLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      isCurved: true,
      isStrokeCapRound: true,
      barWidth: 2,
    );
  }

   Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) {
      return Container();
    }
    final style = TextStyle(
      color: Colors.blueAccent,
      fontSize: min(11, 11 * chartWidth / 300),
    );
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch((value + listData.first.x).toInt());
    String formattedTime = DateFormat.Hm().format(dateTime);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text(formattedTime, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      color: Colors.blueAccent,
      fontSize: min(10, 10 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text('${meta.formattedValue}\u2103', style: style),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
