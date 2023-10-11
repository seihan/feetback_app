import 'dart:typed_data';

import 'package:flutter/material.dart';

class SensorStateModel extends ChangeNotifier {
  static final SensorStateModel _instance = SensorStateModel._internal();
  SensorStateModel._internal();

  factory SensorStateModel() {
    return _instance;
  }

  List<int> _leftValues = List.generate(12, (index) => 0);
  List<int> _rightValues = List.generate(12, (index) => 0);
  List<int> get leftValues => _leftValues;
  List<int> get rightValues => _rightValues;

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

  updateLeft(List<int> data) {
    var uInt8List = Uint8List.fromList(data);
    int start = uInt8List.first;
    int crc = 0;
    debugPrint('start: $start');

    switch (start) {
      case 0x01:
        {
          debugPrint('got left values');
          final List<int> intValues = _combineUInt8Values(uInt8List.sublist(2));
          _leftValues = intValues;
          break;
        }
      default:
        {
          debugPrint('got remaining left values');
          final List<int> intValues = _combineUInt8Values(uInt8List);
          crc = intValues.last;
          debugPrint('length = ${_leftValues.length}');
          if (_leftValues.length == 9) {
            _leftValues.addAll(intValues.sublist(0, intValues.length - 1));
          }
        }
    }
    debugPrint('crc = $crc');
    debugPrint('all values = $_leftValues');
    notifyListeners();
  }

  updateRight(List<int> data) {
    var uInt8List = Uint8List.fromList(data);
    int start = uInt8List.first;
    int crc = 0;
    debugPrint('start: $start');

    switch (start) {
      case 0x02:
        {
          debugPrint('got right values');
          final List<int> intValues = _combineUInt8Values(uInt8List.sublist(2));
          _rightValues = intValues;
          break;
        }
      default:
        {
          debugPrint('got remaining right values');
          final List<int> intValues = _combineUInt8Values(uInt8List);
          crc = intValues.last;
          if (_rightValues.length == 9) {
            _rightValues.addAll(intValues.sublist(0, intValues.length - 1));
          }
        }
    }
    debugPrint('crc = $crc');
    debugPrint('all values = $_leftValues');
    notifyListeners();
  }
}
