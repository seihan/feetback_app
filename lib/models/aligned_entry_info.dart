class AlignedEntryInfo {
  final DateTime startTime; // Start time of the aligned entries.
  final int length; // Length of the aligned entries in milliseconds.

  AlignedEntryInfo({
    required this.startTime,
    required this.length,
  });

  // Factory constructor to create an AlignedEntryInfo object from a map.
  factory AlignedEntryInfo.fromMap(Map<String, dynamic> map) {
    return AlignedEntryInfo(
      startTime: DateTime.parse(map['start_time']),
      length: (map['length'] as double).toInt(),
    );
  }
}
