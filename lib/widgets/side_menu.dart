import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/bluetooth_connection_model.dart';
import '../routes.dart';
import 'record_list_tile.dart';
import 'scrollable_vertical_widget.dart';

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
                    title: Text(S.of(context).disconnect),
                    onTap: model.disconnect,
                  );
                }),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: Text(S.of(context).analytics),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.analytics,
                  ),
                ),
                const RecordListTile(),
                ListTile(
                  leading: const Icon(Icons.calculate),
                  title: Text(S.of(context).calibration),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.calibration,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(S.of(context).feedbackSettings),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.feedback,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.satellite_alt),
                  title: Text(S.of(context).sensorSettings),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.sensorSettings,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.satellite_alt),
                  title: Text(S.of(context).actorSettings),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.actorSettings,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: Text(S.of(context).log),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.logs,
                  ),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: Text(S.of(context).closeMenu),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
