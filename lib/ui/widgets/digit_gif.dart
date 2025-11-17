import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:neko_time/core/services/log_service.dart';

class DigitGif extends StatefulWidget {
  final String digit;
  final double scale;
  final String? fontFamily;
  final String? gifBasePath; // 数字图片资源的基础路径
  final String? imageFormat; // 图片格式：'gif', 'png', 'jpg', 'webp' 等，null 表示自动检测
  final String? assetsBasePath; // 主题的文件系统根路径（用于外部主题）

  const DigitGif({
    super.key,
    required this.digit,
    this.scale = 1.0,
    this.fontFamily,
    this.gifBasePath,
    this.imageFormat,
    this.assetsBasePath,
  });

  @override
  State<DigitGif> createState() => _DigitGifState();
}

class _DigitGifState extends State<DigitGif>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持状态不被销毁

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，以支持 AutomaticKeepAliveClientMixin

    final double height = 80 * widget.scale;
    final double digitWidth = height * 0.58;
    final double colonWidth = height * 0.25;

    LogService().debug(
        '🔨 Building digit: "${widget.digit}", height: ${height.toStringAsFixed(1)}, width: ${widget.digit == ":" ? colonWidth.toStringAsFixed(1) : digitWidth.toStringAsFixed(1)}');

    if (widget.digit == ':') {
      // 冒号用文本实现
      LogService().debug(
          '  ➡️ Rendering colon with text, width: ${colonWidth.toStringAsFixed(1)}');
      return SizedBox(
        width: colonWidth, // 冒号更窄
        height: height,
        child: Center(
          child: Text(
            ':',
            style: TextStyle(
              fontSize: height * 0.6,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: widget.fontFamily,
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

    // 构建数字图片 widget
    // 如果没有指定路径，默认使用应用内置的 assets/gif
    final imagePath = widget.gifBasePath ?? 'assets/gif';
    final format = widget.imageFormat ?? 'gif';

    LogService().debug(
        '🔍 Loading digit image: digit="${widget.digit}", path=$imagePath, format=$format, assetsBase=${widget.assetsBasePath}');

    // 先尝试构建文本后备widget，如果GIF加载失败就用它
    Widget textFallback = Container(
      width: digitWidth,
      height: height,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        widget.digit,
        style: TextStyle(
          fontSize: height * 0.6,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: widget.fontFamily,
          shadows: const [
            Shadow(
              blurRadius: 6.0,
              color: Colors.black45,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
    );

    Widget digitImage;

    // 核心判断逻辑：
    // 1. 如果path是"assets/"开头，ALWAYS使用内置资源，忽略assetsBasePath
    // 2. 否则才使用外部文件路径
    final bool isBuiltinAsset = imagePath.startsWith('assets/');

    LogService().debug(
        '  🎯 Resource type: ${isBuiltinAsset ? "BUILTIN ASSET" : "EXTERNAL FILE"}');

    if (isBuiltinAsset) {
      // 内置资源，使用 Image.asset，包装在Container中避免默认错误显示
      final String assetPath = _findAssetPath(imagePath, widget.digit, format);
      LogService().debug('  📦 Loading asset: $assetPath');

      digitImage = Container(
        width: digitWidth,
        height: height,
        color: Colors.transparent,
        child: Image.asset(
          assetPath,
          width: digitWidth,
          height: height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stack) {
            LogService().error(
                '❌ Asset load FAILED: digit=${widget.digit}, path=$assetPath, error=$error');
            // 直接返回一个新的Container with Text，不复用textFallback
            return SizedBox(
              width: digitWidth,
              height: height,
              child: Center(
                child: Text(
                  widget.digit,
                  style: TextStyle(
                    fontSize: height * 0.6,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: widget.fontFamily,
                  ),
                ),
              ),
            );
          },
        ),
      );
      LogService()
          .debug('  ✅ Created asset container for digit: ${widget.digit}');
    } else {
      // 外部主题资源，使用 FileImage
      if (widget.assetsBasePath == null) {
        LogService().warning(
            '  ⚠️ No assetsBasePath for external resource, using text fallback');
        digitImage = textFallback;
      } else {
        final File? file = _findExternalFile(
            widget.assetsBasePath!, imagePath, widget.digit, format);
        if (file != null && file.existsSync()) {
          LogService().debug('  📁 Using external file: ${file.path}');
          digitImage = Image.file(
            file,
            width: digitWidth,
            height: height,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
            gaplessPlayback: true,
            errorBuilder: (context, error, stack) {
              LogService().error('❌ DigitImage file errorBuilder triggered!',
                  error:
                      'digit: ${widget.digit}, path: ${file.path}, error: $error');
              return textFallback;
            },
          );
        } else {
          LogService().warning(
              '  ⚠️ File not found for digit: ${widget.digit} in ${widget.assetsBasePath}/$imagePath');
          digitImage = textFallback;
        }
      }
    }

    LogService().debug(
        '  ✅ Returning final widget: width=${digitWidth.toStringAsFixed(1)}, height=${height.toStringAsFixed(1)}');

    // 直接返回digitImage，它已经有正确的尺寸
    return digitImage;
  }

  // 支持的图片格式列表，按优先级排序
  static const List<String> _supportedFormats = [
    'gif',
    'png',
    'jpg',
    'jpeg',
    'webp',
    'bmp'
  ];

  // 查找内置资源路径
  String _findAssetPath(String basePath, String digit, String format) {
    // 直接返回完整路径，Image.asset 会处理加载
    return '$basePath/$digit.$format';
  }

  // 查找外部文件
  File? _findExternalFile(
      String basePath, String imagePath, String digit, String? format) {
    if (format != null && format.isNotEmpty) {
      // 如果指定了格式，只尝试该格式
      final file = File(p.join(basePath, imagePath, '$digit.$format'));
      LogService().debug(
          'Checking external file: ${file.path}, exists: ${file.existsSync()}');
      return file.existsSync() ? file : null;
    }

    // 自动检测：按优先级尝试各种格式
    LogService().debug(
        'Auto-detecting format for digit $digit in $basePath/$imagePath');
    for (final fmt in _supportedFormats) {
      final file = File(p.join(basePath, imagePath, '$digit.$fmt'));
      if (file.existsSync()) {
        LogService()
            .debug('Found external file with format $fmt: ${file.path}');
        return file;
      }
    }

    LogService().debug(
        'No external file found for digit $digit in any supported format');
    return null;
  }
}
