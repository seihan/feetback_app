import 'dart:convert';

class SensorValues {
  late final DateTime time;
  final List<int> data;
  List<double>? normalized;
  final String side;
  int? recordId;

  SensorValues({
    required this.time,
    required this.data,
    required this.side,
    this.normalized,
    this.recordId,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId ?? -1,
      'time': time.toIso8601String(),
      'data': json.encode(data),
      'side': side,
    };
  }

  factory SensorValues.fromMap(Map<String, dynamic> map) {
    return SensorValues(
      time: DateTime.parse(map['time']),
      data: List<int>.from(json.decode(map['data'])),
      side: map['side'],
    );
  }
}
