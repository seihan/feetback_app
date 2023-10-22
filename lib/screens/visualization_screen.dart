import 'package:feet_back_app/widgets/charts_widget.dart';
import 'package:feet_back_app/widgets/notify_button.dart';
import 'package:feet_back_app/widgets/sensor_soles.dart';
import 'package:feet_back_app/widgets/side_menu.dart';
import 'package:flutter/material.dart';

import '../../models/bluetooth_connection_model.dart';
import '../widgets/connection_widgets.dart';

class VisualizationScreen extends StatefulWidget {
  final BluetoothConnectionModel model;
  const VisualizationScreen({Key? key, required this.model}) : super(key: key);

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> tabPages = [
      SensorSoles(bluetoothConnectionModel: widget.model),
      const RealTimeChartsWidget(),
    ];
    return Scaffold(
      endDrawer: SideMenu(
        model: widget.model,
      ),
      appBar: AppBar(
        leading: const NotifyButton(),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              ConnectionWidgets(bluetoothConnectionModel: widget.model),
              tabPages[_selectedIndex],
            ],
          ),
        ),
      ),
      floatingActionButton: !widget.model.connected
          ? FloatingActionButton(
              onPressed:
                  widget.model.isScanning ? null : widget.model.startScan,
              backgroundColor:
                  widget.model.isScanning ? Colors.red : Colors.green,
              child: Icon(
                widget.model.isScanning ? Icons.stop : Icons.search,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.display_settings),
            label: 'Soles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.area_chart),
            label: 'Chart',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
