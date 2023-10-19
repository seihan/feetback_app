import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';

class TransmissionHandler {
  final String device;
  final BluetoothDeviceModel outputDevice;
  final SensorStateModel sensorStateModel = SensorStateModel();

  TransmissionHandler({required this.device, required this.outputDevice});
  static const String _buzzOne = 'AT+MOTOR=11'; // 50ms vibration

  //static const String _buzzTwo = 'AT+MOTOR=12'; // 100ms vibration
  static const String _buzzThree = 'AT+MOTOR=13'; // 150ms vibration

  Timer? _writeTimer;
  bool _canWrite = false;

  void initialize() {
    if (device == 'LEFT') {
      sensorStateModel.leftValuesStream.listen(_onNewValue);
    } else if (device == 'RIGHT') {
      sensorStateModel.rightValuesStream.listen(_onNewValue);
    }
    _writeTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      _timerCallback,
    );
  }

  void _timerCallback(Timer timer) {
    _canWrite = !_canWrite;
  }

  void _onNewValue(SensorValues sensorValues) {
    if (sensorValues.values.isNotEmpty && sensorValues.values.length == 12) {
      final int highestFront = sensorValues.values.sublist(0, 5).min;
      final int highestRear = sensorValues.values.sublist(6).min;
      if ((highestFront > highestRear) &&
          _canWrite &&
          outputDevice.connected &&
          (highestRear < 2000)) {
        // outputDevice.rxTxChar?.write(utf8.encode(_buzzThree));
      } else if (_canWrite && outputDevice.connected && (highestFront < 2000)) {
        // outputDevice.rxTxChar?.write(utf8.encode(_buzzOne));
      }
    }
  }

  void dispose() {
    _writeTimer?.cancel();
  }
}
