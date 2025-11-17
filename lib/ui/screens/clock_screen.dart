import 'dart:ui';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/models/theme_definition.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/core/services/log_service.dart';
import 'package:digital_clock/core/services/time_service.dart';
import 'package:digital_clock/core/services/theme_service.dart';
import 'package:digital_clock/ui/widgets/time_display.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with WindowListener {
  final _timeService = TimeService();
  String? _lastLoadedThemeId;

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
  
  void _loadThemeFontsIfNeeded(ThemeService themeService, String themeId) {
    if (_lastLoadedThemeId != themeId) {
      _lastLoadedThemeId = themeId;
      final theme = themeService.resolve(themeId);
      LogService().info('Loading theme: ${theme.name} (${theme.id})');
      LogService().debug('Theme config: digitGifPath=${theme.digitGifPath}, format=${theme.digitImageFormat}, assetsBase=${theme.assetsBasePath}');
      themeService.ensureFontsLoaded(theme);
    }
  }

  Widget _buildThemeWrapper(
    BuildContext context,
    Widget child,
    ClockConfig config,
    ThemeDefinition theme,
  ) {
    final opacity = config.opacity;
    EdgeInsets padding;
    switch (theme.paddingPreset) {
      case 'none':
        padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0);
        break;
      case 'compact':
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
      case 'cozy':
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
      case 'comfortable':
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        break;
      default:
        padding = EdgeInsets.symmetric(
          horizontal: theme.paddingHorizontal,
          vertical: theme.paddingVertical,
        );
    }

    final backgroundOverlay = theme.backgroundColor?.withOpacity(
      theme.backgroundOpacityMultiplier * opacity,
    );
    final tintOverlay = theme.tintColor?.withOpacity(
      theme.tintOpacityMultiplier * opacity,
    );

    Alignment align;
    switch (theme.alignment) {
      case LayoutAlignment.left:
        align = Alignment.centerLeft;
        break;
      case LayoutAlignment.right:
        align = Alignment.centerRight;
        break;
      case LayoutAlignment.center:
      default:
        align = Alignment.center;
    }

    Widget content = Padding(
      padding: padding,
      child: Align(alignment: align, child: child),
    );

    DecorationImage? bgImage;
    DecorationImage? overlayImage;
    if (theme.backgroundImagePath != null && theme.assetsBasePath != null) {
      final file = File(p.join(theme.assetsBasePath!, theme.backgroundImagePath!));
      if (file.existsSync()) {
        bgImage = DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
        );
      }
    }
    if (theme.overlayImagePath != null && theme.assetsBasePath != null) {
      final file = File(p.join(theme.assetsBasePath!, theme.overlayImagePath!));
      if (file.existsSync()) {
        overlayImage = DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
        );
      }
    }

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
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color:
                        (tintOverlay ?? backgroundOverlay) ?? Colors.transparent,
                    image: bgImage,
                  ),
                ),
                if (overlayImage != null)
                  Opacity(
                    opacity: (theme.overlayOpacityMultiplier * opacity)
                        .clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(image: overlayImage),
                    ),
                  ),
                content,
              ],
            ),
          ),
        );
      case ThemeKind.solid:
        return ClipRRect(
          borderRadius: BorderRadius.circular(theme.borderRadius),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: (backgroundOverlay ?? tintOverlay) ?? Colors.black,
                  image: bgImage,
                ),
              ),
              if (overlayImage != null)
                Opacity(
                  opacity:
                      (theme.overlayOpacityMultiplier * opacity).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(image: overlayImage),
                  ),
                ),
              content,
            ],
          ),
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

        // 只在主题切换时加载字体和记录日志
        _loadThemeFontsIfNeeded(themeService, configService.config.themeId);
        
        final theme = themeService.resolve(configService.config.themeId);

        Widget clock = StreamBuilder<DateTime>(
          key: const ValueKey('time_stream_builder'), // 添加稳定key防止重建
          stream: _timeService.timeStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final digits = _timeService.formatTime(snapshot.data!,
                showSeconds: configService.config.showSeconds);
            // ALWAYS use the config from the builder
            final safeScale = configService.config.scale.clamp(0.5, 3.0);
            return TimeDisplay(
              digits: digits,
              scale: safeScale,
              digitSpacing: theme.digitSpacing ?? 0.0,
              fontFamily: theme.fontFamily,
              gifBasePath: theme.digitGifPath,
              imageFormat: theme.digitImageFormat,
              assetsBasePath: theme.assetsBasePath,
            );
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
              theme,
            ),
          ),
        );
      },
    );
  }
}
