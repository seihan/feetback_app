import 'package:flutter/material.dart';

class FrequencyWidget extends StatelessWidget {
  final Stream<int> stream;
  const FrequencyWidget({required this.stream, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<int> frequency,
        ) {
          int freq = frequency.data ?? 0;
          return Text('$freq Hz');
        });
  }
}
