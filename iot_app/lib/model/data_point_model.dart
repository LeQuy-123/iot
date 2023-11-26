class DataPoint {
  final double x;
  final double y;

  DataPoint({
    required this.x,
    required this.y,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}
