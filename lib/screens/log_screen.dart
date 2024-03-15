import '../models/log_model.dart';
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
      body: StreamBuilder(
          stream: logModel.log,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<String>> log,
          ) {
            if (log.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (log.hasError) {
              return Center(child: Text('Error: ${log.error}'));
            } else if (!log.hasData) {
              return const Center(
                child: Text(
                  'No data available.',
                ),
              );
            }
            return ListView.builder(
              itemCount: log.data?.length,
              itemBuilder: (BuildContext context, int index) {
                final int reversedIndex = (log.data?.length ?? 0) - index - 1;
                return Text(log.data?[reversedIndex] ?? 'no data');
              },
            );
          }),
    );
  }
}
