import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class WeatherForecast extends StatefulWidget {
  const WeatherForecast({super.key});

  @override
  WeatherForecastState createState() => WeatherForecastState();
}

final formatter = DateFormat('MM/dd');
final formatterH = DateFormat('HH:mm');

class WeatherForecastState extends State<WeatherForecast> {
  List<WeatherData> forecastData = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    const apiKey = 'ed02b217540012b28c3d6ff72c8ac711';
    const lat = '10.82302';
    const lon = '106.62965';
    const apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        forecastData = (data['list'] as List)
            .map((item) => WeatherData.fromJson(item))
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          final weather = forecastData[index];
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              // width: 70,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.09, -1.00),
                  end: Alignment(-0.09, 1),
                  colors: [Color(0xFF66E0D1), Color(0xFF579FF1)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                shadows: const [
                  BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 80,
                    offset: Offset(0, 10),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(children: [
                Text(
                  formatter.format(DateTime.parse(weather.dateTime)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formatterH.format(DateTime.parse(weather.dateTime)),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Image.network('https://openweathermap.org/img/wn/${weather.icon}@2x.png', scale: 2),
                Text(
                  '${weather.temperature} \u2103',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                )
              ]),
            ),
          );
        },
      ),
    );
  }
}

class WeatherData {
  final String dateTime;
  final double temperature;
  final double temperatureMin;
  final double temperatureMax;
  final String icon;
  WeatherData(
      {required this.dateTime,
      required this.temperature,
      required this.temperatureMin,
      required this.temperatureMax,
      required this.icon
      });

  factory WeatherData.fromJson(Map<String, dynamic> json) {

    return WeatherData(
      dateTime: json['dt_txt'],
      temperature: double.parse((json['main']['temp'])?.toString() ?? '0'),
      temperatureMax: double.parse((json['main']['temp_max'])?.toString() ?? '0'),
      temperatureMin: double.parse((json['main']['temp_min'])?.toString() ?? '0'),
      icon: json['weather'][0]['icon'] ?? '',
    );
  }
}
