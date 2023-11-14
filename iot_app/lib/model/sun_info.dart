class SunInfo {
  final Results results;
  final String status;

  SunInfo({
    required this.results,
    required this.status,
  });

  factory SunInfo.fromJson(Map<String, dynamic> json) {
    return SunInfo(
      results: Results.fromJson(json['results']),
      status: json['status'],
    );
  }
}

class Results {
  final String sunrise;
  final String sunset;
  final String firstLight;
  final String lastLight;
  final String dawn;
  final String dusk;
  final String solarNoon;
  final String goldenHour;
  final String dayLength;
  final String timezone;
  final int? utcOffset;

  Results({
    required this.sunrise,
    required this.sunset,
    required this.firstLight,
    required this.lastLight,
    required this.dawn,
    required this.dusk,
    required this.solarNoon,
    required this.goldenHour,
    required this.dayLength,
    required this.timezone,
     this.utcOffset,
  });

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      firstLight: json['first_light'],
      lastLight: json['last_light'],
      dawn: json['dawn'],
      dusk: json['dusk'],
      solarNoon: json['solar_noon'],
      goldenHour: json['golden_hour'],
      dayLength: json['day_length'],
      timezone: json['timezone'],
      utcOffset: json['utc_offset'] ?? 0,
    );
  }
}
