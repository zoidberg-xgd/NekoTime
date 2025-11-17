import 'package:flutter/material.dart';

class DigitGif extends StatelessWidget {
  final String digit;
  final double scale;

  const DigitGif({super.key, required this.digit, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final double height = 80 * scale;

    if (digit == ':') {
      // 冒号用文本实现
      return SizedBox(
        width: height * 0.4, // 冒号更窄
        height: height,
        child: Center(
          child: Text(
            ':',
            style: TextStyle(
              fontSize: height * 0.6,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.0,
              shadows: const [
                Shadow(
                  blurRadius: 6.0,
                  color: Colors.black45,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Image.asset(
      'assets/gif/$digit.gif',
      // 只限定高度，让宽度随原始比例自适应，避免变形
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, // 像素风，避免模糊和畸变
      gaplessPlayback: true,
    );
  }
}
