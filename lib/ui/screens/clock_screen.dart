import 'dart:ui';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/models/theme_definition.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/core/services/time_service.dart';
import 'package:digital_clock/core/services/theme_service.dart';
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

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Widget _buildThemeWrapper(
    BuildContext context,
    Widget child,
    ClockConfig config,
    ThemeDefinition theme,
  ) {
    final opacity = config.opacity;
    final padding = EdgeInsets.symmetric(
      horizontal: theme.paddingHorizontal,
      vertical: theme.paddingVertical,
    );

    final backgroundOverlay = theme.backgroundColor?.withOpacity(
      theme.backgroundOpacityMultiplier * opacity,
    );
    final tintOverlay = theme.tintColor?.withOpacity(
      theme.tintOpacityMultiplier * opacity,
    );

    Widget content = Padding(
      padding: padding,
      child: Center(child: child),
    );

    switch (theme.kind) {
      case ThemeKind.transparent:
        return content;
      case ThemeKind.blur:
        return ClipRRect(
          borderRadius: BorderRadius.circular(theme.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: theme.blurSigmaX,
              sigmaY: theme.blurSigmaY,
            ),
            child: Container(
              color: tintOverlay ?? backgroundOverlay ?? Colors.transparent,
              child: content,
            ),
          ),
        );
      case ThemeKind.solid:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.borderRadius),
            color: backgroundOverlay ?? tintOverlay ?? Colors.black,
          ),
          child: content,
        );
    }
  }

  void _updateWindow(ConfigService configService) {
    final config = configService.config;
    final Size desiredSize = calculateWindowSizeFromConfig(config);

    // Fit window to content size
    windowManager.setSize(desiredSize);
    windowManager.setHasShadow(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfigService, ThemeService>(
      builder: (context, configService, themeService, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateWindow(configService);
        });

        Widget clock = StreamBuilder<DateTime>(
          stream: _timeService.timeStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final digits = _timeService.formatTime(snapshot.data!,
                showSeconds: configService.config.showSeconds);
            // ALWAYS use the config from the builder
            return TimeDisplay(
                digits: digits, scale: configService.config.scale);
          },
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) {
              if (!configService.config.lockPosition) {
                windowManager.startDragging();
              }
            },
            child: _buildThemeWrapper(
              context,
              clock,
              configService.config,
              themeService.resolve(configService.config.themeId),
            ),
          ),
        );
      },
    );
  }
}
