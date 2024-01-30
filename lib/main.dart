import 'dart:async';

import 'package:feet_back_app/global_params.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/record_model.dart';
import 'package:feet_back_app/routes.dart';
import 'package:feet_back_app/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/custom_error_handler.dart';
import 'models/permission_model.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle the Flutter error and stack trace
    CustomErrorHandler.handleFlutterError(
      details.exception,
      details.stack,
    );
  };
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupServices();
    await services.allReady(timeout: const Duration(seconds: 10));
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: services.get<BluetoothConnectionModel>(),
        ),
        ChangeNotifierProvider.value(
          value: services.get<RecordModel>(),
        ),
      ],
      child: const FeetBackApp(),
    ));
  }, (error, stackTrace) {
    // Handle the platform error and stack trace
    CustomErrorHandler.handlePlatformError(error, stackTrace);
  });
}

class FeetBackApp extends StatelessWidget {
  const FeetBackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeetBack',
      navigatorKey: services.get<GlobalParams>().navigatorKey,
      theme: ThemeData.dark(),
      routes: Routes.routes,
      initialRoute: services.get<PermissionModel>().guessInitialRoute(),
      builder: (context, child) {
        return child ?? const CircularProgressIndicator();
      },
    );
  }
}
