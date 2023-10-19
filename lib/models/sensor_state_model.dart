import 'dart:async';
import 'dart:typed_data';

import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SensorStateModel {
  static final SensorStateModel _instance = SensorStateModel._internal();
  SensorStateModel._internal();
  factory SensorStateModel() {
    return _instance;
  }

  static final StreamController<SensorValues> _leftValuesStream =
      StreamController<SensorValues>.broadcast();
  static final StreamController<SensorValues> _rightValuesStream =
      StreamController<SensorValues>.broadcast();

  SensorValues _leftValues = SensorValues(
      time: DateTime(1900), values: List.generate(12, (index) => 0));
  SensorValues _rightValues = SensorValues(
      time: DateTime(1900), values: List.generate(12, (index) => 0));

  Stream<SensorValues> get leftValuesStream => _leftValuesStream.stream;
  Stream<SensorValues> get leftDisplayStream => leftValuesStream
      .throttleTime(const Duration(milliseconds: 33), trailing: true);
  Stream<SensorValues> get rightValuesStream => _rightValuesStream.stream;
  Stream<SensorValues> get rightDisplayStream => rightValuesStream
      .throttleTime(const Duration(milliseconds: 33), trailing: true);
  List<int> _combineUInt8Values(List<int> uInt8List) {
    List<int> result = [];
    int value = 0;
    bool combine = false;

    for (int i = 0; i < uInt8List.length; i++) {
      if (combine) {
        value = (value << 8) + uInt8List[i];
        result.add(value);
        value = 0;
        combine = false;
      } else {
        value = uInt8List[i];
        combine = true;
      }
    }

    return result;
  }

  /*
  double _getResistance(int value) {
    return (value / (4096 - value)) * 1000000;
  }
   */

  updateLeft(List<int> data) {
    final Uint8List uInt8List = Uint8List.fromList(data);
    int start = uInt8List.first;
    int crc = 0;

    final DateTime now = DateTime.now();
    switch (start) {
      case 0x01:
        {
          debugPrint('got left values');
          final List<int> intValues = _combineUInt8Values(
            uInt8List.sublist(2),
          );
          debugPrint('values length = ${intValues.length}');
          if (intValues.length > 12) {
            crc = intValues.last;
            intValues.removeLast();
          }
          final SensorValues sensorValues =
              SensorValues(time: now, values: intValues);
          _leftValues = sensorValues;
          break;
        }
      default:
        {
          debugPrint('got remaining left values');
          final List<int> intValues = _combineUInt8Values(uInt8List);
          final SensorValues sensorValues = _leftValues;
          crc = intValues.last;
          intValues.removeLast();
          if (_leftValues.values.length != 12) {
            debugPrint('values length = ${intValues.length}');
            sensorValues.values.addAll(intValues);
            _leftValues = sensorValues;
          }
        }
    }
    if (crc != 0 && _leftValues.values.length == 12) {
      _leftValuesStream.add(_leftValues);
    }
  }

  updateRight(List<int> data) {
    final Uint8List uInt8List = Uint8List.fromList(data);
    int start = uInt8List.first;
    int crc = 0;

    switch (start) {
      case 0x02:
        {
          debugPrint('got right values');
          final List<int> intValues = _combineUInt8Values(
            uInt8List.sublist(2),
          );
          SensorValues sensorValues =
              SensorValues(time: DateTime(1900), values: []);
          final DateTime now = DateTime.now();
          debugPrint('values length = ${intValues.length}');
          if (intValues.length > 12) {
            crc = intValues.last;
            intValues.removeLast();
          }
          sensorValues = SensorValues(time: now, values: intValues);
          _rightValues = sensorValues;
          break;
        }
      default:
        {
          debugPrint('got remaining right values');
          final List<int> intValues = _combineUInt8Values(uInt8List);
          final SensorValues sensorValues = _leftValues;
          crc = intValues.last;
          intValues.removeLast();
          if (_rightValues.values.length != 12) {
            debugPrint('values length = ${intValues.length}');
            sensorValues.values.addAll(intValues);
            _rightValues = sensorValues;
          }
        }
    }
    if (crc != 0 && _rightValues.values.length == 12) {
      _rightValuesStream.add(_rightValues);
    }
  }
}
