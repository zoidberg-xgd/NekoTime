import 'dart:io';

import 'dart:ui';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/core/services/time_service.dart';
import 'package:digital_clock/ui/widgets/time_display.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with WindowListener {
  final _timeService = TimeService();

  Widget _wrapWithTheme(Widget child, ConfigService configService) {
    final config = configService.config;
    switch (config.themeStyle) {
      case ThemeStyle.transparent:
        return Center(child: child);
      case ThemeStyle.frostedGlass:
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white.withOpacity(0.08 + 0.5 * config.opacity),
                child: child,
              ),
            ),
          ),
        );
      case ThemeStyle.aquaGlass:
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF80D0FF).withOpacity(0.18 * config.opacity),
                      const Color(0xFFB0E0FF).withOpacity(0.28 * config.opacity),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来监听配置变化
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        final config = configService.config;

        Widget clock = StreamBuilder<DateTime>(
          stream: _timeService.timeStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final digits = _timeService.formatTime(snapshot.data!, showSeconds: config.showSeconds);
            // 基础逻辑尺寸，配合 FittedBox 等比缩放
            return FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 600 * config.scale,
                height: 180 * config.scale,
                child: Center(
                  child: TimeDisplay(digits: digits, scale: 1.0),
                ),
              ),
            );
          },
        );

        Widget content = _wrapWithTheme(clock, configService);

        // 计算期望窗口尺寸（内容 + 主题留白），并在帧结束时自动贴合
        final double baseW = 600 * config.scale;
        final double baseH = 180 * config.scale;
        final double padH = config.themeStyle == ThemeStyle.transparent ? 0 : 32; // 左右总和
        final double padV = config.themeStyle == ThemeStyle.transparent ? 0 : 16; // 上下总和
        final Size desiredSize = Size(baseW + padH, baseH + padV);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 自动贴合窗口尺寸并保持中心位置
          try {
            final current = await windowManager.getSize();
            if ((current.width - desiredSize.width).abs() > 1 || (current.height - desiredSize.height).abs() > 1) {
              final pos = await windowManager.getPosition();
              final centerX = pos.dx + current.width / 2;
              final centerY = pos.dy + current.height / 2;
              await windowManager.setSize(desiredSize);
              await windowManager.setPosition(Offset(centerX - desiredSize.width / 2, centerY - desiredSize.height / 2));
            }
          } catch (_) {}
        });

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            // 拖动窗口
            onPanStart: (details) {
              if (!config.lockPosition && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
                windowManager.startDragging();
              }
            },
            onSecondaryTap: () {}, // 设置全部放在托盘菜单，不弹窗
            child: content,
          ),
        );
      },
    );
  }
}
