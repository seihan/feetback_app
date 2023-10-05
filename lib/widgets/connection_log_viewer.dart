import 'package:feet_back_app/widgets/text_stream_widget.dart';
import 'package:flutter/material.dart';

class ConnectionLogViewer extends StatelessWidget {
  final Stream<String> stream;
  const ConnectionLogViewer({
    Key? key,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      height: 115,
      child: TextStreamWidget(textStream: stream),
    );
  }
}
