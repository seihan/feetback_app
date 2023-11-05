class RecordInfo {
  final DateTime startTime;
  final DateTime endTime;
  final int recordId;

  RecordInfo(
      {required this.startTime, required this.endTime, required this.recordId});

  factory RecordInfo.fromMap(Map<String, dynamic> map) {
    return RecordInfo(
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      recordId: map['recordId'] as int,
    );
  }
}
