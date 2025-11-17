import 'package:digital_clock/ui/widgets/digit_gif_v2.dart';
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
    LogService().debug('📺 TimeDisplay building: digits=${digits.join()}, count=${digits.length}, gifPath=$gifBasePath, format=$imageFormat, spacing=$digitSpacing');
    
    final children = <Widget>[];
    for (int i = 0; i < digits.length; i++) {
      // 只在非第一个元素且非冒号后添加间距
      if (i > 0 && digitSpacing > 0 && digits[i-1] != ':' && digits[i] != ':') {
        children.add(SizedBox(key: ValueKey('spacer_$i'), width: digitSpacing));
        LogService().debug('  ➕ Added spacer before digit[$i]: ${digits[i]}');
      }
      children.add(
        DigitGifV2(
          key: ValueKey('digit_${i}_${digits[i]}'), // 给每个数字widget添加唯一key
          digit: digits[i],
          scale: scale,
          fontFamily: fontFamily,
          gifBasePath: gifBasePath,
          imageFormat: imageFormat,
          assetsBasePath: assetsBasePath,
        ),
      );
      LogService().debug('  📍 Added digit[$i]: ${digits[i]} (isColon: ${digits[i] == ":"})');
    }

    LogService().debug('✅ TimeDisplay created ${children.length} widgets (${digits.length} digits + ${children.length - digits.length} spacers)');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
