import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iot_app/model/location.dart';
import 'package:iot_app/model/sun_info.dart';
import 'package:iot_app/model/weather.dart';
import 'package:iot_app/widget/clock.dart';
import 'package:iot_app/widget/helper.dart';

class WeatherInfo extends StatefulWidget {
  final Location selectedLocation;
  const WeatherInfo({super.key, required this.selectedLocation});

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
  @override
  void didUpdateWidget(covariant WeatherInfo oldWidget) {
    if (oldWidget.selectedLocation != widget.selectedLocation) {
      // Trigger data fetching when the selected location changes
      weatherData = fetchWeatherData();
    }
    super.didUpdateWidget(oldWidget);
  }
  Future<FutureData> fetchWeatherData() async {
    final lat = widget.selectedLocation.lat;
    final lon = widget.selectedLocation.lon;
    final apiUrl = 'https://api.sunrisesunset.io/json?lat=$lat&lng=$lon';
    final weatherApi =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(apiUrl));
    final weatherResponse = await http.get(Uri.parse(weatherApi));
    if (response.statusCode == 200 && weatherResponse.statusCode == 200) {
      final data = json.decode(response.body);
      final dataWeather = json.decode(weatherResponse.body);
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
              final currentSun = snapshot.data?.sunInfo;
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
                          borderRadius: BorderRadius.circular(25),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.selectedLocation.name}, ${widget.selectedLocation.country}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const ClockWidget()
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
                  const SizedBox(height: 16),
                  Container(
                      width: MediaQuery.of(context).size.width - 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      
                      padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text('Wind',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Image.asset('assets/WindSmall.png', scale: 2.5),
                                  Text(
                                      '${currentWeather?.wind.speed.toString()} m/s',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Humidity',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Image.asset('assets/Drop.png', scale: 2.5),
                                  Text(
                                      '${currentWeather?.main.humidity.toString()}%',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Pressure',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Image.asset('assets/CloudRain.png', scale: 2.5),
                                  Text(
                                      '${currentWeather?.main.pressure.toString()} hPa',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text('Temp',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Image.asset('assets/Thermometer.png',
                                      scale: 2.7),
                                  Text(
                                      '${currentWeather?.main.temp.toString()} \u2103',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Sunrise',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Image.asset('assets/SunHorizon.png', scale: 2.5),
                                  Text(
                                      '${currentSun?.results.sunrise}',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Sunset',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Image.asset('assets/SunHorizon.png',
                                      scale: 2.5),
                                  Text(
                                      '${currentSun?.results.sunset}',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              );
            }
          },
        ),
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
