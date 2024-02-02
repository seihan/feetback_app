import 'package:feet_back_app/models/device_id_model.dart';
import 'package:feet_back_app/models/peripheral_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../services.dart';
import 'bluetooth_device_model.dart';

class SensorDeviceSelector {
  static final SensorDeviceSelector _instance =
      SensorDeviceSelector._internal();
  SensorDeviceSelector._internal();
  final DeviceIdModel _deviceIdModel = services.get<DeviceIdModel>();
  factory SensorDeviceSelector() {
    return _instance;
  }
  SensorDevice _selectedDevice = SensorDevice.salted;
  SensorDevice get selectedDevice => _selectedDevice;
  List<BluetoothDeviceModel> selectedDevices = [];
  late List<BluetoothDeviceModel> fsrtecDevices;
  late List<BluetoothDeviceModel> saltedDevices;

  void init() {
    _deviceIdModel.init(selectedDevice);
    _initializeDevices();
  }

  void selectDevice(SensorDevice? selectedDevice) {
    _selectedDevice = selectedDevice ?? _selectedDevice;
    selectedDevices.clear();
    _initializeDevices();
    switch (_selectedDevice) {
      case SensorDevice.salted:
        selectedDevices.addAll(saltedDevices);
        break;
      case SensorDevice.fsrtec:
        selectedDevices.addAll(fsrtecDevices);
        break;
    }
  }

  List<BluetoothDeviceModel> getSelectedDevices() {
    selectedDevices.isEmpty
        ? _selectedDevice = SensorDevice.salted
        : _selectedDevice;
    return selectedDevices.isNotEmpty ? selectedDevices : getDefaultDevices();
  }

  List<BluetoothDeviceModel> getDefaultDevices() {
    return saltedDevices;
  }

  List<double> getPositionList(int index, Side side) {
    List<double> position = getPositionMap(side)[index] ?? [];
    return position;
  }

  Map<int, List<double>> getPositionMap(Side side) {
    final Map<int, List<double>> fsrtecSensorPositions = {
      0: [side == Side.left ? 40 : 45, side == Side.left ? 40 : 30],
      1: [side == Side.left ? 80 : 85, side == Side.left ? 35 : 35],
      2: [side == Side.left ? 25 : 30, side == Side.left ? 110 : 100],
      3: [side == Side.left ? 95 : 100, side == Side.left ? 100 : 105],
      4: [35, side == Side.left ? 180 : 170],
      5: [90, side == Side.left ? 170 : 180],
      6: [side == Side.left ? 55 : 40, 250],
      7: [side == Side.left ? 85 : 70, 250],
      8: [side == Side.left ? 75 : 25, 320],
      9: [side == Side.left ? 100 : 50, 320],
      10: [side == Side.left ? 85 : 15, 380],
      11: [side == Side.left ? 110 : 40, 380],
    };

    final Map<int, List<double>> saltedSensorPositions = {
      0: [side == Side.left ? 60 : 65, side == Side.left ? 60 : 60],
      1: [side == Side.left ? 90 : 30, side == Side.left ? 360 : 360],
      2: [side == Side.left ? 25 : 30, side == Side.left ? 150 : 140],
      3: [side == Side.left ? 95 : 100, side == Side.left ? 140 : 150],
    };

    switch (_selectedDevice) {
      case SensorDevice.fsrtec:
        return fsrtecSensorPositions;
      case SensorDevice.salted:
        return saltedSensorPositions;
      default:
        return {};
    }
  }

  List<double> normalizeData(List<int> data) {
    const int min32 = -2147483648;
    const int max32 = 2147483647;

    switch (_selectedDevice) {
      case SensorDevice.fsrtec:
        return _normalizeInt16(data);
      case SensorDevice.salted:
        return _normalizeInt32(data, min32, max32);
      default:
        return [];
    }
  }

// Helper function to normalize int16 values
  List<double> _normalizeInt16(List<int> data) {
    return data.map((value) => value / 4095).toList();
  }

// Helper function to normalize int32 values
  List<double> _normalizeInt32(List<int> data, int min, int max) {
    return data.map((value) {
      if (value >= min && value <= max) {
        return (value - min) / (max - min);
      } else if (value < min) {
        return 0.0; // Normalize to the minimum value if below the range
      } else {
        return 1.0; // Normalize to the maximum value if above the range
      }
    }).toList();
  }

  DeviceIdentifier? _getIdBySide({required Side side}) {
    switch (side) {
      case Side.left:
        return _deviceIdModel.leftSensorId;
      case Side.right:
        return _deviceIdModel.rightSensorId;
    }
  }

  void _initializeDevices() {
    fsrtecDevices = [
      BluetoothDeviceModel(
        name: PeripheralConstants.fsrtecLeftName,
        id: _getIdBySide(side: Side.left),
        serviceGuid: PeripheralConstants.fsrtecServiceGuid,
        rxTxCharGuid: PeripheralConstants.fsrtecRxTxCharGuid,
        side: Side.left,
      ),
      BluetoothDeviceModel(
        name: PeripheralConstants.fsrtecRightName,
        id: _getIdBySide(side: Side.right),
        serviceGuid: PeripheralConstants.fsrtecServiceGuid,
        rxTxCharGuid: PeripheralConstants.fsrtecRxTxCharGuid,
        side: Side.right,
      ),
    ];
    saltedDevices = [
      BluetoothDeviceModel(
        name: PeripheralConstants.saltedLeftName,
        id: _getIdBySide(side: Side.left),
        serviceGuid: PeripheralConstants.saltedServiceGuid,
        txCharGuid: PeripheralConstants.saltedTxCharGuid,
        rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
        side: Side.left,
      ),
      BluetoothDeviceModel(
        name: PeripheralConstants.saltedRightName,
        id: _getIdBySide(side: Side.right),
        serviceGuid: PeripheralConstants.saltedServiceGuid,
        txCharGuid: PeripheralConstants.saltedTxCharGuid,
        rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
        side: Side.right,
      ),
    ];
  }
}
