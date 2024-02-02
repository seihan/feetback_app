import 'package:feet_back_app/enums/actor_device.dart';
import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/side.dart';
import '../services.dart';

class DeviceIdModel {
  static final DeviceIdModel _instance = DeviceIdModel._internal();
  DeviceIdModel._internal();
  factory DeviceIdModel() {
    return _instance;
  }
  String leftActorIdStr = '';
  String rightActorIdStr = '';
  String leftSensorIdStr = '';
  String rightSensorIdStr = '';
  DeviceIdentifier? get leftActorId =>
      leftActorIdStr.isNotEmpty ? DeviceIdentifier(leftActorIdStr) : null;
  DeviceIdentifier? get rightActorId =>
      rightActorIdStr.isNotEmpty ? DeviceIdentifier(rightActorIdStr) : null;
  DeviceIdentifier? get leftSensorId =>
      leftSensorIdStr.isNotEmpty ? DeviceIdentifier(leftSensorIdStr) : null;
  DeviceIdentifier? get rightSensorId =>
      rightSensorIdStr.isNotEmpty ? DeviceIdentifier(rightSensorIdStr) : null;
  final prefs = services.get<SharedPreferences>();

  void initActorDevices(ActorDevice selectedDevice) {
    loadActorDeviceIds(selectedDevice);
  }

  void initSensorDevices(SensorDevice selectedDevice) {
    loadSensorDeviceIds(selectedDevice);
  }

  bool loadActorDeviceIds(ActorDevice? device) {
    bool success = false;
    final String leftIdentifier = '${device?.description}leftId';
    final String rightIdentifier = '${device?.description}rightId';
    final String? leftValue = prefs.getString(leftIdentifier);
    final String? rightValue = prefs.getString(rightIdentifier);
    leftActorIdStr = leftValue ?? '';
    rightActorIdStr = rightValue ?? '';
    if (leftValue != null && rightValue != null) {
      success = true;
    }
    return success;
  }

  bool loadSensorDeviceIds(SensorDevice? device) {
    bool success = false;
    final String leftIdentifier = '${device?.description}leftId';
    final String rightIdentifier = '${device?.description}rightId';
    final String? leftValue = prefs.getString(leftIdentifier);
    final String? rightValue = prefs.getString(rightIdentifier);
    leftSensorIdStr = leftValue ?? '';
    rightSensorIdStr = rightValue ?? '';
    if (leftValue != null && rightValue != null) {
      success = true;
    }
    return success;
  }

  Future<void> saveActorDeviceId({
    ActorDevice? device,
    String? id,
    required Side side,
  }) async {
    switch (side) {
      case Side.left:
        {
          leftActorIdStr = id ?? leftActorIdStr;
          final identifier = '${device?.description}leftId';
          await prefs.setString(identifier, leftActorIdStr);
        }
      case Side.right:
        {
          rightActorIdStr = id ?? rightActorIdStr;
          final identifier = '${device?.description}rightId';
          await prefs.setString(identifier, rightActorIdStr);
        }
    }
  }

  Future<void> deleteActorIds({ActorDevice? device}) async {
    final leftIdentifier = '${device?.description}leftId';
    final rightIdentifier = '${device?.description}rightId';
    await prefs.remove(leftIdentifier);
    await prefs.remove(rightIdentifier);
    leftActorIdStr = rightActorIdStr = '';
  }

  Future<void> saveSensorDeviceId({
    SensorDevice? device,
    String? id,
    required Side side,
  }) async {
    switch (side) {
      case Side.left:
        {
          leftSensorIdStr = id ?? leftSensorIdStr;
          final identifier = '${device?.description}leftId';
          await prefs.setString(identifier, leftSensorIdStr);
        }
      case Side.right:
        {
          rightSensorIdStr = id ?? rightSensorIdStr;
          final identifier = '${device?.description}rightId';
          await prefs.setString(identifier, rightSensorIdStr);
        }
    }
  }

  Future<void> deleteSensorIds({SensorDevice? device}) async {
    final leftIdentifier = '${device?.description}leftId';
    final rightIdentifier = '${device?.description}rightId';
    await prefs.remove(leftIdentifier);
    await prefs.remove(rightIdentifier);
    leftSensorIdStr = rightSensorIdStr = '';
  }
}
