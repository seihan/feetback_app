import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/balance_model.dart';
import 'balance_values.dart';

class BalanceWidget extends StatefulWidget {
  const BalanceWidget({super.key});

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  final BalanceModel balanceModel = BalanceModel();
  static const height = 420.0;
  static const width = 140.0;
  @override
  void initState() {
    super.initState();
    balanceModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              children: [
                BalanceValuesWidget.box(
                  stream: balanceModel.leftFrontRearBalance,
                  height: height,
                  width: width,
                ),
                SvgPicture.asset(
                  'assets/sole_mask_left.svg',
                  height: 420,
                ),
                SizedBox(
                  height: height,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BalanceValuesWidget.txt(
                          stream: balanceModel.leftFrontRearBalance),
                      BalanceValuesWidget.txtInverted(
                          stream: balanceModel.leftFrontRearBalance),
                    ],
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                BalanceValuesWidget.box(
                  stream: balanceModel.rightFrontRearBalance,
                  height: height,
                  width: width,
                ),
                SvgPicture.asset(
                  'assets/sole_mask_right.svg',
                  height: 420,
                ),
                SizedBox(
                  height: height,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BalanceValuesWidget.txt(
                          stream: balanceModel.rightFrontRearBalance),
                      BalanceValuesWidget.txtInverted(
                          stream: balanceModel.rightFrontRearBalance),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BalanceValuesWidget.txt(stream: balanceModel.leftBalance),
            BalanceValuesWidget.txt(stream: balanceModel.rightBalance),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    balanceModel.dispose();
    super.dispose();
  }
}
