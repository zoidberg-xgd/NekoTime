import 'dart:convert';
import 'dart:io';
import 'package:digital_clock/core/models/clock_config.dart';
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
    // Apply initial window settings from config
    _applyWindowSettings();
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
  void _applyWindowSettings() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      switch (_config.layer) {
        case ClockLayer.desktop:
          // 桌面层：目前 window_manager 不再提供 setAsDesktop，
          // 这里退化为普通窗口且不置顶。
          windowManager.setAlwaysOnTop(false);
          break;
        case ClockLayer.normal:
          windowManager.setAlwaysOnTop(false);
          break;
        case ClockLayer.top:
          windowManager.setAlwaysOnTop(true);
          break;
      }
    }
  }

  // Methods to update specific config values
  void toggleShowSeconds() {
    final newConfig = _config.copyWith(showSeconds: !_config.showSeconds);
    saveConfig(newConfig);
  }

  void setScale(double scale) {
    final newConfig = _config.copyWith(scale: scale);
    saveConfig(newConfig);
  }

  void setOpacity(double opacity) {
    final newConfig = _config.copyWith(opacity: opacity);
    saveConfig(newConfig);
  }

  void setThemeStyle(ThemeStyle style) {
    final newConfig = _config.copyWith(themeStyle: style);
    saveConfig(newConfig);
  }

  void setLayer(ClockLayer layer) {
    final newConfig = _config.copyWith(layer: layer);
    saveConfig(newConfig);
  }

  void toggleLockPosition() {
    final newConfig = _config.copyWith(lockPosition: !_config.lockPosition);
    saveConfig(newConfig);
  }
}
