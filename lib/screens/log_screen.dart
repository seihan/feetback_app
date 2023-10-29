import 'package:feet_back_app/models/log_model.dart';
import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LogModel logModel = LogModel();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
      ),
      body: ListView.builder(
        itemCount: logModel.log.length,
        itemBuilder: (context, index) {
          final reversedIndex = logModel.log.length - index - 1;
          return Text(logModel.log[reversedIndex]);
        },
      ),
    );
  }
}
