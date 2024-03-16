import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/log_model.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LogModel logModel = LogModel();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).log),
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
              return Center(
                child: Text(
                  S.of(context).error(log.error.toString()),
                ),
              );
            } else if (!log.hasData) {
              return Center(
                child: Text(S.of(context).noDataAvailable),
              );
            }
            return ListView.builder(
              itemCount: log.data?.length,
              itemBuilder: (BuildContext context, int index) {
                final int reversedIndex = (log.data?.length ?? 0) - index - 1;
                return Text(
                  log.data?[reversedIndex] ?? S.of(context).noData,
                );
              },
            );
          }),
    );
  }
}
