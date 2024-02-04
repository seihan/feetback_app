import 'dart:async';
import 'dart:typed_data';

import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:feet_back_app/services.dart';

import '../enums/side.dart';

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

  final SensorDeviceSelector _deviceSelector =
      services.get<SensorDeviceSelector>();

  SensorValues? _leftValues;
  SensorValues? _rightValues;

  Stream<SensorValues> get leftValuesStream => _leftValuesStream.stream;
  Stream<int> get leftFrequency => _leftFrequencyStream.stream;
  Stream<SensorValues> get rightValuesStream => _rightValuesStream.stream;
  Stream<int> get rightFrequency => _rightFrequencyStream.stream;

  int _leftCounter = 0;
  int _rightCounter = 0;

  Timer? _leftTimer;
  Timer? _rightTimer;
  updateFsrtecValues(List<int> data, Side side) {
    final buffer = ByteData.view(Uint8List.fromList(data).buffer);
    final time = DateTime.now();
    _parseFsrtecValues(buffer, time, side);
  }

  updateSaltedValues(List<int> data, Side side) {
    final buffer = ByteData.sublistView(Uint8List.fromList(data));
    final time = DateTime.now();
    _parseSaltedValues(buffer, time, side);
  }

  void _parseFsrtecValues(ByteData buffer, DateTime time, Side side) {
    // assumptions:
    // - package length is always multiple of 2 (List of uint16 big endian)
    // - full package has 28 bytes
    // - first value is identifier
    // - 12 sensor values are split on two packages
    // - last value is crc
    int identifier = buffer.getInt16(0);
    int crc = 0;
    switch (side) {
      case Side.left:
        {
          _startLeftTimer();
          switch (identifier) {
            case 0x0103:
              {
                _leftValues = SensorValues(
                  time: time,
                  data: [],
                  side: side.description.toUpperCase(),
                );
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
        }
        if (crc != 0 && _leftValues?.data.length == 12) {
          _leftValues?.normalized = _deviceSelector.normalizeData(
            _leftValues!.data,
          );
          _leftValuesStream.add(_leftValues!);
          _leftCounter++;
        }
      case Side.right:
        {
          _startRightTimer();
          switch (identifier) {
            case 0x0203:
              {
                _rightValues = SensorValues(
                  time: time,
                  data: [],
                  side: side.description.toUpperCase(),
                );
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
            _rightValues?.normalized = _deviceSelector.normalizeData(
              _rightValues!.data,
            );
            _rightValuesStream.add(_rightValues!);
            _rightCounter++;
          }
        }
    }
  }

  _parseSaltedValues(ByteData buffer, DateTime time, Side side) {
    switch (side) {
      case Side.left:
        {
          _startLeftTimer();
          _leftValues = SensorValues(
            time: time,
            data: [],
            side: side.description.toUpperCase(),
          );
          // experimentally found four 10bit sensor values at these offsets
          for (int i = 9; i < 17; i += 2) {
            if (i & 0x2 != 0) {
              // for every second sensor value ...
              _leftValues?.data.add(
                0x3ff - // ... subtract from max 10 bit
                    (buffer.getUint16(i, Endian.little) &
                        0x3ff), // mask low 10 bits
              );
            } else {
              _leftValues?.data.add(
                buffer.getUint16(i, Endian.little) & 0x03ff, // mask low 10 bits
              );
            }
          }
          _leftValues?.normalized = _deviceSelector.normalizeData(
            _leftValues!.data,
          );
          _leftValuesStream.add(_leftValues!);
          _leftCounter++;
        }

      case Side.right:
        {
          _startRightTimer();
          _rightValues = SensorValues(
            time: time,
            data: [],
            side: side.description.toUpperCase(),
          );

          // experimentally found four 10bit sensor values at these offsets
          for (int i = 9; i < 17; i += 2) {
            if (i & 0x2 != 0) {
              // for every second sensor value ...
              _rightValues?.data.add(
                0x3ff - // ... subtract from max 10 bit
                    (buffer.getUint16(i, Endian.little) &
                        0x3ff), // mask low 10 bits
              );
            } else {
              _rightValues?.data.add(
                buffer.getUint16(i, Endian.little) & 0x03ff, // mask low 10 bits
              );
            }
          }
          _rightValues?.normalized = _deviceSelector.normalizeData(
            _rightValues!.data,
          );
          _rightValuesStream.add(_rightValues!);
          _rightCounter++;
        }
    }
  }

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
}
