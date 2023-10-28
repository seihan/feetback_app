import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/screens/analytics_screen.dart';
import 'package:feet_back_app/screens/calibration_screen.dart';
import 'package:feet_back_app/screens/feedback_settings.dart';
import 'package:feet_back_app/widgets/record_list_tile.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final BluetoothConnectionModel model;
  const SideMenu({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.sensors_off,
                color: model.connected ? Colors.blue : Colors.white,
              ),
              title: const Text('Disconnect'),
              onTap: model.disconnect,
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => const AnalyticsScreen(),
                ),
              ),
            ),
            const RecordListTile(),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calibration'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => const CalibrationScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Feedback Settings'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => FeedbackSettings(
                    bluetoothConnectionModel: model,
                  ),
                ),
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text('Close Menu'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
