import 'package:flutter/material.dart';

import '../models/balance_model.dart';

class BalanceWidget extends StatefulWidget {
  final bool asRow;
  const BalanceWidget({super.key, this.asRow = true});

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  final BalanceModel balanceModel = BalanceModel();
  @override
  void initState() {
    super.initState();
    balanceModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asRow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BalanceValuesWidget(stream: balanceModel.leftBalance),
          BalanceValuesWidget(stream: balanceModel.rightBalance),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              BalanceValuesWidget(stream: balanceModel.leftFrontRearBalance),
              BalanceValuesWidget(stream: balanceModel.leftFrontRearBalance),
            ],
          ),
          Column(
            children: [
              BalanceValuesWidget(stream: balanceModel.rightFrontRearBalance),
              BalanceValuesWidget(stream: balanceModel.rightFrontRearBalance),
            ],
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    balanceModel.dispose();
    super.dispose();
  }
}

class BalanceValuesWidget extends StatelessWidget {
  final Stream<double> stream;
  const BalanceValuesWidget({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<double> sensorState,
        ) {
          return Text(
            '${sensorState.data?.toStringAsFixed(0) ?? 0}%',
            style: const TextStyle(fontSize: 50),
          );
        });
  }
}
