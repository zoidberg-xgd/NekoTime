import 'dart:io';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/models/theme_definition.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/core/services/theme_service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:digital_clock/l10n/app_localizations.dart';

/// 系统托盘控制逻辑（基于 system_tray）。
/// 使用 mixin 混入到 State 类中，集中管理托盘与菜单。
mixin TrayController<T extends StatefulWidget> on State<T> {
  /// 由混入该 mixin 的 State 提供上下文，用于读取 Provider 等。
  BuildContext get trayContext;

  final SystemTray _tray = SystemTray();
  VoidCallback? _configListener;

  Future<void> initTray(ConfigService configService) async {
    try {
      // 初始化托盘，不使用文件图标，直接设置标题为 Emoji
      await _tray.initSystemTray(iconPath: '', toolTip: 'Digital Clock');
      await _tray.setTitle('🕑');
    } catch (e) {
      debugPrint('SystemTray init failed: $e');
      return;
    }

    await _rebuildMenu(configService);

    // 单击或右击都弹出菜单（macOS 左键即可）
    _tray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick ||
          eventName == kSystemTrayEventRightClick) {
        await _tray.popUpContextMenu();
      }
    });

    _configListener = () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _rebuildMenu(configService);
      });
    };
    configService.addListener(_configListener!);
  }

  Future<void> _rebuildMenu(ConfigService configService) async {
    final config = configService.config;
    final l10n = AppLocalizations.of(trayContext)!;
    final themeService = Provider.of<ThemeService>(trayContext, listen: false);
    final themes = themeService.themes;

    String check(bool v) => v ? '✓ ' : '';

    final Menu menu = Menu();
    await menu.buildFrom([
      // 主题
      SubMenu(
        label: l10n.theme,
        children: [
          for (final theme in themes)
            MenuItemLabel(
              label:
                  '${check(config.themeId == theme.id)}${_trayThemeName(l10n, theme)}',
              onClicked: (_) => configService.setTheme(theme.id),
            ),
        ],
      ),
      // 透明度
      SubMenu(label: l10n.opacity, children: [
        for (final v in [0.30, 0.50, 0.70, 0.85, 1.00])
          MenuItemLabel(
            label:
                '${check((config.opacity - v).abs() < 0.01)}${v.toStringAsFixed(2)}',
            onClicked: (_) => configService.setOpacity(v),
          ),
      ]),
      // 缩放
      SubMenu(label: l10n.scale, children: [
        for (final v in [0.75, 1.00, 1.25, 1.50, 2.00])
          MenuItemLabel(
            label:
                '${check((config.scale - v).abs() < 0.01)}${v.toStringAsFixed(2)}x',
            onClicked: (_) => configService.setScale(v),
          ),
      ]),
      MenuItemLabel(
        label: config.showSeconds ? l10n.hideSeconds : l10n.showSeconds,
        onClicked: (_) => configService.toggleShowSeconds(),
      ),
      MenuItemLabel(
        label: config.lockPosition ? l10n.unlockPosition : l10n.lockPosition,
        onClicked: (_) => configService.toggleLockPosition(),
      ),
      SubMenu(label: l10n.layer, children: [
        MenuItemLabel(
          label:
              '${check(config.layer == ClockLayer.desktop)}${l10n.layerDesktop}',
          onClicked: (_) => configService.setLayer(ClockLayer.desktop),
        ),
        MenuItemLabel(
          label:
              '${check(config.layer == ClockLayer.normal)}${l10n.layerNormal}',
          onClicked: (_) => configService.setLayer(ClockLayer.normal),
        ),
        MenuItemLabel(
          label: '${check(config.layer == ClockLayer.top)}${l10n.layerTop}',
          onClicked: (_) => configService.setLayer(ClockLayer.top),
        ),
      ]),
      SubMenu(label: l10n.language, children: [
        MenuItemLabel(
          label: '${check(config.locale == 'en')}${l10n.languageEnglish}',
          onClicked: (_) => configService.setLocale('en'),
        ),
        MenuItemLabel(
          label: '${check(config.locale == 'zh')}${l10n.languageChinese}',
          onClicked: (_) => configService.setLocale('zh'),
        ),
      ]),
      MenuSeparator(),
      MenuItemLabel(
        label: l10n.exit,
        onClicked: (_) async {
          await _tray.destroy();
          exit(0);
        },
      ),
    ]);

    await _tray.setContextMenu(menu);
  }

  Future<void> disposeTray(ConfigService configService) async {
    if (_configListener != null) {
      configService.removeListener(_configListener!);
      _configListener = null;
    }
    await _tray.destroy();
  }

  String _trayThemeName(AppLocalizations l10n, ThemeDefinition theme) {
    return theme.name;
  }
}
