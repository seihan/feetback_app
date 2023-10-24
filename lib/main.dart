import 'dart:async';

import 'package:feet_back_app/screens/home.dart';
import 'package:feet_back_app/screens/permission_screen.dart';
import 'package:flutter/material.dart';

import 'models/custom_error_handler.dart';
import 'models/permission_model.dart';

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
      FeetBackApp(
        navigatorKey: navigatorKey,
      ),
    );
  }, (error, stackTrace) {
    // Handle the platform error and stack trace
    CustomErrorHandler.handlePlatformError(error, stackTrace);
  });
}

class FeetBackApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const FeetBackApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PermissionModel permissionModel = PermissionModel();
    return MaterialApp(
      title: 'FeetBack',
      navigatorKey: navigatorKey,
      theme: ThemeData.dark(),
      home: FutureBuilder<PermissionSection>(
        future: permissionModel.requestLocationPermission(),
        builder:
            (BuildContext context, AsyncSnapshot<PermissionSection> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No data available.',
              ),
            );
          } else {
            return snapshot.data == PermissionSection.permissionGranted
                ? HomeScreen(navigatorKey: navigatorKey)
                : PermissionScreen(navigatorKey: navigatorKey);
          }
        },
      ),
    );
  }
}
