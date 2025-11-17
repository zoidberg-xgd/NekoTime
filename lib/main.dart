import 'dart:io';

import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/ui/screens/clock_screen.dart';
import 'package:digital_clock/utils/tray_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 仅在桌面平台上初始化窗口管理器
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    // 设置窗口选项
    WindowOptions windowOptions = const WindowOptions(
      // 初始大小，可以根据 GIF 尺寸调整
      size: Size(600, 180),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // 这里不再调用 setAsDesktop，初始为普通窗口，
      // 具体层级由配置服务中的 ClockLayer 决定。
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 初始化配置服务
  final configService = ConfigService();
  await configService.init();

  runApp(MyApp(configService: configService));
}

class MyApp extends StatefulWidget {
  final ConfigService configService;

  const MyApp({super.key, required this.configService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayController {
  @override
  BuildContext get trayContext => context;

  @override
  void initState() {
    super.initState();
    // 重新启用托盘（包含安全保护与资源解包），三端均可用
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await initTray(widget.configService);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.configService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ClockScreen(),
      ),
    );
  }
}
