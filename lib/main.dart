import 'dart:async';

import 'global_params.dart';
import 'models/bluetooth_connection_model.dart';
import 'models/record_model.dart';
import 'routes.dart';
import 'services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/error_handler.dart';

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
    await services.allReady(timeout: const Duration(seconds: 3));
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
  const FeetBackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeetBack',
      navigatorKey: services.get<GlobalParams>().navigatorKey,
      theme: ThemeData.dark(),
      routes: Routes.routes,
      initialRoute: Routes.home,
      builder: (context, child) {
        return child ?? const CircularProgressIndicator();
      },
    );
  }
}
