import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neko_time/core/services/log_service.dart';
import 'package:path/path.dart' as p;

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
  bool _isExternalFile = false;
  File? _externalFile;
  
  // 智能缓存系统：按主题分组，保留最近使用的主题缓存
  static const int _maxCachedThemes = 3; // 最多缓存 3 个主题
  static final List<String> _recentThemes = []; // 最近使用的主题列表（LRU）
  static final Map<String, Map<String, bool>> _assetExistsCache = {}; // themeKey -> {assetPath -> exists}
  static final Map<String, Map<String, File?>> _externalFileCache = {}; // themeKey -> {cacheKey -> file}

  /// 获取当前主题的缓存 key
  String get _themeKey => '${widget.gifBasePath ?? 'null'}|${widget.assetsBasePath ?? 'null'}';

  /// 更新 LRU 缓存，清理过期主题
  static void _updateLRU(String themeKey) {
    // 移除已存在的（如果有）
    _recentThemes.remove(themeKey);
    // 添加到最前面
    _recentThemes.insert(0, themeKey);
    
    // 清理超出限制的旧主题缓存
    while (_recentThemes.length > _maxCachedThemes) {
      final oldTheme = _recentThemes.removeLast();
      _assetExistsCache.remove(oldTheme);
      _externalFileCache.remove(oldTheme);
    }
  }

  /// 获取当前主题的 asset 缓存
  Map<String, bool> get _currentAssetCache {
    _updateLRU(_themeKey);
    return _assetExistsCache.putIfAbsent(_themeKey, () => {});
  }

  /// 获取当前主题的外部文件缓存
  Map<String, File?> get _currentFileCache {
    return _externalFileCache.putIfAbsent(_themeKey, () => {});
  }

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
        oldWidget.imageFormat != widget.imageFormat ||
        oldWidget.assetsBasePath != widget.assetsBasePath) {
      _checkAssetExists();
    }
  }

  Future<void> _checkAssetExists() async {
    if (widget.digit == ':') {
      if (mounted) {
        setState(() {
          _isCheckingAsset = false;
          _assetExists = false;
          _isExternalFile = false;
        });
      }
      return;
    }

    // 如果没有指定 gifBasePath，直接使用文本显示
    if (widget.gifBasePath == null) {
      if (mounted) {
        setState(() {
          _assetExists = false;
          _isExternalFile = false;
          _isCheckingAsset = false;
        });
      }
      return;
    }

    final imagePath = widget.gifBasePath!;
    final format = widget.imageFormat ?? 'gif';
    final assetPath = '$imagePath/${widget.digit}.$format';

    // 判断是内置资源还是外部文件
    final bool isBuiltinAsset = imagePath.startsWith('assets/') || imagePath.startsWith('themes/');

    // 获取当前主题的缓存
    final assetCache = _currentAssetCache;
    final fileCache = _currentFileCache;

    if (isBuiltinAsset) {
      // 内置资源：检查 AssetBundle
      if (assetCache.containsKey(assetPath)) {
        if (mounted) {
          setState(() {
            _assetExists = assetCache[assetPath]!;
            _isExternalFile = false;
            _isCheckingAsset = false;
          });
        }
        return;
      }

      try {
        await rootBundle.load(assetPath);
        assetCache[assetPath] = true;
        if (mounted) {
          setState(() {
            _assetExists = true;
            _isExternalFile = false;
            _isCheckingAsset = false;
          });
        }
      } catch (e) {
        assetCache[assetPath] = false;
        if (mounted) {
          setState(() {
            _assetExists = false;
            _isExternalFile = false;
            _isCheckingAsset = false;
          });
        }
      }
    } else {
      // 外部文件：检查文件系统
      if (widget.assetsBasePath == null) {
        if (mounted) {
          setState(() {
            _assetExists = false;
            _isExternalFile = false;
            _isCheckingAsset = false;
          });
        }
        return;
      }

      final cacheKey = assetPath; // 简化 key，因为已经按主题分组了
      if (fileCache.containsKey(cacheKey)) {
        final cachedFile = fileCache[cacheKey];
        if (mounted) {
          setState(() {
            _assetExists = cachedFile != null;
            _isExternalFile = cachedFile != null;
            _externalFile = cachedFile;
            _isCheckingAsset = false;
          });
        }
        return;
      }

      // 查找外部文件
      final file = File(p.join(widget.assetsBasePath!, imagePath, '${widget.digit}.$format'));
      if (file.existsSync()) {
        fileCache[cacheKey] = file;
        if (mounted) {
          setState(() {
            _assetExists = true;
            _isExternalFile = true;
            _externalFile = file;
            _isCheckingAsset = false;
          });
        }
      } else {
        fileCache[cacheKey] = null;
        if (mounted) {
          setState(() {
            _assetExists = false;
            _isExternalFile = false;
            _externalFile = null;
            _isCheckingAsset = false;
          });
        }
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

    // 文本后备 widget
    Widget textFallback() => SizedBox(
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

    // 如果资源不存在，直接显示文本
    if (!_assetExists) {
      return textFallback();
    }

    // 资源存在，加载图片
    final imagePath =
        widget.gifBasePath ?? 'themes/builtin/frosted_glass/digits';
    final format = widget.imageFormat ?? 'gif';

    // 根据是否为外部文件选择不同的加载方式
    if (_isExternalFile && _externalFile != null) {
      // 外部文件：使用 Image.file
      return SizedBox(
        width: digitWidth,
        height: height,
        child: Image.file(
          _externalFile!,
          width: digitWidth,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) {
            LogService().error('Image.file error for digit: ${widget.digit}',
                error: error, stackTrace: stack);
            return textFallback();
          },
        ),
      );
    } else {
      // 内置资源：使用 Image.asset
      final assetPath = '$imagePath/${widget.digit}.$format';
      return SizedBox(
        width: digitWidth,
        height: height,
        child: Image.asset(
          assetPath,
          width: digitWidth,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) {
            LogService().error('Image.asset error for digit: ${widget.digit}',
                error: error, stackTrace: stack);
            return textFallback();
          },
        ),
      );
    }
  }
}
