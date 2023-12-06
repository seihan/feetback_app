import 'dart:async';
import 'dart:convert';

import 'package:feet_back_app/models/peripheral_constants.dart';
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

  bool _canSaved = false;
  bool get canSaved => _canSaved;
  bool _canTested = false;
  bool get canTested => _canTested;

  bool canAdded = true;
  late final List<double> _xTestValues;
  List<double>? _predictedValues;

  List<double> get xTestValues => _xTestValues;
  List<double>? get predictedValues => _predictedValues;

  Future<void> initialize() async {
    _xTestValues = List.generate(
      4096,
      (int index) => index.toDouble(),
    );
    if (_calibrationTable.values.length != _calibrationTable.samples.length) {
      clearTable();
    }
    _calibrationTable = await _getCalibrationTable() ?? _calibrationTable;
    if (_calibrationTable.isValid()) {
      if (_calibrationTable.values.length > 4) {
        canAdded = false;
      }
      await getPredictedValues();
      if (_predictedValues?.isNotEmpty ?? false) {
        _canTested = false;
      }
    } else {
      _calibrationTable.values.addAll(PeripheralConstants.crmDefaultValues);
      _calibrationTable.samples.addAll(PeripheralConstants.crmDefaultSamples);
      predictValues();
    }
  }

  void clearTable() {
    _calibrationTable.samples.clear();
    _calibrationTable.values.clear();
    _xTestValues.clear();
    _predictedValues?.clear();
    canAdded = true;
  }

  void addValue({required double value}) {
    _calibrationTable.values.add(value);
    if (_calibrationTable.values.length > 2) {
      _canSaved = true;
    }
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

  Future<void> _savePredictedValues(List<double> values) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encodedList =
        values.map((double value) => value.toString()).toList();
    prefs.setStringList('predictedValues', encodedList);
  }

  Future<void> getPredictedValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList('predictedValues');
    _predictedValues = encodedList
            ?.map(
              (String value) => double.parse(value),
            )
            .toList() ??
        [];
  }

  Future<void> predictValues() async {
    final List<double> values = [];
    const int degree = 1;
    final Array xFineValues = Array(_calibrationTable.values);
    final Array xCoarseValues = Array([200, 130, 120, 85, 0]);
    final Array yFineValues = Array(_calibrationTable.samples);
    final Array yCoarseValues = Array([300, 1000, 2000, 3000, 4000]);
    final PolyFit pFine = PolyFit(xFineValues, yFineValues, degree);
    final PolyFit pCoarse = PolyFit(xCoarseValues, yCoarseValues, degree);
    debugPrint('PolyFit fine: ${pFine.toString()}');
    debugPrint('PolyFit coarse: ${pCoarse.toString()}');
    for (int i = 0; i < 200; i++) {
      // coarse measurement range
      double predictedValue = pCoarse.predict(_xTestValues[i]);
      debugPrint('predicted coarse value: $predictedValue');
      predictedValue < 0 ? predictedValue = 0 : predictedValue;
      values.add(predictedValue);
    }
    for (int i = 200; i < _xTestValues.length; i++) {
      double predictedValue = pFine.predict(_xTestValues[i]);
      debugPrint('predicted fine value: $predictedValue');
      predictedValue < 0 ? predictedValue = 0 : predictedValue;
      values.add(predictedValue);
    }
    _predictedValues = values;
    debugPrint('predicted length: ${_predictedValues?.length}');
    await _savePredictedValues(values);
    _canTested = false;
    _canSaved = false;
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
