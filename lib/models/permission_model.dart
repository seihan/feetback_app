import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../routes.dart';

// This enum will manage the overall state of the app
enum PermissionSection {
  noLocationPermission, // Permission denied, but not forever
  noLocationPermissionPermanent, // Permission denied forever
  permissionGranted, // Permission granted
  unknown, // Permission unknown
}

class PermissionModel extends ChangeNotifier {
  PermissionSection _permissionSection = PermissionSection.unknown;

  PermissionSection get permissionSection => _permissionSection;

  set permissionSection(PermissionSection value) {
    if (value != _permissionSection) {
      _permissionSection = value;
      notifyListeners();
    }
  }

  Future<PermissionModel> init() async {
    await requestLocationPermission();
    return this;
  }

  String guessInitialRoute() {
    switch (_permissionSection) {
      case PermissionSection.unknown:
        return Routes.permissions;
      case PermissionSection.noLocationPermission:
        return Routes.permissions;
      case PermissionSection.noLocationPermissionPermanent:
        return Routes.permissions;
      case PermissionSection.permissionGranted:
        return Routes.home;
    }
  }

  /// Request the location permission and updates the UI accordingly
  Future<PermissionSection> requestLocationPermission() async {
    PermissionStatus result;
    result = await Permission.location.request();

    if (result.isGranted) {
      _permissionSection = PermissionSection.permissionGranted;
    } else if (result.isPermanentlyDenied) {
      _permissionSection = PermissionSection.noLocationPermissionPermanent;
    } else {
      _permissionSection = PermissionSection.noLocationPermission;
    }
    return _permissionSection;
  }
}
