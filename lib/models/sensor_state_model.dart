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

  updateFsrtecValues(List<int> data, Side side) {
    // assumptions:
    // - package length is always multiple of 2 (List of uint16 big endian)
    // - full package has 28 bytes
    // - first value is identifier
    // - 12 sensor values are split on two packages
    // - last value is crc
    final ByteData buffer = ByteData.view(Uint8List.fromList(data).buffer);
    int identifier = buffer.getInt16(0);
    int crc = 0;
    final DateTime now = DateTime.now();
    switch (side) {
      case Side.left:
        {
          _startLeftTimer();
          switch (identifier) {
            case 0x0103:
              {
                _leftValues = SensorValues(
                  time: now,
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
                  time: now,
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

  updateSaltedValues(List<int> data, Side side) {
    final ByteData buffer = ByteData.sublistView(
      Uint8List.fromList(data),
    );
    final DateTime now = DateTime.now();
    final int numInt16Values = buffer.lengthInBytes ~/ 4;
    switch (side) {
      case Side.left:
        {
          _startLeftTimer();
          _leftValues = SensorValues(
            time: now,
            data: [],
            side: side.description.toUpperCase(),
          );
          for (int i = 2; i < numInt16Values - 1; i++) {
            _leftValues?.data.add(
              buffer.getInt32(i * 4, Endian.little),
            );
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
            time: now,
            data: [],
            side: side.description.toUpperCase(),
          );
          for (int i = 2; i < numInt16Values - 1; i++) {
            _rightValues?.data.add(
              buffer.getInt32(i * 4, Endian.little),
            );
          }
          _rightValues?.normalized = _deviceSelector.normalizeData(
            _rightValues!.data,
          );
          _rightValuesStream.add(_rightValues!);
          _rightCounter++;
        }
    }
  }
}
