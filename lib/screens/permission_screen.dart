import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/log_model.dart';
import '../models/permission_model.dart';
import '../routes.dart';
import '../services.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  final _permissionModel = services.get<PermissionModel>();
  bool _detectPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This block of code is used in the event that the user
  // has denied the permission forever. Detects if the permission
  // has been granted when the user returns from the
  // permission system screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _detectPermission &&
        (_permissionModel.permissionSection ==
            PermissionSection.noLocationPermissionPermanent)) {
      _detectPermission = false;
      _permissionModel.requestLocationPermission();
    } else if (state == AppLifecycleState.paused &&
        _permissionModel.permissionSection ==
            PermissionSection.noLocationPermissionPermanent) {
      _detectPermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _permissionModel,
      child: Consumer<PermissionModel>(
        builder: (context, model, child) {
          Widget widget;
          switch (model.permissionSection) {
            case PermissionSection.noLocationPermission:
              widget = LocationPermissions(
                isPermanent: false,
                onPressed: _checkPermissions,
              );
              break;
            case PermissionSection.noLocationPermissionPermanent:
              widget = LocationPermissions(
                isPermanent: true,
                onPressed: _checkPermissions,
              );
              break;
            case PermissionSection.permissionGranted:
              widget = Container(); // this will never reached
              break;
            case PermissionSection.unknown:
              widget = LocationPermissions(
                isPermanent: false,
                onPressed: _checkPermissions,
              );
              break;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).handlePermissions),
            ),
            body: widget,
          );
        },
      ),
    );
  }

  /// Check if the pick file permission is granted,
  /// if it's not granted then request it.
  /// If it's granted then invoke the file picker
  Future<void> _checkPermissions() async {
    final section = await _permissionModel.requestLocationPermission();
    LogModel().add('Location permission: $section');
    if (section == PermissionSection.permissionGranted) {
      _goToHomeScreen();
    }
  }

  /// Leave permission screen and go to home screen
  /// There is no need to came back, that's why the
  /// route will be removed
  void _goToHomeScreen() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home,
      (route) => false,
    );
  }
}

/// This widget will serve to inform the user in
/// case the permission has been denied. There is a
/// variable [isPermanent] to indicate whether the
/// permission has been denied forever or not.
class LocationPermissions extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const LocationPermissions({
    super.key,
    required this.isPermanent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              S.of(context).locationServicePermission,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              S.of(context).requestYourPermission,
              textAlign: TextAlign.center,
            ),
          ),
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                S.of(context).giveThisPermission,
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
              bottom: 24.0,
            ),
            child: ElevatedButton(
              child: Text(isPermanent
                  ? S.of(context).openSettings
                  : S.of(context).allowAccess),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}

/// This widget is simply the button to select
/// the image from the local file system.
class StartButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StartButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                S.of(context).permissionsAreGranted,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                S.of(context).prepareYourself,
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(S.of(context).letsStart),
            ),
          ],
        ),
      );
}
