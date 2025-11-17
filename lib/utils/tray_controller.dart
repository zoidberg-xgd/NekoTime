import 'dart:io';

import 'package:neko_time/core/models/clock_config.dart';
import 'package:neko_time/core/models/theme_definition.dart';
import 'package:neko_time/core/services/config_service.dart';
import 'package:neko_time/core/services/theme_service.dart';
import 'package:neko_time/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:neko_time/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

/// 系统托盘控制逻辑（基于 system_tray）。
/// 使用 mixin 混入到 State 类中，集中管理托盘与菜单。
mixin TrayController<T extends StatefulWidget> on State<T> {
  /// 由混入该 mixin 的 State 提供上下文，用于读取 Provider 等。
  BuildContext get trayContext;

  final SystemTray _tray = SystemTray();
  VoidCallback? _configListener;

  /// 获取托盘图标路径（Windows 和 Linux 需要实际图标文件）
  Future<String> _getTrayIconPath() async {
    if (Platform.isWindows) {
      // Windows 必须使用实际的 .ico 文件
      try {
        final tempDir = await getTemporaryDirectory();
        final iconPath = path.join(tempDir.path, 'tray_icon.ico');
        final iconFile = File(iconPath);
        
        // 如果文件不存在，从 assets 复制
        if (!iconFile.existsSync()) {
          final byteData = await rootBundle.load('assets/icons/tray_icon.ico');
          await iconFile.writeAsBytes(byteData.buffer.asUint8List());
          LogService().info('Windows tray icon copied to: $iconPath');
        }
        
        return iconPath;
      } catch (e) {
        LogService().error('Failed to load Windows tray icon: $e');
        return '';
      }
    } else if (Platform.isLinux) {
      // Linux 也需要实际的图标文件（某些桌面环境不支持 Emoji）
      try {
        final tempDir = await getTemporaryDirectory();
        final iconPath = path.join(tempDir.path, 'tray_icon.png');
        final iconFile = File(iconPath);
        
        // 如果文件不存在，从 assets 复制（使用 app_icon_source.png）
        if (!iconFile.existsSync()) {
          final byteData = await rootBundle.load('assets/icons/app_icon_source.png');
          await iconFile.writeAsBytes(byteData.buffer.asUint8List());
          LogService().info('Linux tray icon copied to: $iconPath');
        }
        
        return iconPath;
      } catch (e) {
        LogService().error('Failed to load Linux tray icon: $e');
        return '';
      }
    }
    // macOS 可以使用空路径 + Emoji
    return '';
  }

  Future<void> initTray(ConfigService configService) async {
    try {
      // 获取适合平台的图标路径
      final iconPath = await _getTrayIconPath();
      
      // 初始化托盘
      await _tray.initSystemTray(
        iconPath: iconPath,
        toolTip: 'NekoTime',
      );

      // 只在 macOS 上设置 Emoji 标题（Linux 可能不支持）
      if (Platform.isMacOS) {
        await _tray.setTitle('🕐');
      }

      // 确保托盘图标可见
      await _tray.setSystemTrayInfo(
        title: Platform.isMacOS ? '🕐' : '',
        toolTip: 'NekoTime - 双击窗口隐藏，右键菜单显示',
      );
      
      LogService().info('System tray initialized successfully');
    } catch (e) {
      LogService().error('SystemTray init failed: $e');
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
        label: config.lockPosition ? l10n.unlockPosition : l10n.lockPosition,
        onClicked: (_) => configService.toggleLockPosition(),
      ),
      MenuItemLabel(
        label: l10n.hideShow,
        onClicked: (_) async {
          // 使用透明度控制而不是hide/show，避免托盘消失
          final currentOpacity = await windowManager.getOpacity();
          if (currentOpacity > 0.01) {
            // 当前可见，隐藏它
            await windowManager.setOpacity(0.0);
            LogService().info('Window hidden via tray menu (opacity=0)');
          } else {
            // 当前隐藏，恢复用户配置的透明度
            final configOpacity = configService.config.opacity.clamp(0.1, 1.0);
            await windowManager.setOpacity(configOpacity);
            await windowManager.show();
            await windowManager.focus();
            LogService().info('Window shown via tray menu (opacity=$configOpacity)');
          }
        },
      ),
      SubMenu(label: l10n.layer, children: [
        MenuItemLabel(
          label:
              '${check(config.layer == ClockLayer.desktop)}${l10n.layerDesktop}',
          onClicked: (_) => configService.setLayer(ClockLayer.desktop),
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
