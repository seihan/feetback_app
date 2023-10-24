import 'package:feet_back_app/screens/visualization_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';
import '../models/sensor_state_model.dart';
import '../widgets/connection_log_viewer.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const HomeScreen({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ChangeNotifierProvider<BluetoothConnectionModel>(
      create: (_) => BluetoothConnectionModel(
        navigatorKey: navigatorKey,
        sensorStateModel: SensorStateModel(),
      )..initialize(),
      child: Consumer<BluetoothConnectionModel>(
        builder: (BuildContext context,
            BluetoothConnectionModel connectionModel, Widget? child) {
          return Stack(
            children: [
              ConnectionLogViewer(
                stream: connectionModel.log,
              ),
              VisualizationScreen(
                model: connectionModel,
              ),
            ],
          );
        },
      ),
    );
  }
}
