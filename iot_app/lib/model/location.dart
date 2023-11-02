import 'dart:convert';
import 'dart:io';

class Location {
  final String name;
  final double lon;
  final double lat;
  final String country;

  Location({
    required this.name,
    required this.lon,
    required this.lat,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      lon: (json['lon'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      country: json['country'] as String,
    );
  }
  Future<List<Map<String, dynamic>>?> loadJSON() async {
    try {
      // Get the file path (replace 'your_file.json' with the actual file path)
      final file = File('../../assets/cities_list.json');

      // Read the file
      final contents = await file.readAsString();

      // Parse the JSON data
      final jsonList = List<Map<String, dynamic>>.from(json.decode(contents));

      return jsonList;
    } catch (e) {
      return null;
    }
  }
}

