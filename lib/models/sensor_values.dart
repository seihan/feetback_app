import 'dart:convert';

class SensorValues {
  late final DateTime time;
  final List<int> data;
  final String side;
  int? recordId;
  SensorValues({
    required this.time,
    required this.data,
    required this.side,
    this.recordId,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId ?? -1,
      'time': time.toIso8601String(), // Convert DateTime to a string.
      'data': json.encode(data), // Convert List<int> to a JSON string.
      'side': side,
    };
  }

  factory SensorValues.fromMap(Map<String, dynamic> map) {
    return SensorValues(
        time: DateTime.parse(map['time']),
        data: List<int>.from(
          json.decode(map['data']),
        ),
        side: map['side']);
  }
}
