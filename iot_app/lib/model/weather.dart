class Coord {
  double lon;
  double lat;

  Coord({required this.lon, required this.lat});

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lon: json['lon']?.toDouble() ?? 0.0,
      lat: json['lat']?.toDouble() ?? 0.0,
    );
  }
}

class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id']?.toInt() ?? 0,
      main: json['main'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class Main {
  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;
  int seaLevel;
  int grndLevel;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.seaLevel,
    required this.grndLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp']?.toDouble() ?? 0.0,
      feelsLike: json['feels_like']?.toDouble() ?? 0.0,
      tempMin: json['temp_min']?.toDouble() ?? 0.0,
      tempMax: json['temp_max']?.toDouble() ?? 0.0,
      pressure: json['pressure']?.toInt() ?? 0,
      humidity: json['humidity']?.toInt() ?? 0,
      seaLevel: json['sea_level']?.toInt() ?? 0,
      grndLevel: json['grnd_level']?.toInt() ?? 0,
    );
  }
}

class Wind {
  double speed;
  int deg;
  double gust;

  Wind({
    required this.speed,
    required this.deg,
    required this.gust,
  });

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: json['speed']?.toDouble() ?? 0.0,
      deg: json['deg']?.toInt() ?? 0,
      gust: json['gust']?.toDouble() ?? 0.0,
    );
  }
}

class Clouds {
  int all;

  Clouds({required this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(all: json['all']?.toInt() ?? 0);
  }
}

class Sys {
  String country;
  int sunrise;
  int sunset;

  Sys({required this.country, required this.sunrise, required this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      country: json['country'] ?? '',
      sunrise: json['sunrise']?.toInt() ?? 0,
      sunset: json['sunset']?.toInt() ?? 0,
    );
  }
}

class WeatherInfoToday {
  Coord coord;
  List<Weather> weather;
  String base;
  Main main;
  int visibility;
  Wind wind;
  Clouds clouds;
  int dt;
  Sys sys;
  int timezone;
  int id;
  String name;
  int cod;

  WeatherInfoToday({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  factory WeatherInfoToday.fromJson(Map<String, dynamic> json) {
    return WeatherInfoToday(
      coord: Coord.fromJson(json['coord'] ?? {}),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => Weather.fromJson(e))
          .toList(),
      base: json['base'] ?? '',
      main: Main.fromJson(json['main'] ?? {}),
      visibility: json['visibility']?.toInt() ?? 0,
      wind: Wind.fromJson(json['wind'] ?? {}),
      clouds: Clouds.fromJson(json['clouds'] ?? {}),
      dt: json['dt']?.toInt() ?? 0,
      sys: Sys.fromJson(json['sys'] ?? {}),
      timezone: json['timezone']?.toInt() ?? 0,
      id: json['id']?.toInt() ?? 0,
      name: json['name'] ?? '',
      cod: json['cod']?.toInt() ?? 0,
    );
  }
}
