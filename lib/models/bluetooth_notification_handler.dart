import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothNotificationHandler {
  final BluetoothCharacteristic? rxChar;

  BluetoothNotificationHandler({this.rxChar});

  Future<void> setNotify(bool setNotify) async {
    await rxChar?.setNotifyValue(setNotify);
  }

  Stream<List<int>>? get notifyValues => rxChar?.lastValueStream;
  bool get isNotifying => rxChar?.isNotifying ?? false;
}
