import 'package:feet_back_app/widgets/charts_widget.dart';
import 'package:feet_back_app/widgets/heatmap_widget.dart';
import 'package:feet_back_app/widgets/notify_button.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
import 'package:feet_back_app/widgets/sensor_soles.dart';
import 'package:feet_back_app/widgets/side_menu.dart';
import 'package:flutter/material.dart';

import '../../models/bluetooth_connection_model.dart';
import '../models/calibration_model.dart';
import '../widgets/connection_widgets.dart';

class VisualizationScreen extends StatefulWidget {
  final BluetoothConnectionModel model;
  const VisualizationScreen({Key? key, required this.model}) : super(key: key);

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  final CalibrationModel _calibrationModel = CalibrationModel();
  final List<Widget> _tabPages = [
    const SensorSoles(),
    const HeatmapSoles(),
    const RealTimeChartsWidget(),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConnectionWidgets(bluetoothConnectionModel: widget.model),
            _tabPages[_selectedIndex],
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.display_settings),
            label: 'Soles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Heatmap',
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
