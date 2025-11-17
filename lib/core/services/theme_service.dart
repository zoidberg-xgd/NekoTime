import 'dart:convert';
import 'dart:io';

import 'package:digital_clock/core/models/theme_definition.dart';
import 'package:digital_clock/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThemeService extends ChangeNotifier {
  final Map<String, ThemeDefinition> _themes = {};
  Directory? _themesDirectory;
  final Set<String> _fontLoadedForTheme = {};

  static List<ThemeDefinition> get _builtinThemes => const [
        ThemeDefinition(
          id: ThemeDefinition.defaultThemeId,
          name: 'Frosted Glass',
          kind: ThemeKind.blur,
          borderRadius: 12,
          paddingHorizontal: 12,
          paddingVertical: 6,
          blurSigmaX: 16,
          blurSigmaY: 16,
          tintColor: Color(0xFF9E9E9E),
          tintOpacityMultiplier: 0.15,
          digitGifPath: 'assets/gif', // 使用应用内置的数字图片资源
          digitImageFormat: 'gif', // 默认使用 GIF 格式
        ),
      ];

  Future<void> init() async {
    _themes.clear();
    for (final theme in _builtinThemes) {
      _themes[theme.id] = theme;
    }
    final dir = await _ensureThemesDirectory();
    await _loadCustomThemes(dir);
    notifyListeners();
  }

  Future<void> reload() async {
    final dir = await _ensureThemesDirectory();
    _themes
      ..clear()
      ..addEntries(_builtinThemes.map((t) => MapEntry(t.id, t)));
    await _loadCustomThemes(dir);
    notifyListeners();
  }

  List<ThemeDefinition> get themes {
    final list = _themes.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  ThemeDefinition resolve(String themeId) {
    return _themes[themeId] ??
        _themes[ThemeDefinition.defaultThemeId] ??
        _builtinThemes.first;
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
          _themes[theme.id] = theme;
          LogService().info('Loaded theme package: ${theme.name} (${theme.id}) from ${entry.path}');
          LogService().debug('  - digitGifPath: ${theme.digitGifPath}');
          LogService().debug('  - digitImageFormat: ${theme.digitImageFormat}');
          LogService().debug('  - assetsBasePath: ${theme.assetsBasePath}');
        } catch (e, stackTrace) {
          LogService().error('Failed to load theme package ${entry.path}', error: e, stackTrace: stackTrace);
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
        _themes[theme.id] = theme;
        LogService().info('Loaded legacy theme: ${theme.name} (${theme.id}) from ${file.path}');
      } catch (e, stackTrace) {
        LogService().error('Failed to load theme ${file.path}', error: e, stackTrace: stackTrace);
      }
    }
    
    LogService().info('Total themes loaded: ${_themes.length}');
  }

  Future<void> ensureFontsLoaded(ThemeDefinition theme) async {
    if (theme.fontFamily == null || theme.fontFiles == null || theme.fontFiles!.isEmpty) return;
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
        LogService().error('Failed to load font $rel for theme ${theme.id}', error: e, stackTrace: stackTrace);
      }
    }
    try {
      await loader.load();
      _fontLoadedForTheme.add(cacheKey);
      LogService().info('Fonts successfully loaded for theme: ${theme.id}');
    } catch (e, stackTrace) {
      LogService().error('FontLoader load failed for theme ${theme.id}', error: e, stackTrace: stackTrace);
    }
  }
}
