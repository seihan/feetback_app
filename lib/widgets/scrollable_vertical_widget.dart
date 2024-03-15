import 'package:flutter/material.dart';

class ScrollableVerticalWidget extends StatelessWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<Widget> children;

  const ScrollableVerticalWidget({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
              crossAxisAlignment:
                  crossAxisAlignment ?? CrossAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
