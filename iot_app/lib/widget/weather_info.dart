import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iot_app/model/sun_info.dart';
import 'package:iot_app/model/weather.dart';
import 'package:iot_app/provider/log_provider.dart';
import 'package:iot_app/widget/clock.dart';
import 'package:iot_app/widget/helper.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  WeatherInfoState createState() => WeatherInfoState();
}

final formatter = DateFormat('MM/dd');
final formatterH = DateFormat('HH:mm');

class WeatherInfoState extends State<WeatherInfo> {
  Future<FutureData>? weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = fetchWeatherData();
  }

  Future<FutureData> fetchWeatherData() async {
    const lat = '10.82302';
    const lon = '106.62965';
    const apiUrl = 'https://api.sunrisesunset.io/json?lat=$lat&lng=$lon';
    const weatherApi =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(apiUrl));
    final weatherResponse = await http.get(Uri.parse(weatherApi));
    if (response.statusCode == 200 && weatherResponse.statusCode == 200) {
      final data = json.decode(response.body);
      final dataWeather = json.decode(weatherResponse.body);
      Log.print('dataWeather = > ${dataWeather.toString()}');
      FutureData res = FutureData(
          weatherInfoToday: WeatherInfoToday.fromJson(dataWeather),
          sunInfo: SunInfo.fromJson(data));
      return res;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        FutureBuilder<FutureData>(
          future: weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final currentWeather = snapshot.data?.weatherInfoToday;
              return Column(
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Container(
                      width: size.width - 32,
                      height: 180,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(-0.42, -0.91),
                          end: Alignment(0.42, 0.91),
                          colors: [Color(0xFF67E1D2), Color(0xFF53A8FF)],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: -115,
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.network(
                                      'https://openweathermap.org/img/wn/${currentWeather?.weather[0].icon}@4x.png',
                                      scale: 0.7),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 75, right: 50),
                                    child: Text(
                                      '${currentWeather?.main.temp.floor().toString() ?? ''} \u2103',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 45,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ]),
                          ),
                          Positioned(
                            bottom: 20,
                            width: size.width - 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ho Chi Minh, Viet Nam',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    ClockWidget()
                                  ],
                                ),
                                Image.asset('assets/wind.png', scale: 4),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
        Container(
            width: MediaQuery.of(context).size.width - 32,
            height: 180,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Column(
              children: [Row()],
            )),
      ],
    );
  }
}

class FutureData {
  WeatherInfoToday weatherInfoToday;
  SunInfo sunInfo;
  FutureData({
    required this.weatherInfoToday,
    required this.sunInfo,
  });
}
