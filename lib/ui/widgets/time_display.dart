import 'package:digital_clock/ui/widgets/digit_gif.dart';
import 'package:digital_clock/core/services/log_service.dart';
import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final List<String> digits;
  final double scale;
  final double digitSpacing;
  final String? fontFamily;
  final String? gifBasePath;
  final String? imageFormat;
  final String? assetsBasePath;

  const TimeDisplay({
    super.key,
    required this.digits,
    this.scale = 1.0,
    this.digitSpacing = 0.0,
    this.fontFamily,
    this.gifBasePath,
    this.imageFormat,
    this.assetsBasePath,
  });

  @override
  Widget build(BuildContext context) {
    LogService().debug('TimeDisplay building: digits=${digits.join()}, gifPath=$gifBasePath, format=$imageFormat, assetsBase=$assetsBasePath');
    
    final children = <Widget>[];
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && digitSpacing != 0) {
        children.add(SizedBox(key: ValueKey('spacer_$i'), width: digitSpacing));
      }
      children.add(
        DigitGif(
          key: ValueKey('digit_${i}_${digits[i]}'), // 给每个数字widget添加唯一key
          digit: digits[i],
          scale: scale,
          fontFamily: fontFamily,
          gifBasePath: gifBasePath,
          imageFormat: imageFormat,
          assetsBasePath: assetsBasePath,
        ),
      );
    }

    LogService().debug('TimeDisplay created ${children.length} children widgets');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
