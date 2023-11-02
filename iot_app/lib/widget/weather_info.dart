import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:iot_app/model/sun_info.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  WeatherInfoState createState() => WeatherInfoState();
}

final formatter = DateFormat('MM/dd');
final formatterH = DateFormat('HH:mm');

class WeatherInfoState extends State<WeatherInfo> {
  List<SunInfo> forecastData = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    const lat = '10.82302';
    const lon = '106.62965';
    const apiUrl = 'https://api.sunrisesunset.io/json?lat=$lat&lng=$lon';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        forecastData = (data['list'] as List)
            .map((item) => SunInfo.fromJson(item))
            .toList();
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container()
    );
  }
}
 