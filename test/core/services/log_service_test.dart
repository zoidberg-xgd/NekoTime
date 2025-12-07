import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/core/services/log_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogService', () {
    late LogService logService;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('neko_time_log_test_');

      // Mock path_provider
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return tempDir.path;
        }
        return null;
      });

      // Reset singleton
      logService = LogService();
      logService.reset();
      
      await logService.init();
    });

    tearDown(() async {
      await logService.clearLogs();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('init creates log directory and file', () async {
      await logService.init();
      final logPath = await logService.getLogFilePath();
      expect(logPath, isNotNull);
      expect(File(logPath!).parent.existsSync(), isTrue);
    });

    test('writes info log', () async {
      await logService.info('Test info message');
      final content = await logService.readLogs();
      expect(content, contains('[INFO] Test info message'));
    });

    test('writes error log with stacktrace', () async {
      try {
        throw Exception('Test error');
      } catch (e, s) {
        await logService.error('Test error message', error: e, stackTrace: s);
      }
      
      final content = await logService.readLogs();
      expect(content, contains('[ERROR] Test error message'));
      expect(content, contains('Exception: Test error'));
    });
    
    test('clearLogs removes content', () async {
      await logService.info('To be cleared');
      await logService.clearLogs();
      
      // File contains "Logs cleared"
      final content = await logService.readLogs();
      expect(content, contains('[INFO] Logs cleared'));
      expect(content, isNot(contains('To be cleared')));
    });
  });
}
