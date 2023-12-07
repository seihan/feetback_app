import 'package:feet_back_app/models/peripheral_constants.dart';

import 'bluetooth_device_model.dart';

enum SensorDevice { fsrtec, salted }

class SensorDeviceSelector {
  static final SensorDeviceSelector _instance =
      SensorDeviceSelector._internal();
  SensorDeviceSelector._internal();
  factory SensorDeviceSelector() {
    return _instance;
  }

  SensorDevice? _selectedDevice;
  SensorDevice? get selectedDevice => _selectedDevice;
  List<BluetoothDeviceModel> selectedDevices = [];

  void selectDevices(SensorDevice selectedDevice) {
    _selectedDevice = selectedDevice;
    selectedDevices.clear();
    switch (selectedDevice) {
      case SensorDevice.fsrtec:
        selectedDevices.addAll(fsrtecDevices);
        break;
      case SensorDevice.salted:
        selectedDevices.addAll(saltedDevices);
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

  static final List<BluetoothDeviceModel> fsrtecDevices = [
    BluetoothDeviceModel(
      name: PeripheralConstants.crmLeftName,
      serviceGuid: PeripheralConstants.crmServiceGuid,
      rxTxCharGuid: PeripheralConstants.crmRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      name: PeripheralConstants.crmRightName,
      serviceGuid: PeripheralConstants.crmServiceGuid,
      rxTxCharGuid: PeripheralConstants.crmRxTxCharGuid,
    ),
  ];

  static final List<BluetoothDeviceModel> saltedDevices = [
    BluetoothDeviceModel(
      name: PeripheralConstants.saltedLeftName,
      serviceGuid: PeripheralConstants.saltedServiceGuid,
      txCharGuid: PeripheralConstants.saltedTxCharGuid,
      rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      name: PeripheralConstants.saltedRightName,
      serviceGuid: PeripheralConstants.saltedServiceGuid,
      txCharGuid: PeripheralConstants.saltedTxCharGuid,
      rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
    ),
  ];
}
