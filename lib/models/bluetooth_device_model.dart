import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceModel {
  final String name;
  final Guid serviceGuid;
  final Guid rxTxCharGuid;

  BluetoothDeviceModel({
    required this.name,
    required this.serviceGuid,
    required this.rxTxCharGuid,
  });

  BluetoothDevice? device;
  BluetoothService? service;
  BluetoothCharacteristic? rxTxChar;
  bool connected = false;
}
