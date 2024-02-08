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
  bool switchWidget = false;
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
        Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(switchWidget
                    ? 'Left / Right Balance'
                    : 'Front / Rear Balance'),
                Switch(
                  onChanged: (bool value) {
                    setState(() {
                      switchWidget = value;
                    });
                  },
                  value: switchWidget,
                ),
              ],
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    height: height - 2,
                    width: width,
                    color: Colors.blueGrey,
                  ),
                ),
                switchWidget
                    ? BalanceValuesWidget.horizontalBars(
                        stream: balanceModel.leftLeftRightBalance,
                        height: height,
                        width: width,
                      )
                    : BalanceValuesWidget.verticalBars(
                        stream: balanceModel.leftFrontRearBalance,
                        height: height,
                        width: width,
                      ),
                SvgPicture.asset(
                  'assets/sole_mask_left.svg',
                  height: height,
                ),
                SizedBox(
                  height: height,
                  width: width,
                  child: switchWidget
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              fontSize: 40,
                              stream: balanceModel.leftLeftRightBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              fontSize: 40,
                              stream: balanceModel.leftLeftRightBalance,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              stream: switchWidget
                                  ? balanceModel.leftLeftRightBalance
                                  : balanceModel.leftFrontRearBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              stream: switchWidget
                                  ? balanceModel.leftLeftRightBalance
                                  : balanceModel.leftFrontRearBalance,
                            ),
                          ],
                        ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    height: height - 2,
                    width: width,
                    color: Colors.blueGrey,
                  ),
                ),
                switchWidget
                    ? BalanceValuesWidget.horizontalBars(
                        stream: balanceModel.rightLeftRightBalance,
                        height: height,
                        width: width,
                      )
                    : BalanceValuesWidget.verticalBars(
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
                  width: width,
                  child: switchWidget
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              fontSize: 40,
                              stream: balanceModel.rightLeftRightBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              fontSize: 40,
                              stream: balanceModel.rightLeftRightBalance,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              stream: balanceModel.rightFrontRearBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              stream: balanceModel.rightFrontRearBalance,
                            ),
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
