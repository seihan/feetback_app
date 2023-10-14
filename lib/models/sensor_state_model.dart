import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class SensorStateModel extends ChangeNotifier {
  static final SensorStateModel _instance = SensorStateModel._internal();
  SensorStateModel._internal();
  factory SensorStateModel() {
    return _instance;
  }

  static final StreamController<List<int>> _leftValuesStream =
      StreamController<List<int>>.broadcast();
  static final StreamController<List<int>> _rightValuesStream =
      StreamController<List<int>>.broadcast();

  List<int> _leftValues = List.generate(12, (index) => 0);
  List<int> _rightValues = List.generate(12, (index) => 0);
  List<int> get leftValues =>
      _leftValues.length == 12 ? _leftValues : List.generate(12, (index) => 0);
  List<double> get leftResistance => _leftValues.map((item) {
        return _getResistance(item);
      }).toList();
  List<int> get rightValues => _rightValues.length == 12
      ? _rightValues
      : List.generate(12, (index) => 0);
  List<double> get rightResistance => _rightValues.map((item) {
        return _getResistance(item);
      }).toList();
  Stream<List<int>> get leftValuesStream => _leftValuesStream.stream;
  Stream<List<int>> get rightValuesStream => _rightValuesStream.stream;
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

  double _getResistance(int value) {
    return (value / (4096 - value)) * 1000000;
  }

  updateLeft(List<int> data) {
    var uInt8List = Uint8List.fromList(data);
    int start = uInt8List.first;
    int crc = 0;

    switch (start) {
      case 0x01:
        {
          debugPrint('got left values');
          final List<int> intValues = _combineUInt8Values(uInt8List.sublist(2));
          if (intValues.length > 12) {
            debugPrint('values length = ${intValues.length}');
            crc = intValues.last;
            intValues.removeLast();
          }
          _leftValues = intValues;
          break;
        }
      default:
        {
          debugPrint('got remaining left values');
          final List<int> intValues = _combineUInt8Values(uInt8List);
          crc = intValues.last;
          if (_leftValues.length != 12) {
            debugPrint('values length = ${intValues.length}');
            _leftValues.addAll(intValues.sublist(0, intValues.length - 1));
          }
        }
    }
    if (crc != 0 && _leftValues.length == 12) {
      _leftValuesStream.add(_leftValues);
      notifyListeners();
    }
  }

  updateRight(List<int> data) {
    var uInt8List = Uint8List.fromList(data);
    int start = uInt8List.first;
    int crc = 0;

    switch (start) {
      case 0x02:
        {
          debugPrint('got right values');
          final List<int> intValues = _combineUInt8Values(uInt8List.sublist(2));
          if (intValues.length > 12) {
            debugPrint('values length = ${intValues.length}');
            crc = intValues.last;
            intValues.removeLast();
          }
          _rightValues = intValues;
          break;
        }
      default:
        {
          debugPrint('got remaining right values');
          final List<int> intValues = _combineUInt8Values(uInt8List);
          crc = intValues.last;
          if (_rightValues.length != 12) {
            _rightValues.addAll(intValues.sublist(0, intValues.length - 1));
            debugPrint('values length = ${intValues.length}');
          }
        }
    }
    if (crc != 0 && _rightValues.length == 12) {
      _rightValuesStream.add(_rightValues);
      notifyListeners();
    }
  }
}
