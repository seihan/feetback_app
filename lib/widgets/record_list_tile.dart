import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/record_model.dart';

class RecordListTile extends StatelessWidget {
  const RecordListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordModel>(
      builder: (BuildContext context, RecordModel model, Widget? child) {
        return ListTile(
          leading: Icon(
            Icons.fiber_manual_record_rounded,
            color: model.record ? Colors.red : Colors.white,
          ),
          title: Text(S.of(context).record),
          subtitle: Text(S.of(context).duration(model.duration)),
          onTap: model.record ? model.stopRecord : model.startRecord,
        );
      },
    );
  }
}
