import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:neko_time/core/models/theme_definition.dart';
import 'package:neko_time/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThemeService extends ChangeNotifier {
  final Map<String, ThemeDefinition> _themes = {};
  Directory? _themesDirectory;
  final Set<String> _fontLoadedForTheme = {};

  Future<void> init() async {
    _themes.clear();

    // 首先添加内置主题（硬编码，确保始终可用）
    _themes[ThemeDefinition.defaultThemeId] = await _createBuiltinTheme();
    LogService().info('Loaded builtin theme: Frosted Glass');

    // 然后从应用支持目录加载用户主题
    final dir = await _ensureThemesDirectory();

    // 首次启动时，复制示例主题到应用支持目录
    await _installExampleThemesIfNeeded(dir);

    await _loadCustomThemes(dir);

    LogService().info('Total themes loaded: ${_themes.length}');
    notifyListeners();
  }

  Future<void> _installExampleThemesIfNeeded(Directory themesDir) async {
    // 检查是否已安装示例主题（通过检查标记文件）
    final markerFile = File(p.join(themesDir.path, '.examples_installed_v2'));
    if (await markerFile.exists()) {
      LogService().debug('Example themes already installed');
      return;
    }

    LogService().info('Installing example themes from assets...');
    
    try {
      // 复制 example_mod 主题
      final exampleModDir = Directory(p.join(themesDir.path, 'example_mod'));
      if (!await exampleModDir.exists()) {
        await exampleModDir.create(recursive: true);
      }
      
      // 复制主题配置文件
      final themeJsonAsset = await rootBundle.loadString('themes/example_mod/theme.json');
      await File(p.join(exampleModDir.path, 'theme.json')).writeAsString(themeJsonAsset);
      
      // 复制数字 GIF
      final digitsDir = Directory(p.join(exampleModDir.path, 'digits'));
      if (!await digitsDir.exists()) {
        await digitsDir.create(recursive: true);
      }
      
      for (int i = 0; i <= 9; i++) {
        final assetPath = 'themes/example_mod/digits/$i.gif';
        final digitBytes = await rootBundle.load(assetPath);
        await File(p.join(digitsDir.path, '$i.gif'))
            .writeAsBytes(digitBytes.buffer.asUint8List());
      }
      
      LogService().info('Example theme installed successfully: example_mod');
      
      // 创建标记文件
      await markerFile.writeAsString('v2');
      LogService().info('Example themes installation completed');
    } catch (e, stackTrace) {
      LogService().error('Failed to install example themes', 
          error: e, stackTrace: stackTrace);
    }
  }

  Future<void> reload() async {
    _themes.clear();

    // 重新加载内置主题
    _themes[ThemeDefinition.defaultThemeId] = await _createBuiltinTheme();
    LogService().info('Reloaded builtin theme: Frosted Glass');

    // 加载用户主题
    final dir = await _ensureThemesDirectory();
    await _loadCustomThemes(dir);

    LogService().info('Total themes after reload: ${_themes.length}');
    notifyListeners();
  }

  List<ThemeDefinition> get themes {
    final list = _themes.values.toList();
    // 排序：内置主题优先，然后按名称排序
    list.sort((a, b) {
      // 内置主题始终排在最前
      if (a.id == ThemeDefinition.defaultThemeId) return -1;
      if (b.id == ThemeDefinition.defaultThemeId) return 1;
      // 其他主题按名称排序
      return a.name.compareTo(b.name);
    });
    return list;
  }

  ThemeDefinition resolve(String themeId) {
    if (_themes.isEmpty) {
      LogService().error('No themes loaded! Creating fallback theme.');
      return _createFallbackTheme();
    }
    return _themes[themeId] ??
        _themes[ThemeDefinition.defaultThemeId] ??
        _themes.values.first;
  }

  Future<ThemeDefinition> _createBuiltinTheme() async {
    const theme = ThemeDefinition(
      id: ThemeDefinition.defaultThemeId,
      name: 'Frosted Glass',
      kind: ThemeKind.blur,
      borderRadius: 16,
      paddingHorizontal: 12,
      paddingVertical: 8,
      blurSigmaX: 16,
      blurSigmaY: 16,
      tintColor: Color(0xFF9E9E9E),
      backgroundOpacityMultiplier: 0.3,
      tintOpacityMultiplier: 0.15,
      digitGifPath: 'themes/builtin/frosted_glass/digits',
      digitImageFormat: 'gif',
      digitSpacing: 2,
    );
    // Auto-detect dimensions from first digit image (builtin theme has no manual override)
    final dimensions = await _detectDigitDimensions(theme);
    if (dimensions != null) {
      final (aspectRatio, baseHeight) = dimensions;
      return theme.copyWith(digitAspectRatio: aspectRatio, digitBaseHeight: baseHeight);
    }
    return theme;
  }

  /// Ensure theme has digitAspectRatio and digitBaseHeight set.
  /// If manually specified in theme.json, use that value.
  /// Otherwise, auto-detect from first digit image.
  Future<ThemeDefinition> _ensureDigitDimensions(ThemeDefinition theme) async {
    if (theme.digitAspectRatio != null && theme.digitBaseHeight != null) {
      // Both manually specified - use as-is
      LogService().debug('Using manual digit dimensions for ${theme.id}: '
          'aspectRatio=${theme.digitAspectRatio}, baseHeight=${theme.digitBaseHeight}');
      return theme;
    }
    // Auto-detect from first digit image
    final dimensions = await _detectDigitDimensions(theme);
    if (dimensions != null) {
      final (aspectRatio, baseHeight) = dimensions;
      LogService().debug('Auto-detected digit dimensions for ${theme.id}: '
          'aspectRatio=$aspectRatio, baseHeight=$baseHeight');
      return theme.copyWith(
        digitAspectRatio: theme.digitAspectRatio ?? aspectRatio,
        digitBaseHeight: theme.digitBaseHeight ?? baseHeight,
      );
    }
    return theme;
  }

  /// Detect digit dimensions from the first digit image (0.gif/png/etc)
  /// Returns (aspectRatio, baseHeight) or null if detection fails
  Future<(double, double)?> _detectDigitDimensions(ThemeDefinition theme) async {
    try {
      final gifPath = theme.digitGifPath;
      final format = theme.digitImageFormat ?? 'gif';
      
      if (gifPath == null) return null;
      
      Uint8List? imageBytes;
      
      // Check if it's a bundled asset or external file
      if (gifPath.startsWith('themes/') || gifPath.startsWith('assets/')) {
        // Bundled asset
        final assetPath = '$gifPath/0.$format';
        try {
          final data = await rootBundle.load(assetPath);
          imageBytes = data.buffer.asUint8List();
        } catch (e) {
          LogService().debug('Could not load bundled asset: $assetPath');
          return null;
        }
      } else if (theme.assetsBasePath != null) {
        // External file
        final filePath = p.join(theme.assetsBasePath!, gifPath, '0.$format');
        final file = File(filePath);
        if (await file.exists()) {
          imageBytes = await file.readAsBytes();
        } else {
          LogService().debug('Digit image not found: $filePath');
          return null;
        }
      }
      
      if (imageBytes == null) return null;
      
      // Decode image to get dimensions
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final width = image.width.toDouble();
      final height = image.height.toDouble();
      
      if (height <= 0) return null;
      
      final aspectRatio = width / height;
      LogService().debug('Detected digit dimensions for ${theme.id}: '
          'aspectRatio=$aspectRatio (${width.toInt()}x${height.toInt()})');
      
      return (aspectRatio, height);
    } catch (e, stackTrace) {
      LogService().error('Failed to detect digit dimensions for ${theme.id}',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  ThemeDefinition _createFallbackTheme() {
    return const ThemeDefinition(
      id: 'fallback',
      name: 'Fallback',
      kind: ThemeKind.transparent,
      borderRadius: 12,
      paddingHorizontal: 4,
      paddingVertical: 2,
      blurSigmaX: 0,
      blurSigmaY: 0,
      backgroundOpacityMultiplier: 0.0,
      tintOpacityMultiplier: 0.0,
      digitSpacing: 0,
    );
  }

  String? get themesDirectoryPath => _themesDirectory?.path;

  Future<Directory> _ensureThemesDirectory() async {
    if (_themesDirectory != null) return _themesDirectory!;
    final supportDir = await getApplicationSupportDirectory();
    final themesDir = Directory(p.join(supportDir.path, 'themes'));
    if (!await themesDir.exists()) {
      await themesDir.create(recursive: true);
    }
    _themesDirectory = themesDir;
    return themesDir;
  }

  Future<void> _loadCustomThemes(Directory dir) async {
    final entries = dir.listSync();
    LogService().info('Loading custom themes from: ${dir.path}');

    // 1) Theme packages: subdirectory with theme.json
    for (final entry in entries.whereType<Directory>()) {
      final manifest = File(p.join(entry.path, 'theme.json'));
      if (await manifest.exists()) {
        try {
          final content = await manifest.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          var theme = ThemeDefinition.fromJson(data)
              .copyWith(assetsBasePath: entry.path);
          // Use manual dimensions from JSON, or auto-detect from image
          theme = await _ensureDigitDimensions(theme);
          _themes[theme.id] = theme;
          LogService().info(
              'Loaded theme package: ${theme.name} (${theme.id}) from ${entry.path}');
          LogService().debug('  - digitGifPath: ${theme.digitGifPath}');
          LogService().debug('  - digitImageFormat: ${theme.digitImageFormat}');
          LogService().debug('  - assetsBasePath: ${theme.assetsBasePath}');
          LogService().debug('  - digitAspectRatio: ${theme.digitAspectRatio}');
        } catch (e, stackTrace) {
          LogService().error('Failed to load theme package ${entry.path}',
              error: e, stackTrace: stackTrace);
        }
      }
    }

    // 2) Legacy flat JSON files inside themes directory
    for (final file in entries.whereType<File>()) {
      if (!file.path.toLowerCase().endsWith('.json')) continue;
      // skip package manifest already loaded
      if (p.basename(file.path).toLowerCase() == 'theme.json') continue;
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        var theme = ThemeDefinition.fromJson(data)
            .copyWith(assetsBasePath: file.parent.path);
        // Use manual dimensions from JSON, or auto-detect from image
        theme = await _ensureDigitDimensions(theme);
        _themes[theme.id] = theme;
        LogService().info(
            'Loaded legacy theme: ${theme.name} (${theme.id}) from ${file.path}');
      } catch (e, stackTrace) {
        LogService().error('Failed to load theme ${file.path}',
            error: e, stackTrace: stackTrace);
      }
    }

    LogService().info('Total themes loaded: ${_themes.length}');
  }

  Future<void> ensureFontsLoaded(ThemeDefinition theme) async {
    if (theme.fontFamily == null ||
        theme.fontFiles == null ||
        theme.fontFiles!.isEmpty) return;
    final cacheKey = '${theme.id}:${theme.fontFamily}';
    if (_fontLoadedForTheme.contains(cacheKey)) {
      LogService().debug('Font already loaded for theme: ${theme.id}');
      return;
    }
    if (theme.assetsBasePath == null) return;

    LogService().info('Loading fonts for theme: ${theme.name} (${theme.id})');
    final loader = FontLoader(theme.fontFamily!);
    for (final rel in theme.fontFiles!) {
      try {
        final file = File(p.join(theme.assetsBasePath!, rel));
        final bytes = await file.readAsBytes();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
        LogService().debug('Font file loaded: $rel');
      } catch (e, stackTrace) {
        LogService().error('Failed to load font $rel for theme ${theme.id}',
            error: e, stackTrace: stackTrace);
      }
    }
    try {
      await loader.load();
      _fontLoadedForTheme.add(cacheKey);
      LogService().info('Fonts successfully loaded for theme: ${theme.id}');
    } catch (e, stackTrace) {
      LogService().error('FontLoader load failed for theme ${theme.id}',
          error: e, stackTrace: stackTrace);
    }
  }
}
