import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';

class TransmissionHandler {
  final BluetoothDeviceModel inputDevice;
  final BluetoothDeviceModel outputDevice;
  final SensorStateModel sensorStateModel = SensorStateModel();
  late final StreamSubscription? _sensorSubscription;

  TransmissionHandler({required this.inputDevice, required this.outputDevice});
  static const String _buzzOne = 'AT+MOTOR=11'; // 50ms vibration
  static const String _buzzThree = 'AT+MOTOR=13'; // 150ms vibration

  Timer? _writeTimer;
  bool _canWrite = true;

  void initialize() {
    if (inputDevice.name == 'CRM508-LEFT') {
      _sensorSubscription =
          sensorStateModel.leftDisplayStream.listen(_onNewValue);
    } else if (inputDevice.name == 'CRM508-RIGHT') {
      _sensorSubscription =
          sensorStateModel.rightDisplayStream.listen(_onNewValue);
    }
  }

  void _startWriteTimer(int highestValue) {
    if (_writeTimer != null && _writeTimer!.isActive) {
      _writeTimer!.cancel();
    }
    int durationMilliseconds = 2000;
    if (highestValue <= 2000 && highestValue >= 1) {
      // Adjust the timer duration based on the highestValue.
      durationMilliseconds = ((highestValue - 1) / 1500 * 1500 + 1).round();
    }
    _writeTimer = Timer(Duration(milliseconds: durationMilliseconds), () {
      _canWrite = true;
    });
  }

  void _onNewValue(SensorValues sensorValues) {
    if (sensorValues.values.isNotEmpty && sensorValues.values.length == 12) {
      final int highestFront = sensorValues.values.sublist(0, 5).min;
      final int highestRear = sensorValues.values.sublist(6).min;
      if (outputDevice.connected) {
        if ((highestFront > highestRear) && _canWrite && (highestRear < 2000)) {
          outputDevice.rxTxChar
              ?.write(utf8.encode(_buzzThree), withoutResponse: true);
          _canWrite = false;
          _startWriteTimer(
              highestRear); // Start the timer after a write operation.
        } else if (_canWrite && (highestFront < 2000)) {
          outputDevice.rxTxChar
              ?.write(utf8.encode(_buzzOne), withoutResponse: true);
          _canWrite = false;
          _startWriteTimer(
              highestFront); // Start the timer after a write operation.
        }
      }
    }
  }

  void dispose() {
    _writeTimer?.cancel();
    _sensorSubscription?.cancel();
  }
}
