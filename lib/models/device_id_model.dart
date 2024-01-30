import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdModel {
  static final DeviceIdModel _instance = DeviceIdModel._internal();
  DeviceIdModel._internal();
  factory DeviceIdModel() {
    return _instance;
  }
  String leftSensorId = '';
  String rightSensorId = '';

  Future<void> loadSensorDeviceIds(SensorDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String leftId = '${device.description}leftId';
    final String rightId = '${device.description}rightId';
    leftSensorId = prefs.getString(leftId) ?? leftSensorId;
    rightSensorId = prefs.getString(rightId) ?? rightSensorId;
  }

  Future<void> saveSensorDeviceIds(SensorDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String leftId = '${device.description}leftId';
    final String rightId = '${device.description}rightId';
    await prefs.setString(leftId, leftSensorId);
    await prefs.setString(rightId, rightSensorId);
  }
}
