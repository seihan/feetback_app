import '../models/bluetooth_connection_model.dart';
import 'record_list_tile.dart';
import 'scrollable_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 180,
      child: SafeArea(
        child: ScrollableVerticalWidget(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Consumer<BluetoothConnectionModel>(builder:
                    (BuildContext context, BluetoothConnectionModel model,
                        Widget? child) {
                  return ListTile(
                    leading: Icon(
                      Icons.sensors_off,
                      color: model.connected ? Colors.blue : Colors.white,
                    ),
                    title: const Text('Disconnect'),
                    onTap: model.disconnect,
                  );
                }),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Analytics'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.analytics,
                  ),
                ),
                const RecordListTile(),
                ListTile(
                  leading: const Icon(Icons.calculate),
                  title: const Text('Calibration'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.calibration,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Feedback Settings'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.feedback,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.satellite_alt),
                  title: const Text('Sensor Settings'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.sensorSettings,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.satellite_alt),
                  title: const Text('Actor Settings'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.actorSettings,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Log'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.logs,
                  ),
                ),
              ],
            ),
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
