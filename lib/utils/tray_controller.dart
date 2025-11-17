import 'dart:io';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

/// 系统托盘控制逻辑（基于 system_tray）。
/// 使用 mixin 混入到 State 类中，集中管理托盘与菜单。
mixin TrayController {
  /// 由混入该 mixin 的 State 提供上下文，用于读取 Provider 等。
  BuildContext get trayContext;

  final SystemTray _tray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  Future<void> initTray(ConfigService configService) async {
    // 仅标题模式：不设置图标，避免任何图标渲染带来的不确定性
    try {
      await _tray.initSystemTray(toolTip: 'Digital Clock');
      await _tray.setTitle('⏰'); // 始终显示标题作为入口
    } catch (e) {
      debugPrint('SystemTray init failed: $e');
      return;
    }

    // 平台图标设置：
    // - macOS: 尝试 template 单色图标（icon_template.png），失败保留标题模式
    // - Windows/Linux: 使用 24x24 PNG（tray_win.png/tray_linux.png）
    try {
      final tmpDir = await getTemporaryDirectory();
      if (Platform.isMacOS) {
        final bytes = await rootBundle.load('assets/icons/icon_template.png');
        final file = File('${tmpDir.path}/tray_icon_template.png');
        await file.writeAsBytes(bytes.buffer.asUint8List());
        await _tray.setIcon(file.path);
      } else if (Platform.isWindows) {
        final bytes = await rootBundle.load('assets/icons/tray_win.png');
        final file = File('${tmpDir.path}/tray_win.png');
        await file.writeAsBytes(bytes.buffer.asUint8List());
        await _tray.setIcon(file.path);
      } else if (Platform.isLinux) {
        final bytes = await rootBundle.load('assets/icons/tray_linux.png');
        final file = File('${tmpDir.path}/tray_linux.png');
        await file.writeAsBytes(bytes.buffer.asUint8List());
        await _tray.setIcon(file.path);
      }
    } catch (_) {
      // 任何失败都不影响使用：保留“⏰”标题可见
    }

    await _rebuildMenu(configService);

    // 单击或右击都弹出菜单（macOS 左键即可）
    _tray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick || eventName == kSystemTrayEventRightClick) {
        await _tray.popUpContextMenu();
      }
    });
  }

  Future<void> _rebuildMenu(ConfigService configService) async {
    final config = configService.config;

    String check(bool v) => v ? '✓ ' : '';

    final Menu menu = Menu();
    await menu.buildFrom([
      // 主题
      SubMenu(label: 'Theme', children: [
        MenuItemLabel(
          label: '${check(config.themeStyle == ThemeStyle.transparent)}Transparent',
          onClicked: (_) => configService.setThemeStyle(ThemeStyle.transparent),
        ),
        MenuItemLabel(
          label: '${check(config.themeStyle == ThemeStyle.frostedGlass)}Frosted Glass',
          onClicked: (_) => configService.setThemeStyle(ThemeStyle.frostedGlass),
        ),
        MenuItemLabel(
          label: '${check(config.themeStyle == ThemeStyle.aquaGlass)}Aqua Glass',
          onClicked: (_) => configService.setThemeStyle(ThemeStyle.aquaGlass),
        ),
      ]),
      // 透明度
      SubMenu(label: 'Opacity', children: [
        for (final v in [0.30, 0.50, 0.70, 0.85, 1.00])
          MenuItemLabel(
            label: '${check((config.opacity - v).abs() < 0.01)}${v.toStringAsFixed(2)}',
            onClicked: (_) => configService.setOpacity(v),
          ),
      ]),
      // 缩放
      SubMenu(label: 'Scale', children: [
        for (final v in [0.75, 1.00, 1.25, 1.50, 2.00])
          MenuItemLabel(
            label: '${check((config.scale - v).abs() < 0.01)}${v.toStringAsFixed(2)}x',
            onClicked: (_) => configService.setScale(v),
          ),
      ]),
      MenuItemLabel(
        label: config.showSeconds ? 'Hide Seconds' : 'Show Seconds',
        onClicked: (_) => configService.toggleShowSeconds(),
      ),
      MenuItemLabel(
        label: config.lockPosition ? 'Unlock Position' : 'Lock Position',
        onClicked: (_) => configService.toggleLockPosition(),
      ),
      SubMenu(label: 'Layer', children: [
        MenuItemLabel(
          label: '${check(config.layer == ClockLayer.desktop)}Desktop',
          onClicked: (_) => configService.setLayer(ClockLayer.desktop),
        ),
        MenuItemLabel(
          label: '${check(config.layer == ClockLayer.normal)}Normal',
          onClicked: (_) => configService.setLayer(ClockLayer.normal),
        ),
        MenuItemLabel(
          label: '${check(config.layer == ClockLayer.top)}Always on Top',
          onClicked: (_) => configService.setLayer(ClockLayer.top),
        ),
      ]),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (_) async {
          await _tray.destroy();
          await windowManager.destroy();
        },
      ),
    ]);

    await _tray.setContextMenu(menu);
  }
}

