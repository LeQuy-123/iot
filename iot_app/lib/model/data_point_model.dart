
class DataPoint {
  final double x;
  final double y;

  DataPoint({
    required this.x,
    required this.y,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      x: json['x'] != null ? json['x'].toDouble() : json['timestamp'].toDouble(),
      y: json['y'] != null ? json['y'].toDouble() : json['prediction'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}
