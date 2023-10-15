import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/widgets/activate_switch.dart';
import 'package:feet_back_app/widgets/devices.dart';
import 'package:feet_back_app/widgets/disconnect_button.dart';
import 'package:flutter/material.dart';

import '../../models/bluetooth_connection_model.dart';
import '../widgets/buzz_button.dart';
import '../widgets/notify_button.dart';
import '../widgets/sensor_sole.dart';

class VisualizationScreen extends StatelessWidget {
  final BluetoothConnectionModel model;
  const VisualizationScreen({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SensorStateModel stateModel = SensorStateModel();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NotifyButton(),
                  DisconnectButton(),
                ],
              ),
              const DeviceWidget(),
              const Spacer(),
              if (model.connected == false)
                Container(
                  color: Colors.black.withAlpha(80),
                  child: const Center(
                    child: Icon(
                      Icons.sensors_off,
                      size: 50.0,
                      color: Colors.white54,
                    ),
                  ),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SensorSole(
                    stream: stateModel.leftDisplayStream,
                    device: 0,
                  ),
                  SensorSole(
                    stream: stateModel.rightDisplayStream,
                    device: 1,
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BuzzButton(mode: 0, device: 2),
                  BuzzButton(mode: 1, device: 2),
                  BuzzButton(mode: 2, device: 2),
                  Spacer(),
                  BuzzButton(mode: 0, device: 3),
                  BuzzButton(mode: 1, device: 3),
                  BuzzButton(mode: 2, device: 3),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActivateSwitch(device: 2),
                  ActivateSwitch(device: 3),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      floatingActionButton: !model.connected
          ? FloatingActionButton(
              onPressed: model.isScanning ? null : model.startScan,
              backgroundColor: model.isScanning ? Colors.red : Colors.green,
              child: Icon(
                model.isScanning ? Icons.stop : Icons.search,
              ),
            )
          : null,
    );
  }
}
