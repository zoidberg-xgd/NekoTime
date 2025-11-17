import 'package:digital_clock/ui/widgets/digit_gif.dart';
import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final List<String> digits;
  final double scale;
  final double digitSpacing;
  final String? fontFamily;

  const TimeDisplay({super.key, required this.digits, this.scale = 1.0, this.digitSpacing = 0.0, this.fontFamily});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && digitSpacing != 0) {
        children.add(SizedBox(width: digitSpacing));
      }
      children.add(DigitGif(digit: digits[i], scale: scale, fontFamily: fontFamily));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      // 基线对齐，让冒号和数字垂直居中
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: children,
    );
  }
}
