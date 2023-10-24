import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/material.dart';

class CalibrationModel extends ChangeNotifier {
  final Stream<SensorValues> stream = SensorStateModel().leftValuesStream;

  static const int sampleRate = 10;

  StreamSubscription? _subscription;
  List<int> _samples = [];
  double _sample = 0;
  int _value = 0;
  int get value => _value;

  final CalibrationTable _calibrationTable = CalibrationTable(
    values: [],
    samples: [],
  );

  CalibrationTable get calibrationTable => _calibrationTable;

  void addSample() {
    _calibrationTable.values.add(_value);
    _subscription = stream.listen((_onValue));
  }

  void _onValue(SensorValues values) {
    _samples.add(values.data.min);
    if (_samples.length == sampleRate) {
      _sample = (_samples.sum / sampleRate);
      _calibrationTable.samples.add(_sample);
      _samples = [];
      notifyListeners();
      _subscription?.cancel();
    }
  }

  void clearTable() {
    _calibrationTable.samples.clear();
    _calibrationTable.values.clear();
  }

  void increaseValue() {
    _value += 10;
    notifyListeners();
  }

  void decreaseValue() {
    if (_value >= 10) {
      _value -= 10;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class CalibrationTable {
  final List<int> values;
  final List<double> samples;

  CalibrationTable({required this.values, required this.samples});
}
