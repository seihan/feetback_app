import 'package:feet_back_app/screens/visualization_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';
import '../models/record_model.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const HomeScreen({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BluetoothConnectionModel>(
          create: (_) => BluetoothConnectionModel(
            navigatorKey: navigatorKey,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => RecordModel(),
        ),
      ],
      child: Consumer<BluetoothConnectionModel>(
        builder: (BuildContext context,
            BluetoothConnectionModel connectionModel, Widget? child) {
          return VisualizationScreen(model: connectionModel);
        },
      ),
    );
  }
}
