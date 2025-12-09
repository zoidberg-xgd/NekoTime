import 'package:neko_time/ui/widgets/digit_gif_v2.dart';
import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final List<String> digits;
  final double scale;
  final double digitSpacing;
  final String? fontFamily;
  final String? gifBasePath;
  final String? imageFormat;
  final String? assetsBasePath;
  final double? digitAspectRatio;
  final double? digitBaseHeight;

  const TimeDisplay({
    super.key,
    required this.digits,
    this.scale = 1.0,
    this.digitSpacing = 0.0,
    this.fontFamily,
    this.gifBasePath,
    this.imageFormat,
    this.assetsBasePath,
    this.digitAspectRatio,
    this.digitBaseHeight,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < digits.length; i++) {
      // 只在非第一个元素且非冒号后添加间距
      if (i > 0 &&
          digitSpacing > 0 &&
          digits[i - 1] != ':' &&
          digits[i] != ':') {
        children.add(SizedBox(key: ValueKey('spacer_$i'), width: digitSpacing));
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
          digitAspectRatio: digitAspectRatio,
          digitBaseHeight: digitBaseHeight,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
