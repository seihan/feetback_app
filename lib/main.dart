import 'dart:async';

import 'package:feet_back_app/global_params.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/record_model.dart';
import 'package:feet_back_app/routes.dart';
import 'package:feet_back_app/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/error_handler.dart';
import 'models/permission_model.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.handleFlutterError(
      details.exception,
      details.stack,
    );
  };
  ErrorHandler.buildErrorWidget();
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupServices();
    await services.allReady(timeout: const Duration(seconds: 20));
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
    ErrorHandler.handlePlatformError(error, stackTrace);
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
