import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/material.dart';
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

  void addValue({required int value}) {
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
    const int degree = 2; // Degree of the polynomial (e.g., 2 for quadratic)
    final List<double> coefficients =
        _performPolynomialRegression(_calibrationTable, degree);

    // Sample value for which you want to find the corresponding x-coordinate
    const double targetSample = 200.0;
    const double initialGuess = 200.0; // Initial guess for Newton's method

    final double xFound = _findXFromSample(
      coefficients,
      targetSample,
      initialGuess,
    );

    debugPrint("Estimated x-coordinate for sample $targetSample: $xFound");
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

  List<double> _performPolynomialRegression(
      CalibrationTable calibrationTable, int degree) {
    assert(calibrationTable.values.length == calibrationTable.samples.length,
        "Data points must have the same length.");

    final int n = calibrationTable.values.length;
    final List<double> x = calibrationTable.values
        .map(
          (int value) => value.toDouble(),
        )
        .toList();
    final List<double> y = calibrationTable.samples;

    final List<double> coefficients = List<double>.filled(
      degree + 1,
      0,
    );

    for (int i = 0; i < n; i++) {
      double xPower = 1.0;
      double yValue = y[i];

      for (int j = 0; j <= degree; j++) {
        coefficients[j] += xPower * yValue;
        xPower *= x[i];
      }
    }

    for (int i = 0; i <= degree; i++) {
      for (int j = 0; j <= degree; j++) {
        double xPower = x[i] * x[i];
        coefficients[j] += xPower;
        xPower *= x[i];
      }
    }

    final List<List<double>> augmentedMatrix =
        List<List<double>>.generate(degree + 1, (int i) {
      return List<double>.generate(degree + 2, (int j) {
        if (j <= degree) {
          return pow(x[i], j).toDouble();
        } else {
          return coefficients[j - degree];
        }
      });
    });

    for (int i = 0; i <= degree; i++) {
      final double factor = augmentedMatrix[i][i];
      for (int j = i; j <= degree + 1; j++) {
        augmentedMatrix[i][j] /= factor;
      }
      for (int k = i + 1; k <= degree; k++) {
        final double factor = augmentedMatrix[k][i];
        for (int j = i; j <= degree + 1; j++) {
          augmentedMatrix[k][j] -= factor * augmentedMatrix[i][j];
        }
      }
    }

    for (int i = degree; i > 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        final double factor = augmentedMatrix[j][i];
        for (int k = i; k <= degree + 1; k++) {
          augmentedMatrix[j][k] -= factor * augmentedMatrix[i][k];
        }
      }
    }

    return augmentedMatrix
        .map(
          (List<double> row) => row[degree + 1],
        )
        .toList();
  }

  double _evaluatePolynomial(List<double> coefficients, double x) {
    double result = 0.0;
    for (int i = 0; i < coefficients.length; i++) {
      result += coefficients[i] * pow(x, i);
    }
    return result;
  }

  double _findXFromSample(
      List<double> coefficients, double targetSample, double initialGuess) {
    const int maxIterations = 100;
    const double tolerance = 1e-10;

    double x = initialGuess;

    for (int i = 0; i < maxIterations; i++) {
      final double f = _evaluatePolynomial(coefficients, x) - targetSample;
      final double fPrime = coefficients[0] +
          coefficients[1] +
          2 * coefficients[2] * x; // Derivative for a quadratic polynomial

      final double delta = f / fPrime;
      x -= delta;

      if (delta.abs() < tolerance) {
        return x;
      }
    }

    // Return an approximation if the root is not found within the iterations
    return x;
  }
}

/// A class representing a table of calibration data.
class CalibrationTable {
  final List<int> values; // List of x-values
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
      values: List<int>.from(map['values']),
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
