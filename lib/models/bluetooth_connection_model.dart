import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
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

  static Uint8List leftStart =
      Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0xF1, 0xD8]);
  static Uint8List leftStop =
      Uint8List.fromList([0x01, 0x06, 0x00, 0x00, 0xE1, 0xD9]);

  static Uint8List rightStart =
      Uint8List.fromList([0x02, 0x03, 0x00, 0x00, 0xF1, 0x9C]);
  static Uint8List rightStop =
      Uint8List.fromList([0x02, 0x06, 0x00, 0x00, 0xe1, 0x9d]);

  final Guid _serviceGuid = Guid('0000fe50-0000-1000-8000-00805f9b34fb');
  final Guid _rxTxCharGuid = Guid('0000fe51-0000-1000-8000-00805f9b34fb');

  // List of Bluetooth devices to manage
  late final List<BluetoothDeviceModel> _devices = [
    BluetoothDeviceModel(
      name: 'CRM508-LEFT',
      serviceGuid: _serviceGuid,
      rxTxCharGuid: _rxTxCharGuid,
    ),
    BluetoothDeviceModel(
      name: 'CRM508-RIGHT',
      serviceGuid: _serviceGuid,
      rxTxCharGuid: _rxTxCharGuid,
    ),
  ];

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
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;
  bool get connected => _devices.every((device) => device.connected);
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  BluetoothAdapterState get state => _state;

  Stream<String> get log => _logStream.stream;

  void initialize() {
    _errorSubscription = CustomErrorHandler.errorStream.listen(_onError);
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    if (_state == BluetoothAdapterState.on) {
      startScan();
    }
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
    notifyListeners();
  }

  void startScan() {
    if (_isScanning) {
      return;
    }
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
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

  Future<void> _startLeftNotify() async {
    try {
      await _devices[0].rxTxChar?.write(leftStart, withoutResponse: false);
      debugPrint('Left start sent successfully.');
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  Future<void> _stopLeftNotify() async {
    try {
      await _devices[0].rxTxChar?.write(leftStop, withoutResponse: false);
      debugPrint('Left stop sent successfully.');
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  Future<void> _startRightNotify() async {
    try {
      await _devices[1].rxTxChar?.write(rightStart, withoutResponse: false);
      debugPrint('Right start sent successfully.');
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  Future<void> _stopRightNotify() async {
    try {
      await _devices[1].rxTxChar?.write(rightStop, withoutResponse: false);
      debugPrint('Right stop sent successfully.');
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
        await _startLeftNotify();
        _leftNotifyStreamSubscription = _leftNotificationHandler?.notifyValues
            ?.listen(_handleLeftNotifyValues);
        await _leftNotificationHandler?.setNotify(true);
      }
      if (_devices[1].connected) {
        _rightNotificationHandler =
            BluetoothNotificationHandler(rxChar: _devices[1].rxTxChar);
        await _startRightNotify();
        _rightNotifyStreamSubscription = _rightNotificationHandler?.notifyValues
            ?.listen(_handleRightNotifyValues);
        await _rightNotificationHandler?.setNotify(true);
      }
    } else {
      if (_devices[0].connected) {
        _leftNotifyStreamSubscription?.cancel();
        await _stopLeftNotify();
        await _leftNotificationHandler?.setNotify(false);
      }
      if (_devices[1].connected) {
        _rightNotifyStreamSubscription?.cancel();
        await _stopRightNotify();
        await _rightNotificationHandler?.setNotify(false);
      }
    }
    _logStream.add('is notifying; ${_devices[0].rxTxChar?.isNotifying}');
    debugPrint('is notifying; ${_devices[0].rxTxChar?.isNotifying}');
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
      try {
        debugPrint('connecting');
        _logStream.add('connecting');
        await deviceModel.device?.connect();
      } on Exception catch (error, stacktrace) {
        CustomErrorHandler.handleFlutterError(error, stacktrace);
        debugPrint('Error: $error');
        _logStream.add('Error: $error');
      }
    } else if (deviceState == BluetoothConnectionState.connected) {
      debugPrint('connected');
      _logStream.add('connected');
      _handleServices(
          await deviceModel.device?.discoverServices(), deviceModel);
      deviceModel.connected = true;
    }
    notifyListeners();
  }

  void _handleServices(
      List<BluetoothService>? services, BluetoothDeviceModel deviceModel) {
    if (services != null) {
      deviceModel.service =
          services.firstWhereOrNull((element) => element.uuid == _serviceGuid);
      if (deviceModel.service != null) {
        debugPrint('found service for ${deviceModel.name}');
        _logStream.add('found service for ${deviceModel.name}');
        _handleCharacteristics(deviceModel);
      }
    }
  }

  void _handleCharacteristics(BluetoothDeviceModel deviceModel) async {
    if (deviceModel.service != null &&
        deviceModel.service?.characteristics != null) {
      for (var characteristic in deviceModel.service!.characteristics) {
        if (characteristic.uuid == deviceModel.rxTxCharGuid) {
          debugPrint('found ${deviceModel.name} rx tx char');
          _logStream.add('found ${deviceModel.name}  rx tx char');
          deviceModel.rxTxChar = characteristic;
        }
      }
    }
  }

  void _onScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      List<ScanResult> processedResults = [];

      for (var device in _devices) {
        final result = results.firstWhereOrNull((result) =>
            result.device.platformName == device.name &&
            (device.device == null || device.device == result.device));

        if (result != null && !processedResults.contains(result)) {
          debugPrint('found device: ${result.device.platformName}');
          _logStream.add('found device: ${result.device.platformName}');
          device.device = result.device;
          processedResults.add(result);

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
    super.dispose();
  }
}
