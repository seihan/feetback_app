import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/side.dart';
import '../services.dart';

class DeviceIdModel {
  String leftSensorId = '';
  String rightSensorId = '';
  final prefs = services.get<SharedPreferences>();
  final selectedDevice = services.get<SensorDeviceSelector>().selectedDevice;

  DeviceIdModel init() {
    loadSensorDeviceIds(selectedDevice);
    return this;
  }

  Future<void> loadSensorDeviceIds(SensorDevice device) async {
    final String leftId = '${device.description}leftId';
    final String rightId = '${device.description}rightId';
    leftSensorId = prefs.getString(leftId) ?? leftSensorId;
    rightSensorId = prefs.getString(rightId) ?? rightSensorId;
  }

  Future<void> saveSensorDeviceId({
    SensorDevice? device,
    String? id,
    required Side side,
  }) async {
    String identifier = '';
    switch (side) {
      case Side.left:
        {
          leftSensorId = id ?? leftSensorId;
          identifier = '${device?.description}leftId';
          await prefs.setString(identifier, leftSensorId);
        }
      case Side.right:
        {
          rightSensorId = id ?? rightSensorId;
          identifier = '${device?.description}rightId';
          await prefs.setString(identifier, rightSensorId);
        }
    }
  }
}
