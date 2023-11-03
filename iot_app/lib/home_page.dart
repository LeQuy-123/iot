// ignore_for_file: avoid_developer.log

import 'dart:convert';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_app/model/location.dart';
// import 'package:iot_app/widget/clock.dart';
// ignore: unused_import
import 'package:iot_app/widget/weather_forecast.dart';
import 'package:iot_app/widget/weather_info.dart';
import 'dart:developer' as developer;

Location initLocation = Location(
                          name: "Ho Chi Minh City",
                          lon: 106.62965,
                          lat: 10.82302,
                          country: "Vietnam");
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isOn = false;
  List<Location> locations = []; // List of Location objects
  Location? selectedLocation ;
  @override
  void initState() {
    loadJSON();
    super.initState();
  }
 
  Future<List<Location>?> loadJSON() async {
    try {
      // Get the file path (replace 'your_file.json' with the actual file path)
      final String response =
          await rootBundle.loadString('assets/cities_list.json');
      // Parse the JSON data
      final jsonList = List<Map<String, dynamic>>.from(json.decode(response));
      List<Location> s =
          jsonList.map((json) => Location.fromJson(json)).toList();
      setState(() {
        locations = s;
      });
      return s;
    } catch (e) {
      developer.log('e $e');
      return null;
    }
  }
 
  // Function to search for locations based on the input
  void searchLocations(String query) {
    // Perform the search logic here and update the 'locations' list
    setState(() {
      locations = locations.where((location) {
        final name = location.name.toLowerCase();
        final lowerQuery = query.toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                color: Colors.black26, fontWeight: FontWeight.w700)),
        actions: [
          if(locations.isNotEmpty) DropdownButton<Location>(
            value: selectedLocation,
            onChanged: (Location? newValue) {
              setState(() {
                selectedLocation = newValue;
              });
            },
            items:
                locations.map<DropdownMenuItem<Location>>((Location location) {
              return DropdownMenuItem<Location>(
                value: location,
                child: Text(location.name),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 66),
              WeatherInfo(
                  selectedLocation: selectedLocation ?? initLocation),
              // LineChartSample10(),
              WeatherForecast(
                  selectedLocation: selectedLocation ?? initLocation),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
