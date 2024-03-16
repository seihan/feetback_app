import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../widgets/database_view.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).analytics),
      ),
      body: const DatabaseView(),
    );
  }
}
