import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';
import '../widgets/connection_log_viewer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return Consumer<BluetoothConnectionModel>(
      builder: (context, connectionModel, child) {
        return Stack(
          children: [
            ConnectionLogViewer(
              stream: connectionModel.log,
            ),
          ],
        );
      },
    );
  }
}
