import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../widgets/bluetooth_alert_dialog.dart';
import 'bluetooth_device_model.dart';
import 'bluetooth_notification_handler.dart';
import 'custom_error_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  BluetoothConnectionModel({
    required this.navigatorKey,
  });

  static const String leftStartValue = '0x01 0x03 0x00 0x00 0xF1 0xD8';

  static const List<int> leftStartHexValues = [
    0x01,
    0x03,
    0x00,
    0x00,
    0xF1,
    0xD8
  ];
  static const List<int> leftStopHexValues = [
    0x01,
    0x06,
    0x00,
    0x00,
    0XE1,
    0XD9
  ];

  final Guid _serviceGuid = Guid('0000fe50-0000-1000-8000-00805f9b34fb');
  final Guid _rxTxCharGuid = Guid('0000fe51-0000-1000-8000-00805f9b34fb');

  // List of Bluetooth devices to manage
  late List<BluetoothDeviceModel> devices = [
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
  StreamSubscription? _notifyStreamSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription? _stateSubscription;
  BluetoothCharacteristic? _leftRxTxChar;
  BluetoothCharacteristic? _rightRxTxChar;

  bool _connected = false;
  bool _isNotifying = false;
  bool _isScanning = false;
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;
  bool get connected => _connected;
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  BluetoothAdapterState get state => _state;

  Stream<List<int>>? get notifyStream => _rightRxTxChar?.lastValueStream;
  Stream<String> get log => _logStream.stream;

  void initialize() {
    _errorSubscription = CustomErrorHandler.errorStream.listen(_onError);
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    _connectionSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => FlutterBluePlus.connectedSystemDevices)
        .listen(_listenConnections);
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
    for (var device in devices) {
      await device.device?.disconnect();
    }
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

  List<int> _convertHexToBytes(String hexValues) {
    List<String> hexValueStrings = hexValues.split(' ');
    List<int> bytes = hexValueStrings
        .map((hex) => int.parse(hex.substring(2), radix: 16))
        .toList();
    return bytes;
  }

  Future<void> _startLeftNotify() async {
    List<int> bytes = _convertHexToBytes(leftStartValue);
    try {
      await _leftRxTxChar?.write(leftStartHexValues, withoutResponse: false);

      debugPrint('Data sent successfully.');
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  Future<void> _stopLeftNotify() async {
    List<int> bytes = _convertHexToBytes(leftStartValue);
    await _leftRxTxChar?.write(leftStopHexValues);
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    if (!_isNotifying) {
      await _stopLeftNotify();
      _notifyStreamSubscription?.cancel();
    } else {
      await _startLeftNotify();
    }
    final BluetoothNotificationHandler notificationHandler =
        BluetoothNotificationHandler(
      rxChar: _rightRxTxChar,
      setNotify: _isNotifying,
    );
    notificationHandler.startNotifications()?.listen(_handleNotifyValues);
    _logStream.add('is notifying; ${notificationHandler.isNotifying}');
    debugPrint('is notifying; ${notificationHandler.isNotifying}');
    notifyListeners();
  }

  void _listenConnections(List<BluetoothDevice> event) {
    bool hasConnections = event.isNotEmpty;
    if (_connected != hasConnections) {
      _connected = hasConnections;
    }
  }

  void _handleDeviceState(BluetoothConnectionState? deviceState,
      BluetoothDeviceModel deviceModel) async {
    debugPrint('device state = ${deviceState.toString()}');
    _logStream.add('device state = ${deviceState.toString()}');
    if (deviceState != BluetoothConnectionState.connected) {
      debugPrint('disconnected');
      _logStream.add('disconnected');
      _connected = false;
      notifyListeners();
      try {
        debugPrint('connecting');
        _logStream.add('connecting');
        await deviceModel.device?.connect();
        _handleServices(
            await deviceModel.device?.discoverServices(), deviceModel);
      } on Exception catch (error, stacktrace) {
        CustomErrorHandler.handleFlutterError(error, stacktrace);
        debugPrint('Error: $error');
        _logStream.add('Error: $error');
      }
    } else if (deviceState == BluetoothConnectionState.connected) {
      deviceModel.connected = true;
      _connected = true;
      debugPrint('connected');
      _logStream.add('connected');
    }
    notifyListeners();
  }

  void _handleServices(
      List<BluetoothService>? services, BluetoothDeviceModel deviceModel) {
    if (services != null) {
      for (var service in services) {
        debugPrint('${service.uuid}');
        if (service.uuid == deviceModel.serviceGuid) {
          debugPrint('found service for ${deviceModel.name}');
          _logStream.add('found service for ${deviceModel.name}');
          deviceModel.service = service;
          _handleCharacteristics(deviceModel);
        }
      }
    }
  }

  void _handleCharacteristics(BluetoothDeviceModel deviceModel) {
    if (deviceModel.service != null &&
        deviceModel.service?.characteristics != null) {
      for (var element in deviceModel.service!.characteristics) {
        if (element.uuid == deviceModel.rxTxCharGuid) {
          debugPrint('found ${deviceModel.name} rx tx char');
          _logStream.add('found ${deviceModel.name}  rx tx char');
          deviceModel.rxTxChar = element;
        }
      }
    }
  }

  void _onScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      for (var result in results) {
        for (var device in devices) {
          debugPrint('device ${device.device}');
          if (result.device.platformName == device.name &&
              device.device == null) {
            device.device = result.device;
            debugPrint('found device: ${result.device.platformName}');
            _logStream.add('found device: ${result.device.platformName}');
            device.device?.connectionState.listen((state) {
              _handleDeviceState(state, device);
            });
            if (_deviceSubscriptions.length <= devices.length) {
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

  void _handleNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      debugPrint(values.toString());
      _logStream.add(values.toString());
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _notifyStreamSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _stateSubscription?.cancel();
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    super.dispose();
  }
}
