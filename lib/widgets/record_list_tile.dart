import 'package:feet_back_app/models/record_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecordListTile extends StatelessWidget {
  const RecordListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordModel>(
      builder: (BuildContext context, RecordModel model, Widget? child) {
        return ListTile(
          leading: Icon(
            model.record
                ? Icons.fiber_manual_record_rounded
                : Icons.fiber_manual_record_outlined,
            color: model.record ? Colors.red : Colors.grey,
          ),
          title: const Text('Record'),
          subtitle: Text('Duration: ${model.duration} s'),
          onTap: model.record ? model.stopRecord : model.startRecord,
        );
      },
    );
  }
}
