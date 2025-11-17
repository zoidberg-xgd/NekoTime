import 'dart:io';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/core/services/theme_service.dart';
import 'package:digital_clock/ui/screens/clock_screen.dart';
import 'package:digital_clock/utils/tray_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = ConfigService();
  final themeService = ThemeService();
  final bool isDesktop =
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  if (isDesktop) {
    await windowManager.ensureInitialized();
    if (Platform.isMacOS) {
      await flutter_acrylic.Window.initialize();
    }
  }

  await configService.init();
  await themeService.init();

  if (isDesktop) {
    final Size initialSize =
        calculateWindowSizeFromConfig(configService.config);

    WindowOptions windowOptions = WindowOptions(
      size: initialSize,
      minimumSize: const Size(200, 80),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (Platform.isMacOS) {
        await flutter_acrylic.Window.makeTitlebarTransparent();
        await flutter_acrylic.Window.enableFullSizeContentView();
        await flutter_acrylic.Window.setWindowBackgroundColorToClear();
        await flutter_acrylic.Window.setEffect(
          effect: flutter_acrylic.WindowEffect.sidebar,
          color: Colors.transparent,
        );
      }
      await windowManager.setAsFrameless(); // 无边框
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
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

class _MyAppState extends State<MyApp> with TrayController<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  BuildContext get trayContext => _navigatorKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    // 延迟并安全地初始化托盘
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          await initTray(widget.configService);
        } catch (e) {
          debugPrint('Failed to init tray COMPLETELY: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      disposeTray(widget.configService);
    }
    super.dispose();
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
