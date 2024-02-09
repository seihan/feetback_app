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
  static const heightWeight = 0.57;
  static const widthWeight = 0.4;
  static const fontWeightSmall = 0.075;
  static const fontWeightBig = 0.125;
  double height = 420.0;
  double width = 140.0;
  double fontSizeBig = 50.0;
  double fontSizeSmall = 30.0;
  bool switchWidget = false;
  @override
  void initState() {
    super.initState();
    balanceModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    _setSizes(context);
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  child: switchWidget // left / right balance
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              fontSize: fontSizeSmall,
                              stream: balanceModel.leftLeftRightBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              fontSize: fontSizeSmall,
                              stream: balanceModel.leftLeftRightBalance,
                            ),
                          ],
                        ) // front / rear balance
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              fontSize: fontSizeBig,
                              stream: switchWidget
                                  ? balanceModel.leftLeftRightBalance
                                  : balanceModel.leftFrontRearBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              fontSize: fontSizeBig,
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
                              fontSize: fontSizeSmall,
                              stream: balanceModel.rightLeftRightBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              fontSize: fontSizeSmall,
                              stream: balanceModel.rightLeftRightBalance,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BalanceValuesWidget.txt(
                              fontSize: fontSizeBig,
                              stream: balanceModel.rightFrontRearBalance,
                            ),
                            BalanceValuesWidget.txtInverted(
                              fontSize: fontSizeBig,
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
            BalanceValuesWidget.txt(
              fontSize: fontSizeBig,
              stream: balanceModel.leftBalance,
            ),
            BalanceValuesWidget.txt(
              fontSize: fontSizeBig,
              stream: balanceModel.rightBalance,
            ),
          ],
        )
      ],
    );
  }

  void _setSizes(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    switch (mediaQuery.orientation) {
      case Orientation.landscape:
        {
          height = screenWidth * heightWeight;
          width = screenHeight * widthWeight;
          fontSizeBig = screenHeight * fontWeightBig;
          fontSizeSmall = screenHeight * fontWeightSmall;
        }
      case Orientation.portrait:
        {
          height = screenHeight * heightWeight;
          width = screenWidth * widthWeight;
          fontSizeBig = screenWidth * fontWeightBig;
          fontSizeSmall = screenWidth * fontWeightSmall;
        }
    }
  }

  @override
  void dispose() {
    balanceModel.dispose();
    super.dispose();
  }
}
