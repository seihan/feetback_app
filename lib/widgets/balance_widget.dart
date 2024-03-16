import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../generated/l10n.dart';
import '../models/balance_model.dart';
import 'balance_values.dart';

class BalanceWidget extends StatefulWidget {
  const BalanceWidget({super.key});

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  final BalanceModel balanceModel = BalanceModel();
  static const heightWeight = 0.5;
  static const widthWeight = 0.35;
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
          child: _SwitchWidget(
            switchWidget: switchWidget,
            onChanged: (value) {
              setState(() {
                switchWidget = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: _BalanceStack(
                switchWidget: switchWidget,
                stream: switchWidget
                    ? balanceModel.leftLeftRightBalance
                    : balanceModel.leftFrontRearBalance,
                assetPath: 'assets/sole_mask_left.svg',
                height: height,
                width: width,
                fontSizeBig: fontSizeBig,
                fontSizeSmall: fontSizeSmall,
              ),
            ),
            _BalanceStack(
              switchWidget: switchWidget,
              stream: switchWidget
                  ? balanceModel.rightLeftRightBalance
                  : balanceModel.rightFrontRearBalance,
              assetPath: 'assets/sole_mask_right.svg',
              height: height,
              width: width,
              fontSizeBig: fontSizeBig,
              fontSizeSmall: fontSizeSmall,
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

class _SwitchWidget extends StatelessWidget {
  final bool switchWidget;
  final ValueChanged<bool> onChanged;

  const _SwitchWidget({
    required this.switchWidget,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(switchWidget
            ? S.of(context).leftRightBalance
            : S.of(context).frontRearBalance),
        Switch(
          onChanged: onChanged,
          value: switchWidget,
        ),
      ],
    );
  }
}

class _BalanceStack extends StatelessWidget {
  final bool switchWidget;
  final Stream<double> stream;
  final String assetPath;
  final double height;
  final double width;
  final double fontSizeBig;
  final double fontSizeSmall;

  const _BalanceStack({
    required this.switchWidget,
    required this.stream,
    required this.assetPath,
    required this.height,
    required this.width,
    required this.fontSizeBig,
    required this.fontSizeSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                stream: stream,
                height: height,
                width: width,
              )
            : BalanceValuesWidget.verticalBars(
                stream: stream,
                height: height,
                width: width,
              ),
        SvgPicture.asset(
          assetPath,
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
                      stream: stream,
                    ),
                    BalanceValuesWidget.txtInverted(
                      fontSize: fontSizeSmall,
                      stream: stream,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BalanceValuesWidget.txt(
                      fontSize: fontSizeBig,
                      stream: stream,
                    ),
                    BalanceValuesWidget.txtInverted(
                      fontSize: fontSizeBig,
                      stream: stream,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
