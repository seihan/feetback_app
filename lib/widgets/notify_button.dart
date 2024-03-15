import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class NotifyButton extends StatelessWidget {
  const NotifyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: model.toggleNotify,
          icon: const Icon(
            Icons.podcasts,
          ),
          color: model.isNotifying ? Colors.blue : Colors.grey,
        );
      },
    );
  }
}
