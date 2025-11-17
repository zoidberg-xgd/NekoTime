import 'package:flutter/material.dart';

class DigitGif extends StatelessWidget {
  final String digit;
  final double scale;
  final String? fontFamily;

  const DigitGif({super.key, required this.digit, this.scale = 1.0, this.fontFamily});

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
              fontFamily: fontFamily,
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

    return SizedBox(
      width: height * 0.75, // 设定一个固定的宽高比，例如 3:4
      height: height,
      child: Image.asset(
        'assets/gif/$digit.gif',
        fit: BoxFit.contain, // 保持原始比例
        filterQuality: FilterQuality.none, // 像素风，避免模糊和畸变
        gaplessPlayback: true,
      ),
    );
  }
}
