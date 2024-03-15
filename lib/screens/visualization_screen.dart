import '../widgets/charts_widget.dart';
import '../widgets/notify_button.dart';
import '../widgets/scrollable_vertical_widget.dart';
import '../widgets/sensor_soles.dart';
import '../widgets/side_menu.dart';
import 'package:flutter/material.dart';

import '../../models/bluetooth_connection_model.dart';
import '../models/calibration_model.dart';
import '../widgets/balance_widget.dart';
import '../widgets/connection_widgets.dart';

class VisualizationScreen extends StatefulWidget {
  final BluetoothConnectionModel model;
  const VisualizationScreen({super.key, required this.model});

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  final CalibrationModel _calibrationModel = CalibrationModel();
  final List<Widget> _tabPages = [
    const SensorSoles(),
    const BalanceWidget(),
    const RealTimeChartsWidget(),
  ];
  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(
        Icons.display_settings,
      ),
      label: 'Soles',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.scale),
      label: 'Balance',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.area_chart),
      label: 'Chart',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _calibrationModel.getPredictedValues();
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const SideMenu(),
      appBar: AppBar(
        leading: const NotifyButton(),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ScrollableVerticalWidget(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConnectionWidgets(bluetoothConnectionModel: widget.model),
            _tabPages[_selectedIndex],
            const SizedBox.shrink(), // placeholder to center widgets
          ],
        ),
      ),
      floatingActionButton: !widget.model.connected
          ? FloatingActionButton(
              onPressed: widget.model.isScanning
                  ? widget.model.stopScan
                  : widget.model.startScan,
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
        items: _items,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
