import 'dart:io';
import 'dart:async';

import 'package:neko_time/core/models/clock_config.dart';
import 'package:neko_time/core/services/config_service.dart';
import 'package:neko_time/core/services/theme_service.dart';
import 'package:neko_time/core/services/log_service.dart';
import 'package:neko_time/ui/screens/clock_screen.dart';
import 'package:neko_time/utils/tray_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志服务
  final logService = LogService();
  await logService.init();
  await logService.info('Application starting...');

  final configService = ConfigService();
  final themeService = ThemeService();
  final bool isDesktop =
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  // 先初始化窗口管理器（必须在最前面）
  if (isDesktop) {
    await windowManager.ensureInitialized();
    // 初始化透明效果库（仅支持 macOS 和 Windows，Linux 使用原生透明）
    if (Platform.isMacOS || Platform.isWindows) {
      try {
        await flutter_acrylic.Window.initialize();
        await logService.info(
            'flutter_acrylic initialized for ${Platform.operatingSystem}');
      } catch (e, stackTrace) {
        await logService.error('Failed to initialize flutter_acrylic',
            error: e, stackTrace: stackTrace);
      }
    }
  }

  try {
    await configService.init();
    await logService.info('ConfigService initialized');
  } catch (e, stackTrace) {
    await logService.error('Failed to initialize ConfigService',
        error: e, stackTrace: stackTrace);
  }

  try {
    await themeService.init();
    await logService.info(
        'ThemeService initialized. Themes loaded: ${themeService.themes.length}');
  } catch (e, stackTrace) {
    await logService.error('Failed to initialize ThemeService',
        error: e, stackTrace: stackTrace);
  }

  if (isDesktop) {
    // 获取当前主题以计算正确的窗口大小
    final theme = themeService.resolve(configService.config.themeId);
    final Size initialSize = calculateWindowSizeFromConfig(
      configService.config,
      digitAspectRatio: theme.digitAspectRatio,
      digitBaseHeight: theme.digitBaseHeight,
      digitSpacing: theme.digitSpacing ?? 2.0,
      paddingHorizontal: theme.paddingHorizontal,
      paddingVertical: theme.paddingVertical,
    );

    // 根据配置决定是否置顶
    bool shouldAlwaysOnTop = configService.config.layer == ClockLayer.top;

    // 检查是否有保存的位置
    bool hasSavedPosition = configService.config.positionX != null &&
        configService.config.positionY != null;

    WindowOptions windowOptions = WindowOptions(
      size: initialSize,
      minimumSize: const Size(200, 80),
      center: !hasSavedPosition, // 如果有保存的位置，则不居中
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: shouldAlwaysOnTop,
    );

    // 先配置窗口属性，再显示
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // 确保窗口大小正确（防止闪烁）
      await windowManager.setSize(initialSize);

      // 恢复位置
      if (hasSavedPosition) {
        await windowManager.setPosition(Offset(
          configService.config.positionX!,
          configService.config.positionY!,
        ));
      }
      
      // 平台特定配置
      if (Platform.isMacOS) {
        // macOS: 使用 Acrylic 实现毛玻璃效果
        await flutter_acrylic.Window.makeTitlebarTransparent();
        await flutter_acrylic.Window.enableFullSizeContentView();
        await flutter_acrylic.Window.setWindowBackgroundColorToClear();
        await flutter_acrylic.Window.setEffect(
          effect: flutter_acrylic.WindowEffect.sidebar,
          color: Colors.transparent,
        );
        // 再次设置大小，因为 acrylic 设置可能影响窗口
        await windowManager.setSize(initialSize);
      } else if (Platform.isWindows) {
        // Windows: 使用 Acrylic 效果
        await flutter_acrylic.Window.setEffect(
          effect: flutter_acrylic.WindowEffect.acrylic,
          color: Colors.transparent,
        );
      } else if (Platform.isLinux) {
        // Linux: 激进的透明窗口配置
        await logService.info('Linux: Configuring aggressive transparency');
        await windowManager.setBackgroundColor(Colors.transparent);
        
        // 尝试移除所有窗口装饰
        try {
          await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
        } catch (e) {
          await logService.error('Failed to set title bar style', error: e);
        }
      }

      // 通用窗口设置（所有平台）
      await windowManager.setAsFrameless();
      await windowManager.setResizable(false);
      
      // Linux 特殊处理：完全禁用阴影和装饰
      if (Platform.isLinux) {
        await windowManager.setHasShadow(false);
        // 先不显示窗口，等待设置完成
        await logService.info('Linux: Applying window settings...');
        
        // 多次设置大小以确保生效
        await windowManager.setSize(initialSize);
        await Future.delayed(const Duration(milliseconds: 50));
        await windowManager.setSize(initialSize);
        
        // 强制最小和最大尺寸相同，防止窗口管理器添加边框
        await windowManager.setMinimumSize(initialSize);
        await windowManager.setMaximumSize(initialSize);
        
        await logService.info('Linux: Window constrained to ${initialSize.width}x${initialSize.height}');
      } else {
        await windowManager.setHasShadow(true);
      }

      // 先设置透明度，再显示窗口
      final savedOpacity = configService.config.opacity.clamp(0.1, 1.0);
      await windowManager.setOpacity(savedOpacity);
      
      // 显示和聚焦窗口
      await windowManager.show();
      await windowManager.focus();
      
      // macOS 需要在 show() 后再次设置透明度，因为 show() 可能会重置它
      if (Platform.isMacOS) {
        await Future.delayed(const Duration(milliseconds: 100));
        await windowManager.setOpacity(savedOpacity);
      }
      await logService.info('Applied saved opacity: $savedOpacity');
      
      // Linux 最后确认：再次设置大小
      if (Platform.isLinux) {
        await Future.delayed(const Duration(milliseconds: 200));
        await windowManager.setSize(initialSize);
        await windowManager.setAlignment(Alignment.center);
        await logService.info('Linux: Final window size applied');
      }

      await logService
          .info('Window initialized and shown on ${Platform.operatingSystem}');
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: configService),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: MyApp(configService: configService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final ConfigService configService;

  const MyApp({super.key, required this.configService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayController<MyApp>, WindowListener {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Timer? _savePositionTimer;

  @override
  BuildContext get trayContext => _navigatorKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    
    // 延迟并安全地初始化托盘
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          await initTray(widget.configService);
          await LogService().info('System tray initialized');
        } catch (e, stackTrace) {
          await LogService()
              .error('Failed to init tray', error: e, stackTrace: stackTrace);
        }
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _savePositionTimer?.cancel();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      disposeTray(widget.configService);
    }
    super.dispose();
  }

  @override
  void onWindowMove() {
    _debounceSavePosition();
  }

  void _debounceSavePosition() {
    if (_savePositionTimer?.isActive ?? false) _savePositionTimer!.cancel();
    _savePositionTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final position = await windowManager.getPosition();
        await widget.configService.savePosition(position);
      } catch (e) {
        // Ignore errors during window drag/move
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          color: Colors.transparent,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.transparent,
          ),
          locale: Locale(configService.config.locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClockScreen(),
        );
      },
    );
  }
}
