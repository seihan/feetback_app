import 'dart:async';

import 'package:feet_back_app/screens/home.dart';
import 'package:feet_back_app/screens/permission_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/bluetooth_connection_model.dart';
import 'models/custom_error_handler.dart';
import 'models/permission_model.dart';
import 'models/sensor_state_model.dart';

void main() {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle the Flutter error and stack trace
    CustomErrorHandler.handleFlutterError(
      details.exception,
      details.stack,
    );
  };
  runZonedGuarded(() {
    runApp(
      LineCtrlApp(
        navigatorKey: navigatorKey,
      ),
    );
  }, (error, stackTrace) {
    // Handle the platform error and stack trace
    CustomErrorHandler.handlePlatformError(error, stackTrace);
  });
}

class LineCtrlApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const LineCtrlApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PermissionModel()..requestLocationPermission(),
        ),
        ChangeNotifierProvider<BluetoothConnectionModel>(
          create: (_) => BluetoothConnectionModel(
            navigatorKey: navigatorKey,
            sensorStateModel: SensorStateModel(),
          )..initialize(),
        ),
        ChangeNotifierProvider<SensorStateModel>(
          create: (_) => SensorStateModel(),
        ),
      ],
      child: MaterialApp(
        title: 'FeetBack',
        navigatorKey: navigatorKey,
        theme: ThemeData.dark(),
        home: Consumer<PermissionModel>(
          builder: (context, permissionModel, child) {
            return permissionModel.permissionSection ==
                    PermissionSection.permissionGranted
                ? const HomeScreen()
                : const PermissionScreen();
          },
        ),
      ),
    );
  }
}
