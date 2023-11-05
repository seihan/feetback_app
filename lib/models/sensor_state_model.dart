import 'dart:async';
import 'dart:typed_data';

import 'package:feet_back_app/models/sensor_values.dart';
import 'package:rxdart/rxdart.dart';

class SensorStateModel {
  static final SensorStateModel _instance = SensorStateModel._internal();
  SensorStateModel._internal();
  factory SensorStateModel() {
    return _instance;
  }

  static final StreamController<SensorValues> _leftValuesStream =
      StreamController<SensorValues>.broadcast();
  static final StreamController<int> _leftFrequencyStream =
      StreamController<int>.broadcast();
  static final StreamController<SensorValues> _rightValuesStream =
      StreamController<SensorValues>.broadcast();
  static final StreamController<int> _rightFrequencyStream =
      StreamController<int>.broadcast();

  SensorValues? _leftValues;
  SensorValues? _rightValues;

  Stream<SensorValues> get leftValuesStream => _leftValuesStream.stream;
  Stream<SensorValues> get leftDisplayStream => leftValuesStream
      .throttleTime(const Duration(milliseconds: 33), trailing: true);
  Stream<int> get leftFrequency => _leftFrequencyStream.stream;
  Stream<SensorValues> get rightValuesStream => _rightValuesStream.stream;
  Stream<SensorValues> get rightDisplayStream => rightValuesStream
      .throttleTime(const Duration(milliseconds: 33), trailing: true);
  Stream<int> get rightFrequency => _rightFrequencyStream.stream;

  int _leftCounter = 0;
  int _rightCounter = 0;

  Timer? _leftTimer;
  Timer? _rightTimer;
  void _startLeftTimer() {
    _leftTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        _leftFrequencyStream.add(_leftCounter);
        _leftCounter = 0;
      },
    );
  }

  void _startRightTimer() {
    _rightTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        _rightFrequencyStream.add(_rightCounter);
        _rightCounter = 0;
      },
    );
  }

  /*
  double _getResistance(int value) {
    return (value / (4096 - value)) * 1000000;
  }
   */

  updateLeft(List<int> data) {
    // assumptions:
    // - package length is always multiple of 2 (List of uint16 big endian)
    // - full package has 28 bytes
    // - first value is identifier
    // - 12 sensor values
    // - last value is crc
    final ByteData buffer = ByteData.view(Uint8List.fromList(data).buffer);
    int identifier = buffer.getInt16(0);
    int crc = 0;
    _startLeftTimer();

    final DateTime now = DateTime.now();
    switch (identifier) {
      case 0x0103:
        {
          _leftValues = SensorValues(time: now, data: [], side: 'LEFT');
          for (int i = 1; i < buffer.lengthInBytes / 2; i++) {
            _leftValues?.data.add(buffer.getInt16((i * 2)));
          }

          if ((_leftValues?.data.length ?? 0) > 12) {
            crc = _leftValues?.data.last ?? 0;
            _leftValues?.data.removeLast();
          }
          break;
        }
      default:
        {
          if (_leftValues?.data.isNotEmpty ?? false) {
            for (int i = 0; i < buffer.lengthInBytes / 2; i++) {
              _leftValues?.data.add(buffer.getInt16((i * 2)));
            }

            if ((_leftValues?.data.length ?? 0) > 12) {
              crc = _leftValues?.data.last ?? 0;
              _leftValues?.data.removeLast();
            }
          }
        }
    }
    if (crc != 0 && _leftValues?.data.length == 12) {
      _leftValuesStream.add(_leftValues!);
      _leftCounter++;
    }
  }

  updateRight(List<int> data) {
    final ByteData buffer = ByteData.view(Uint8List.fromList(data).buffer);
    int identifier = buffer.getInt16(0);
    int crc = 0;
    _startRightTimer();

    final DateTime now = DateTime.now();
    switch (identifier) {
      case 0x0203:
        {
          _rightValues = SensorValues(time: now, data: [], side: 'RIGHT');
          for (int i = 1; i < buffer.lengthInBytes / 2; i++) {
            _rightValues?.data.add(buffer.getInt16((i * 2)));
          }

          if ((_rightValues?.data.length ?? 0) > 12) {
            crc = _rightValues?.data.last ?? 0;
            _rightValues?.data.removeLast();
          }
          break;
        }
      default:
        {
          if (_rightValues?.data.isNotEmpty ?? false) {
            for (int i = 0; i < buffer.lengthInBytes / 2; i++) {
              _rightValues?.data.add(buffer.getInt16((i * 2)));
            }

            if ((_rightValues?.data.length ?? 0) > 12) {
              crc = _rightValues?.data.last ?? 0;
              _rightValues?.data.removeLast();
            }
          }
        }
    }
    if (crc != 0 && _rightValues?.data.length == 12) {
      _rightValuesStream.add(_rightValues!);
      _rightCounter++;
    }
  }
}
