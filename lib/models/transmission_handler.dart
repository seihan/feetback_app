import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:feet_back_app/models/feedback_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';

class TransmissionHandler {
  final BluetoothDeviceModel inputDevice;
  final BluetoothDeviceModel outputDevice;
  final SensorStateModel sensorStateModel = SensorStateModel();

  final FeedbackModel feedbackModel = FeedbackModel();
  late final StreamSubscription? _sensorSubscription;

  TransmissionHandler({required this.inputDevice, required this.outputDevice});
  static const String _buzzOne = 'AT+MOTOR=11'; // 50ms vibration
  static const String _buzzThree = 'AT+MOTOR=13'; // 150ms vibration

  Timer? _writeTimer;
  bool _canWrite = true;
  bool _enableFeedback = false;
  bool get enableFeedback => _enableFeedback;
  set enableFeedback(bool value) {
    if (value == _enableFeedback) {
      return;
    }
    _enableFeedback = value;
  }

  void initialize() {
    if (inputDevice.name == 'CRM508-LEFT') {
      _sensorSubscription =
          sensorStateModel.leftDisplayStream.listen(_onNewValue);
    } else if (inputDevice.name == 'CRM508-RIGHT') {
      _sensorSubscription =
          sensorStateModel.rightDisplayStream.listen(_onNewValue);
    }
    _enableFeedback = feedbackModel.enableFeedback;
  }

  void _startWriteTimer(int highestValue) {
    if (_writeTimer != null && (_writeTimer?.isActive ?? false)) {
      _writeTimer?.cancel();
    }
    final int durationMilliseconds = _getTimerDuration(highestValue);
    _writeTimer = Timer(Duration(milliseconds: durationMilliseconds), () {
      _canWrite = true;
    });
  }

  int _getTimerDuration(int highestValue) {
    int durationMilliseconds = 2000;
    final double duration = feedbackModel.mapValueToRange(
      value: highestValue,
      inMin: 0,
      inMax: feedbackModel.threshold,
      outMin: feedbackModel.minDuration,
      outMax: feedbackModel.maxDuration,
    );
    durationMilliseconds = duration.toInt();
    return durationMilliseconds;
  }

  void _onNewValue(SensorValues sensorValues) {
    if (sensorValues.data.isNotEmpty &&
        sensorValues.data.length == 12 &&
        _enableFeedback) {
      final int highestFront = sensorValues.data.sublist(0, 5).min;
      final int highestRear = sensorValues.data.sublist(6).min;
      if (outputDevice.connected) {
        if ((highestFront > highestRear) &&
            _canWrite &&
            (highestRear < feedbackModel.threshold)) {
          outputDevice.rxTxChar?.write(
            utf8.encode(_buzzThree),
            withoutResponse: true,
          );
          _canWrite = false;
          _startWriteTimer(
              highestRear); // Start the timer after a write operation.
        } else if (_canWrite && (highestFront < feedbackModel.threshold)) {
          outputDevice.rxTxChar?.write(
            utf8.encode(_buzzOne),
            withoutResponse: true,
          );
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
