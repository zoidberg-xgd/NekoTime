import 'dart:convert';
import 'dart:io';
import 'package:neko_time/core/models/clock_config.dart';
import 'package:neko_time/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class ConfigService extends ChangeNotifier {
  late SharedPreferences _prefs;
  late ClockConfig _config;

  ClockConfig get config => _config;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadConfig();
  }

  void _loadConfig() {
    final String? configJson = _prefs.getString('clock_config');
    if (configJson != null) {
      _config = ClockConfig.fromJson(jsonDecode(configJson));
    } else {
      _config = ClockConfig();
    }
    // Note: Do NOT apply window settings here - windowManager may not be ready yet.
    // Window settings are applied in main.dart after waitUntilReadyToShow().
    notifyListeners();
  }

  Future<void> saveConfig(ClockConfig newConfig) async {
    _config = newConfig;
    final String configJson = jsonEncode(_config.toJson());
    await _prefs.setString('clock_config', configJson);
    _applyWindowSettings();
    notifyListeners();
  }

  // Helper to apply window settings based on current config
  Future<void> _applyWindowSettings() async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      bool isAlwaysOnTop = _config.layer == ClockLayer.top;
      await windowManager.setAlwaysOnTop(isAlwaysOnTop);
      await windowManager.setOpacity(_config.opacity.clamp(0.1, 1.0));
    }
  }

  // Methods to update specific config values
  Future<void> setScale(double scale) async {
    final newConfig = _config.copyWith(scale: scale);
    await saveConfig(newConfig);
  }

  Future<void> setOpacity(double opacity) async {
    final newConfig = _config.copyWith(opacity: opacity);
    await saveConfig(newConfig);
  }

  Future<void> setTheme(String themeId) async {
    LogService().info('Theme changed from "${_config.themeId}" to "$themeId"');
    final newConfig = _config.copyWith(themeId: themeId);
    await saveConfig(newConfig);
  }

  Future<void> setLayer(ClockLayer layer) async {
    final newConfig = _config.copyWith(layer: layer);
    await saveConfig(newConfig);
  }

  Future<void> toggleLockPosition() async {
    final newConfig = _config.copyWith(lockPosition: !_config.lockPosition);
    await saveConfig(newConfig);
  }

  Future<void> setLocale(String locale) async {
    final newConfig = _config.copyWith(locale: locale);
    await saveConfig(newConfig);
  }

  Future<void> savePosition(Offset position) async {
    final newConfig = _config.copyWith(
      positionX: position.dx,
      positionY: position.dy,
    );
    // Don't call saveConfig because it calls notifyListeners() and _applyWindowSettings
    // which might cause loops or unnecessary updates during drag
    _config = newConfig;
    final String configJson = jsonEncode(_config.toJson());
    await _prefs.setString('clock_config', configJson);
    // No notifyListeners needed for position updates as they are local to the window
  }
}
