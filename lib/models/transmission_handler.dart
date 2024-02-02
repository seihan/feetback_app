import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:feet_back_app/models/feedback_model.dart';
import 'package:feet_back_app/models/peripheral_constants.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';

class TransmissionHandler {
  final BluetoothDeviceModel outputDevice;
  final Side side;
  final SensorStateModel sensorStateModel = SensorStateModel();
  final FeedbackModel feedbackModel = FeedbackModel();
  final SensorDevice device = SensorDeviceSelector().selectedDevice;
  StreamSubscription? _sensorSubscription;

  TransmissionHandler({
    required this.outputDevice,
    required this.side,
  });
  static const int _factor = 1000;
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
    switch (side) {
      case Side.left:
        _sensorSubscription =
            sensorStateModel.leftValuesStream.listen(_onNewValue);
      case Side.right:
        _sensorSubscription =
            sensorStateModel.leftValuesStream.listen(_onNewValue);
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
      inMax: (feedbackModel.threshold * _factor).toInt(),
      outMin: feedbackModel.minDuration,
      outMax: feedbackModel.maxDuration,
    );
    durationMilliseconds = duration.toInt();
    return durationMilliseconds;
  }

  void _onNewValue(SensorValues values) {
    if ((values.normalized?.isNotEmpty ?? false) && _enableFeedback) {
      double highestFront = 0;
      double highestRear = 0;
      switch (device) {
        case SensorDevice.fsrtec:
          {
            highestFront = 1 - (values.normalized?.sublist(0, 5).min ?? 0);
            highestRear = 1 - (values.normalized?.sublist(6).min ?? 0);
            break;
          }
        case SensorDevice.salted:
          {
            highestFront = 1 - (values.normalized?[0] ?? 0);
            highestRear = 1 - (values.normalized?[1] ?? 0);
          }
      }

      if (outputDevice.connected) {
        bool frontExceedsThreshold = highestFront > feedbackModel.threshold;
        bool rearExceedsThreshold = highestRear > feedbackModel.threshold;
        if ((highestFront > highestRear) &&
            _canWrite &&
            frontExceedsThreshold) {
          outputDevice.rxTxChar?.write(
            utf8.encode(PeripheralConstants.buzzOne),
            withoutResponse: true,
          );
          _canWrite = false;
          _startWriteTimer((highestRear * _factor).toInt());
        } else if (_canWrite && rearExceedsThreshold) {
          outputDevice.rxTxChar?.write(
            utf8.encode(PeripheralConstants.buzzThree),
            withoutResponse: true,
          );
          _canWrite = false;
          _startWriteTimer((highestFront * _factor).toInt());
        }
      }
    }
  }

  void dispose() {
    _writeTimer?.cancel();
    _sensorSubscription?.cancel();
  }
}
