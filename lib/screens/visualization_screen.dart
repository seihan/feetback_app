import 'package:feet_back_app/widgets/disconnect_button.dart';
import 'package:flutter/material.dart';

import '../../models/bluetooth_connection_model.dart';
import '../widgets/notify_button.dart';

class VisualizationScreen extends StatelessWidget {
  final BluetoothConnectionModel model;
  const VisualizationScreen({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const Row(),
            const Align(
              alignment: Alignment.topRight,
              child: NotifyButton(),
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: DisconnectButton(),
            ),
            if (model.connected == false)
              Container(
                color: Colors.black.withAlpha(80),
                child: const Center(
                  child: Icon(
                    Icons.sensors_off,
                    size: 200.0,
                    color: Colors.white54,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: model.isScanning ? null : model.startScan,
        backgroundColor: model.isScanning ? Colors.red : Colors.green,
        child: Icon(
          model.isScanning ? Icons.stop : Icons.search,
        ),
      ),
    );
  }
}
