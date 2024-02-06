import 'dart:async';

import 'package:feet_back_app/models/database_helper.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/cupertino.dart';

import '../services.dart';

class RecordModel extends ChangeNotifier {
  final _sensorStateModel = services.get<SensorStateModel>();
  final DatabaseHelper database = DatabaseHelper();
  StreamSubscription<SensorValues>? _leftSubscription;
  StreamSubscription<SensorValues>? _rightSubscription;
  bool _record = false;

  bool get record => _record;

  int _duration = 0;
  int get duration => _duration;

  DateTime _startTime = DateTime(1900);
  final List<SensorValues> _buffer = [];

  // Adjust the batch size according to your requirements.
  static const batchSize = 100;

  int recordId = -1;
  void startRecord() async {
    if (!_record) {
      // get last recordId
      recordId = await database.getNextRecordID();
      _startTime = DateTime.now();
      _leftSubscription = _sensorStateModel.leftValuesStream.listen(
        _onValue,
      );
      _rightSubscription = _sensorStateModel.rightValuesStream.listen(
        _onValue,
      );
    }
    _record = true;
    notifyListeners();
  }

  void stopRecord() {
    _leftSubscription?.cancel();
    _rightSubscription?.cancel();
    _record = false;
    _duration = 0;
    notifyListeners();
    _insertBufferedValues();
  }

  void _onValue(SensorValues values) {
    if (_record && values.data.isNotEmpty) {
      values.recordId = recordId;
      final Duration difference = DateTime.now().difference(_startTime);
      final int previousDuration = _duration;
      _duration = difference.inSeconds;
      _buffer.add(values);
      if (_buffer.length >= batchSize) {
        _insertBufferedValues();
      }
      if (_duration > previousDuration) {
        notifyListeners();
      }
    }
  }

  void _insertBufferedValues() async {
    if (_buffer.isNotEmpty) {
      await database.batchInsertSensorValues(_buffer);
      _buffer.clear();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _leftSubscription?.cancel();
    _rightSubscription?.cancel();
    _buffer.clear();
  }
}
