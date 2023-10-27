import 'dart:async';
import 'dart:convert';

import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/material.dart';
import 'package:scidart/numdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationModel {
  static final CalibrationModel _instance = CalibrationModel._internal();
  CalibrationModel._internal();
  factory CalibrationModel() {
    return _instance;
  }

  final Stream<SensorValues> stream = SensorStateModel().leftValuesStream;

  CalibrationTable _calibrationTable = CalibrationTable(
    values: [],
    samples: [],
  );

  CalibrationTable get calibrationTable => _calibrationTable;

  bool _canTested = false;
  bool get canTested => _canTested;

  List<double>? _xTestValues;
  List<double>? _yTestValues;

  List<double>? get xTestValues => _xTestValues;
  List<double>? get yTestValues => _yTestValues;

  Future<void> initialize() async {
    if (_calibrationTable.values.length != _calibrationTable.samples.length) {
      clearTable();
    }
    _calibrationTable = await _getCalibrationTable() ?? _calibrationTable;
    if (_calibrationTable.isValid()) {
      _canTested = true;
    }
  }

  void clearTable() {
    _calibrationTable.samples.clear();
    _calibrationTable.values.clear();
  }

  void addValue({required double value}) {
    _calibrationTable.values.add(value);
  }

  void addSample({required double value}) {
    _calibrationTable.samples.add(value);
  }

  Future<void> saveCalibrationTable() async {
    if (_calibrationTable.isValid()) {
      _canTested = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> calibrationData = _calibrationTable.toMap();
      await prefs.setString(
        'calibrationData',
        json.encode(calibrationData),
      );
    }
  }

  void test() {
    final List<double> samples = List.generate(
      4096,
      (index) => index.toDouble(),
    );
    final List<double> values = [];
    const int degree = 2;
    final Array xValues = Array(_calibrationTable.values);
    final Array yValues = Array(_calibrationTable.samples);
    final PolyFit p = PolyFit(xValues, yValues, degree);
    debugPrint('PolyFit: ${p.toString()}');
    for (int i = 0; i < samples.length; i++) {
      values.add(p.predict(samples[i]));
    }
    _xTestValues = samples;
    _yTestValues = values;
  }

  Future<CalibrationTable?> _getCalibrationTable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('calibrationData');
    if (jsonString != null) {
      final dynamic calibrationData = json.decode(jsonString);
      return CalibrationTable.fromMap(calibrationData);
    }
    return null; // Return null if data is not found
  }
}

/// A class representing a table of calibration data.
class CalibrationTable {
  final List<double> values; // List of x-values
  final List<double> samples; // List of corresponding y-values

  /// Creates a [CalibrationTable] with the provided data.
  CalibrationTable({required this.values, required this.samples});

  Map<String, dynamic> toMap() {
    return {
      'values': values,
      'samples': samples,
    };
  }

  factory CalibrationTable.fromMap(Map<String, dynamic> map) {
    return CalibrationTable(
      values: List<double>.from(map['values']),
      samples: List<double>.from(map['samples']),
    );
  }
  bool isValid() {
    bool valid = false;
    if (values.isNotEmpty &&
        samples.isNotEmpty &&
        (values.length == samples.length)) {
      valid = true;
    }
    return valid;
  }
}
