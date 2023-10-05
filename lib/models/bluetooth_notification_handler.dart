import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothNotificationHandler {
  final BluetoothCharacteristic? rxChar;
  final bool setNotify;

  BluetoothNotificationHandler({this.rxChar, this.setNotify = false});

  Stream<List<int>>? startNotifications() {
    rxChar?.setNotifyValue(setNotify);
    return rxChar?.lastValueStream;
  }

  bool get isNotifying => rxChar?.isNotifying ?? false;
}

class BluetoothWriteHandler {
  final BluetoothCharacteristic? characteristic;

  BluetoothWriteHandler({this.characteristic});
}
