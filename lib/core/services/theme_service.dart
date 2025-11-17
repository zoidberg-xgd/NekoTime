import 'dart:convert';
import 'dart:io';

import 'package:digital_clock/core/models/theme_definition.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThemeService extends ChangeNotifier {
  final Map<String, ThemeDefinition> _themes = {};
  Directory? _themesDirectory;

  static List<ThemeDefinition> get _builtinThemes => const [
        ThemeDefinition(
          id: ThemeDefinition.defaultThemeId,
          name: 'Transparent',
          kind: ThemeKind.transparent,
          paddingHorizontal: 16,
          paddingVertical: 8,
        ),
        ThemeDefinition(
          id: 'frosted_glass',
          name: 'Frosted Glass',
          kind: ThemeKind.blur,
          borderRadius: 16,
          paddingHorizontal: 16,
          paddingVertical: 8,
          blurSigmaX: 16,
          blurSigmaY: 16,
          tintColor: Color(0xFF9E9E9E),
          tintOpacityMultiplier: 0.15,
        ),
        ThemeDefinition(
          id: 'aqua_glass',
          name: 'Aqua Glass',
          kind: ThemeKind.blur,
          borderRadius: 16,
          paddingHorizontal: 16,
          paddingVertical: 8,
          blurSigmaX: 16,
          blurSigmaY: 16,
          tintColor: Color(0xFF007AFF),
          tintOpacityMultiplier: 0.2,
        ),
      ];

  Future<void> init() async {
    _themes.clear();
    for (final theme in _builtinThemes) {
      _themes[theme.id] = theme;
    }
    final dir = await _ensureThemesDirectory();
    await _loadCustomThemes(dir);
    await _ensureSampleTheme(dir);
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
    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.json'));
    for (final file in files) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        final theme = ThemeDefinition.fromJson(data);
        _themes[theme.id] = theme;
      } catch (e) {
        debugPrint('Failed to load theme ${file.path}: $e');
      }
    }
  }

  Future<void> _ensureSampleTheme(Directory dir) async {
    final entries = dir.listSync();
    if (entries.isNotEmpty) return;
    final sample = ThemeDefinition(
      id: 'sample_glow',
      name: 'Sample Neon',
      kind: ThemeKind.solid,
      borderRadius: 20,
      paddingHorizontal: 24,
      paddingVertical: 12,
      tintColor: const Color(0xFF00C2FF),
      tintOpacityMultiplier: 0.12,
      backgroundColor: const Color(0xFF0A0A0A),
      backgroundOpacityMultiplier: 0.8,
    );
    final file = File(p.join(dir.path, 'sample_neon.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(
      sample.toJson(),
    ));
  }
}

