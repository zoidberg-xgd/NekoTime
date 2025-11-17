import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:digital_clock/core/services/log_service.dart';

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

class _DigitGifState extends State<DigitGif> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持状态不被销毁

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，以支持 AutomaticKeepAliveClientMixin
    
    final double height = 80 * widget.scale;

    if (widget.digit == ':') {
      // 冒号用文本实现
      return SizedBox(
        width: height * 0.25, // 冒号更窄
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
    Widget digitImage;
    // 如果没有指定路径，默认使用应用内置的 assets/gif
    final imagePath = widget.gifBasePath ?? 'assets/gif';
    final format = widget.imageFormat ?? 'gif';
    
    LogService().debug('Loading digit image: digit=${widget.digit}, path=$imagePath, format=$format, assetsBase=${widget.assetsBasePath}');
    
    // 判断是内置资源还是外部文件
    if (imagePath.startsWith('assets/')) {
      // 内置资源，使用 Image.asset
      final String assetPath = _findAssetPath(imagePath, widget.digit, format);
      LogService().debug('Using asset path: $assetPath');
      digitImage = Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        cacheWidth: null,
        cacheHeight: null,
        errorBuilder: (context, error, stack) {
          LogService().error('DigitImage asset load failed', error: 'digit: ${widget.digit}, path: $assetPath, error: $error');
          // 直接返回文本作为后备，不要再尝试加载图片
          return _buildErrorWidget(height);
        },
      );
    } else if (widget.assetsBasePath != null) {
      // 外部主题资源，使用 FileImage
      final File? file = _findExternalFile(widget.assetsBasePath!, imagePath, widget.digit, format);
      if (file != null && file.existsSync()) {
        LogService().debug('Using external file: ${file.path}');
        digitImage = Image.file(
          file,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) {
            LogService().error('DigitImage file load failed', error: 'digit: ${widget.digit}, path: ${file.path}, error: $error');
            return _buildErrorWidget(height);
          },
        );
      } else {
        LogService().warning('DigitImage file not found for digit: ${widget.digit} in ${widget.assetsBasePath}/$imagePath');
        digitImage = _buildErrorWidget(height);
      }
    } else {
      // 没有提供路径，使用默认内置资源
      final String assetPath = _findAssetPath('assets/gif', widget.digit, format);
      LogService().debug('Using default asset path: $assetPath');
      digitImage = Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) {
          LogService().error('DigitImage default asset load failed', error: 'digit: ${widget.digit}, error: $error');
          return _buildErrorWidget(height);
        },
      );
    }

    return SizedBox(
      width: height * 0.58, // 更紧凑，但仍保持人物显示
      height: height,
      child: Center(
        child: digitImage,
      ),
    );
  }

  // 支持的图片格式列表，按优先级排序
  static const List<String> _supportedFormats = ['gif', 'png', 'jpg', 'jpeg', 'webp', 'bmp'];

  // 查找内置资源路径
  String _findAssetPath(String basePath, String digit, String format) {
    // 直接返回完整路径，Image.asset 会处理加载
    return '$basePath/$digit.$format';
  }

  // 查找外部文件
  File? _findExternalFile(String basePath, String imagePath, String digit, String? format) {
    if (format != null && format.isNotEmpty) {
      // 如果指定了格式，只尝试该格式
      final file = File(p.join(basePath, imagePath, '$digit.$format'));
      LogService().debug('Checking external file: ${file.path}, exists: ${file.existsSync()}');
      return file.existsSync() ? file : null;
    }
    
    // 自动检测：按优先级尝试各种格式
    LogService().debug('Auto-detecting format for digit $digit in $basePath/$imagePath');
    for (final fmt in _supportedFormats) {
      final file = File(p.join(basePath, imagePath, '$digit.$fmt'));
      if (file.existsSync()) {
        LogService().debug('Found external file with format $fmt: ${file.path}');
        return file;
      }
    }
    
    LogService().debug('No external file found for digit $digit in any supported format');
    return null;
  }

  Widget _buildErrorWidget(double height) {
    // 使用文本作为后备显示，样式与冒号保持一致
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        widget.digit,
        style: TextStyle(
          fontSize: height * 0.6,
          color: Colors.white,  // 改为白色，不要红色
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
  }
}
