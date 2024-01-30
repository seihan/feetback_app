import 'package:feet_back_app/screens/visualization_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (BuildContext context, BluetoothConnectionModel connectionModel,
          Widget? child) {
        return VisualizationScreen(model: connectionModel);
      },
    );
  }
}
