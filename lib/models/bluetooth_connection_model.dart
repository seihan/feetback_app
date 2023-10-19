import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/transmission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../widgets/bluetooth_alert_dialog.dart';
import 'bluetooth_device_model.dart';
import 'bluetooth_notification_handler.dart';
import 'custom_error_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  final SensorStateModel sensorStateModel;

  BluetoothConnectionModel({
    required this.navigatorKey,
    required this.sensorStateModel,
  });

  /// Sensor config
  static final Uint8List _leftStart =
      Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0xF1, 0xD8]);
  static final Uint8List _leftStop =
      Uint8List.fromList([0x01, 0x06, 0x00, 0x00, 0xE1, 0xD9]);

  static final Uint8List _rightStart =
      Uint8List.fromList([0x02, 0x03, 0x00, 0x00, 0xF1, 0x9C]);
  static final Uint8List _rightStop =
      Uint8List.fromList([0x02, 0x06, 0x00, 0x00, 0xe1, 0x9d]);

  static final Guid _sensorServiceGuid =
      Guid('0000fe50-0000-1000-8000-00805f9b34fb');
  static final Guid _sensorRxTxCharGuid =
      Guid('0000fe51-0000-1000-8000-00805f9b34fb');

  /// Actor config
  static const DeviceIdentifier _actorLeftId =
      DeviceIdentifier('EA:3F:FA:39:89:E4');
  static const DeviceIdentifier _actorRightId =
      DeviceIdentifier('FC:77:F8:3E:B8:DA');

  static final Guid _actorServiceGuid =
      Guid('0000190b-0000-1000-8000-00805f9b34fb');
  static final Guid _actorRxTxCharGuid =
      Guid('00000003-0000-1000-8000-00805f9b34fb');

  static const String _motorOn = 'AT+MOTOR=1'; // start vibration
  static const String _buzzOne = 'AT+MOTOR=11'; // 50ms vibration
  static const String _buzzTwo = 'AT+MOTOR=12'; // 100ms vibration
  static const String _buzzThree = 'AT+MOTOR=13'; // 150ms vibration
  static const String _motorOff = 'AT+MOTOR=00'; // stop vibration
  static const String bat = 'AT+BATT0\n'; // get battery state %

  late final List<BluetoothDeviceModel> _devices = [
    BluetoothDeviceModel(
      name: 'CRM508-LEFT',
      serviceGuid: _sensorServiceGuid,
      rxTxCharGuid: _sensorRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      name: 'CRM508-RIGHT',
      serviceGuid: _sensorServiceGuid,
      rxTxCharGuid: _sensorRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      id: _actorLeftId,
      serviceGuid: _actorServiceGuid,
      rxTxCharGuid: _actorRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      id: _actorRightId,
      serviceGuid: _actorServiceGuid,
      rxTxCharGuid: _actorRxTxCharGuid,
    ),
  ];

  late final TransmissionHandler _leftHandler;
  late final TransmissionHandler _rightHandler;

  final StreamController<String> _logStream =
      StreamController<String>.broadcast();

  final List<StreamSubscription<BluetoothConnectionState>?>
      _deviceSubscriptions = [];
  StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  StreamSubscription<bool>? _scanSubscription;
  StreamSubscription<List<BluetoothDevice>>? _connectionSubscription;
  StreamSubscription<List<int>>? _leftNotifyStreamSubscription;
  StreamSubscription<List<int>>? _rightNotifyStreamSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription? _stateSubscription;
  BluetoothNotificationHandler? _leftNotificationHandler;
  BluetoothNotificationHandler? _rightNotificationHandler;

  bool _isNotifying = false;
  bool _isScanning = false;
  final List<bool> _activated = [false, false];
  final List<ScanResult> _processedResults = [];
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;
  bool get connected => _devices.every((device) => device.connected);
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  List<bool> get activated => _activated;
  List<BluetoothDeviceModel> get devices => _devices;

  Stream<String> get log => _logStream.stream;

  void initialize() {
    _errorSubscription = CustomErrorHandler.errorStream.listen(_onError);
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    if (_state == BluetoothAdapterState.on) {
      startScan();
    }
    _leftHandler =
        TransmissionHandler(inputDevice: _devices[0], outputDevice: _devices[2])
          ..initialize();
    _rightHandler =
        TransmissionHandler(inputDevice: _devices[1], outputDevice: _devices[3])
          ..initialize();
  }

  void _onError(String error) {
    if (error.isNotEmpty) {
      _logStream.add('${DateTime.now()} $error');
    }
  }

  void _listenBluetoothState(BluetoothAdapterState event) {
    _state = event;
    if (_state == BluetoothAdapterState.off &&
        navigatorKey.currentState != null) {
      showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (BuildContext context) {
          return const BluetoothAlertDialog();
        },
      );
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    for (var device in _devices) {
      await device.device?.disconnect();
      device.connected = false;
    }
    _deviceSubscriptions.clear();
    _leftNotifyStreamSubscription?.cancel();
    _rightNotifyStreamSubscription?.cancel();
    notifyListeners();
  }

  void startScan() {
    if (_isScanning) {
      return;
    }
    _processedResults.clear();
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    _deviceSubscriptions.clear();
    _scanResultSubscription = FlutterBluePlus.scanResults.listen(_onScanResult);
    _scanSubscription = FlutterBluePlus.isScanning.listen(_handleScanState);
    debugPrint('start scanning');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  void _handleScanState(bool event) {
    _isScanning = event;
    _logStream.add('is scanning = $event');
    notifyListeners();
  }

  Future<void> _startNotify({required int device}) async {
    try {
      await _devices[device].rxTxChar?.write(
          device == 0 ? _leftStart : _rightStart,
          withoutResponse: false);
      debugPrint('${device == 0 ? 'Left' : 'Right'} start sent successfully.');
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  Future<void> _stopNotify({required int device}) async {
    try {
      await _devices[device]
          .rxTxChar
          ?.write(device == 0 ? _leftStop : _rightStop, withoutResponse: false);
      debugPrint('${device == 0 ? 'Left' : 'Right'} stop sent successfully.');
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    if (_isNotifying) {
      if (_devices[0].connected) {
        _leftNotificationHandler =
            BluetoothNotificationHandler(rxChar: _devices[0].rxTxChar);
        await _startNotify(device: 0);
        _leftNotifyStreamSubscription = _leftNotificationHandler?.notifyValues
            ?.listen(_handleLeftNotifyValues);
        await _leftNotificationHandler?.setNotify(true);
      }
      if (_devices[1].connected) {
        _rightNotificationHandler =
            BluetoothNotificationHandler(rxChar: _devices[1].rxTxChar);
        await _startNotify(device: 1);
        _rightNotifyStreamSubscription = _rightNotificationHandler?.notifyValues
            ?.listen(_handleRightNotifyValues);
        await _rightNotificationHandler?.setNotify(true);
      }
    } else {
      if (_devices[0].connected) {
        _leftNotifyStreamSubscription?.cancel();
        await _stopNotify(device: 0);
        await _leftNotificationHandler?.setNotify(false);
      }
      if (_devices[1].connected) {
        _rightNotifyStreamSubscription?.cancel();
        await _stopNotify(device: 0);
        await _rightNotificationHandler?.setNotify(false);
      }
    }
    _logStream.add(
        'is notifying; ${_devices.every((device) => device.rxTxChar?.isNotifying ?? false)}');
    debugPrint(
        'is notifying; ${_devices.every((device) => device.rxTxChar?.isNotifying ?? false)}');
    notifyListeners();
  }

  void _handleLeftNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      sensorStateModel.updateLeft(values);
    }
  }

  void _handleRightNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      sensorStateModel.updateRight(values);
    }
  }

  void _handleDeviceState(BluetoothConnectionState? deviceState,
      BluetoothDeviceModel deviceModel) async {
    debugPrint('device state = ${deviceState.toString()}');
    _logStream.add('device state = ${deviceState.toString()}');
    if (deviceState != BluetoothConnectionState.connected) {
      debugPrint('disconnected');
      _logStream.add('disconnected');
      deviceModel.connected = false;
      notifyListeners();
      await _connect(deviceModel);
    } else if (deviceState == BluetoothConnectionState.connected) {
      debugPrint('connected');
      _logStream.add('connected');
      deviceModel.connected = true;
      notifyListeners();
      _handleServices(
          await deviceModel.device?.discoverServices(), deviceModel);
    }
  }

  Future<void> _connect(BluetoothDeviceModel deviceModel) async {
    try {
      debugPrint('connecting');
      _logStream.add('connecting');
      await deviceModel.device?.connect();
    } on Exception catch (error, stacktrace) {
      CustomErrorHandler.handleFlutterError(error, stacktrace);
      debugPrint('Error: $error');
      _logStream.add('Error: $error');
    }
  }

  void _handleServices(
      List<BluetoothService>? services, BluetoothDeviceModel deviceModel) {
    if (services != null) {
      deviceModel.service = services.firstWhereOrNull(
          (service) => service.uuid == deviceModel.serviceGuid);
      if (deviceModel.service != null) {
        debugPrint('found service for ${deviceModel.device?.platformName}');
        _logStream.add('found service for ${deviceModel.device?.platformName}');
        _handleCharacteristics(deviceModel);
      }
    }
  }

  void _handleCharacteristics(BluetoothDeviceModel deviceModel) async {
    deviceModel.rxTxChar = deviceModel.service?.characteristics
        .firstWhereOrNull((characteristic) =>
            characteristic.uuid == deviceModel.rxTxCharGuid);
    if (deviceModel.rxTxChar != null) {
      debugPrint('found ${deviceModel.device?.platformName} rx tx char');
      _logStream.add('found ${deviceModel.device?.platformName}  rx tx char');
    }
  }

  void _onScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      for (var result in results) {
        for (var device in _devices) {
          if ((result.device.platformName == device.name ||
                  result.device.remoteId == device.id) &&
              (device.device == null || device.device == result.device) &&
              !_processedResults.contains(result)) {
            debugPrint('found device: ${result.device.platformName}');
            _logStream.add('found device: ${result.device.platformName}');
            device.device = result.device;
            _processedResults.add(result);
            if (_deviceSubscriptions.length < _devices.length) {
              _deviceSubscriptions
                  .add(device.device?.connectionState.listen((state) {
                _handleDeviceState(state, device);
              }));
            } else {
              FlutterBluePlus.stopScan();
            }
          }
        }
      }
    }
  }

  void activate({required int device}) async {
    int selection = 0;
    switch (device) {
      case 2:
        selection = 0;
        break;
      case 3:
        selection = 1;
        break;
    }
    if (_devices[device].connected) {
      _activated[selection] = true;
      await _devices[device].rxTxChar?.write(utf8.encode(_motorOn));
      notifyListeners();
    }
  }

  void deactivate({required int device}) async {
    int selection = 0;
    switch (device) {
      case 2:
        selection = 0;
        break;
      case 3:
        selection = 1;
        break;
    }
    if (_devices[device].connected) {
      _activated[selection] = false;
      await _devices[device].rxTxChar?.write(utf8.encode(_motorOff));
      notifyListeners();
    }
  }

  void buzzOne({required int device}) async {
    if (_devices[device].connected) {
      await _devices[device].rxTxChar?.write(utf8.encode(_buzzOne));
    }
  }

  void buzzTwo({required int device}) async {
    if (_devices[device].connected) {
      await _devices[device].rxTxChar?.write(utf8.encode(_buzzTwo));
    }
  }

  void buzzThree({required int device}) async {
    if (_devices[device].connected) {
      await _devices[device].rxTxChar?.write(utf8.encode(_buzzThree));
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _leftNotifyStreamSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _stateSubscription?.cancel();
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    _leftHandler.dispose();
    _rightHandler.dispose();
    super.dispose();
  }
}
