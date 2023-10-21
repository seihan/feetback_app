import 'dart:convert';

class SensorValues {
  final DateTime time;
  final List<int> data;
  final String side;
  SensorValues({required this.time, required this.data, required this.side});

  Map<String, dynamic> toMap() {
    return {
      'time': time.toIso8601String(), // Convert DateTime to a string.
      'data': json.encode(data), // Convert List<int> to a JSON string.
      'side': side,
    };
  }
}
