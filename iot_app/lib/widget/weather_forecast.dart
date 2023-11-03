import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iot_app/model/location.dart';
import 'package:iot_app/widget/helper.dart';

class WeatherForecast extends StatefulWidget {
  final Location selectedLocation;
    const WeatherForecast({super.key, required this.selectedLocation});
 

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
  @override
  void didUpdateWidget(covariant WeatherForecast oldWidget) {
    if (oldWidget.selectedLocation != widget.selectedLocation) {
      // Trigger data fetching when the selected location changes
      fetchWeatherData();
    }
    super.didUpdateWidget(oldWidget);
  }
  Future<void> fetchWeatherData() async {
    final lat = widget.selectedLocation.lat;
    final lon =  widget.selectedLocation.lon;
    final apiUrl =
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
      height: 196,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          final weather = forecastData[index];
          return Container(
            // width: 70,
            margin:  const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
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
                  offset: const Offset(0, 1), // changes position of shadow
                ),
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
