import 'package:digital_clock/ui/widgets/digit_gif.dart';
import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final List<String> digits;
  final double scale;

  const TimeDisplay({super.key, required this.digits, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // 基线对齐，让冒号和数字垂直居中
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: digits
          .map((d) => DigitGif(
                digit: d,
                scale: scale,
              ))
          .toList(),
    );
  }
}
