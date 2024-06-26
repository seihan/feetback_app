import 'dart:async';

class LogModel {
  static final LogModel _instance = LogModel._internal();
  LogModel._internal();

  factory LogModel() {
    return _instance;
  }

  final List<String> _log = [];
  Stream<List<String>> get log => Stream.fromIterable([_log]);
  void add(String event) {
    if (event.isNotEmpty) {
      final String now = DateTime.now().toIso8601String();
      _log.add('$now $event');
      if (_log.length == 1024) {
        _log.removeAt(0);
      }
    }
  }
}
