import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neko_time/core/services/log_service.dart';

/// 数字GIF显示组件 - 重构版本
/// 统一处理内置资源和外部资源，确保加载失败时正确显示文本后备
class DigitGifV2 extends StatefulWidget {
  final String digit;
  final double scale;
  final String? fontFamily;
  final String? gifBasePath;
  final String? imageFormat;
  final String? assetsBasePath;
  final double? digitAspectRatio; // width/height ratio detected from theme
  final double? digitBaseHeight; // original height of digit image in pixels

  const DigitGifV2({
    super.key,
    required this.digit,
    this.scale = 1.0,
    this.fontFamily,
    this.gifBasePath,
    this.imageFormat,
    this.assetsBasePath,
    this.digitAspectRatio,
    this.digitBaseHeight,
  });

  @override
  State<DigitGifV2> createState() => _DigitGifV2State();
}

class _DigitGifV2State extends State<DigitGifV2> {
  bool _assetExists = false;
  bool _isCheckingAsset = true;
  
  // 静态缓存，避免重复检查资源是否存在
  static final Map<String, bool> _assetExistsCache = {};

  @override
  void initState() {
    super.initState();
    _checkAssetExists();
  }

  @override
  void didUpdateWidget(DigitGifV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit ||
        oldWidget.gifBasePath != widget.gifBasePath ||
        oldWidget.imageFormat != widget.imageFormat) {
      _checkAssetExists();
    }
  }

  Future<void> _checkAssetExists() async {
    if (widget.digit == ':') {
      if (mounted) {
        setState(() {
          _isCheckingAsset = false;
          _assetExists = false; // 冒号不需要图片
        });
      }
      return;
    }

    final imagePath =
        widget.gifBasePath ?? 'themes/builtin/frosted_glass/digits';
    final format = widget.imageFormat ?? 'gif';
    final assetPath = '$imagePath/${widget.digit}.$format';

    // 先检查缓存
    if (_assetExistsCache.containsKey(assetPath)) {
      if (mounted) {
        setState(() {
          _assetExists = _assetExistsCache[assetPath]!;
          _isCheckingAsset = false;
        });
      }
      return;
    }

    // 检查是否在AssetBundle中（内置资源和打包的主题）
    if (imagePath.startsWith('assets/') || imagePath.startsWith('themes/')) {
      try {
        // 只检查资源是否存在，不加载整个文件
        await rootBundle.load(assetPath);
        _assetExistsCache[assetPath] = true;
        if (mounted) {
          setState(() {
            _assetExists = true;
            _isCheckingAsset = false;
          });
        }
      } catch (e) {
        _assetExistsCache[assetPath] = false;
        if (mounted) {
          setState(() {
            _assetExists = false;
            _isCheckingAsset = false;
          });
        }
      }
    } else {
      // 外部文件
      _assetExistsCache[assetPath] = false;
      if (mounted) {
        setState(() {
          _assetExists = false;
          _isCheckingAsset = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use detected base height, or fallback to default 80
    final double baseHeight = widget.digitBaseHeight ?? 80.0;
    final double height = baseHeight * widget.scale;
    // Use detected aspect ratio, or fallback to default 0.58
    final double aspectRatio = widget.digitAspectRatio ?? 0.58;
    final double digitWidth = height * aspectRatio;
    // Colon width is proportional to digit width
    final double colonWidth = digitWidth * 0.45;

    // 冒号用文本显示，添加强阴影确保在任何透明度下都可见
    if (widget.digit == ':') {
      return SizedBox(
        width: colonWidth,
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
              shadows: [
                // 多层阴影，确保高可见性
                Shadow(
                  blurRadius: 8.0,
                  color: Colors.black.withValues(alpha: 0.9),
                  offset: const Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 12.0,
                  color: Colors.black.withValues(alpha: 0.7),
                  offset: const Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 3.0,
                  color: Colors.black,
                  offset: const Offset(1.0, 1.0),
                ),
                Shadow(
                  blurRadius: 3.0,
                  color: Colors.black,
                  offset: const Offset(-1.0, -1.0),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 如果还在检查资源，显示空白占位符
    if (_isCheckingAsset) {
      return SizedBox(width: digitWidth, height: height);
    }

    // 如果资源不存在，直接显示文本
    if (!_assetExists) {
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
    }

    // 资源存在，加载图片
    final imagePath =
        widget.gifBasePath ?? 'themes/builtin/frosted_glass/digits';
    final format = widget.imageFormat ?? 'gif';
    final assetPath = '$imagePath/${widget.digit}.$format';

    return SizedBox(
      width: digitWidth,
      height: height,
      child: Image.asset(
        assetPath,
        width: digitWidth,
        height: height,
        fit: BoxFit.contain,  // 保持原始纵横比，避免拉伸变形
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        // 即使预检查通过，还是保留errorBuilder作为最后防线
        errorBuilder: (context, error, stack) {
          LogService().error('Image.asset error for digit: ${widget.digit}',
              error: error, stackTrace: stack);
          return Text(
            widget.digit,
            style: TextStyle(
              fontSize: height * 0.6,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}
