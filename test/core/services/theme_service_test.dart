import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/core/models/theme_definition.dart';
import 'package:neko_time/core/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeService', () {
    late ThemeService themeService;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('neko_time_test_');

      // Mock path_provider
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return tempDir.path;
        }
        return null;
      });

      // Mock asset bundle for example theme
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
            // Simple check if it asks for a file, we can return empty or specific json
            // But implementing full asset protocol is hard. 
            // ThemeService uses rootBundle.loadString which eventually calls standard platform channel.
            // We might just let it fail or handle specific paths if needed.
            // For now, let's assume init() might fail to load assets but should still load builtin theme.
            return null;
      });

      themeService = ThemeService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('init loads builtin theme', () async {
      // It might fail to load example themes due to missing assets in test, 
      // but it should at least load builtin theme.
      await themeService.init();

      expect(themeService.themes, isNotEmpty);
      final builtin = themeService.themes.firstWhere((t) => t.id == ThemeDefinition.defaultThemeId);
      expect(builtin.name, equals('Frosted Glass'));
    });

    test('resolve returns builtin theme for default id', () async {
      await themeService.init();
      final theme = themeService.resolve(ThemeDefinition.defaultThemeId);
      expect(theme.id, equals(ThemeDefinition.defaultThemeId));
    });

    test('resolve returns fallback if themes empty (should not happen after init)', () {
      // If init not called, themes is empty
      final theme = themeService.resolve('non_existent');
      expect(theme.id, equals('fallback'));
    });

    test('loads custom themes from directory', () async {
      // Create a fake custom theme in the temp dir
      final themesDir = Directory('${tempDir.path}/themes');
      await themesDir.create(recursive: true);

      final customThemeDir = Directory('${themesDir.path}/custom_theme');
      await customThemeDir.create();

      final themeJson = '''
      {
        "id": "custom_theme",
        "name": "Custom Theme",
        "kind": "transparent"
      }
      ''';
      
      final configFile = File('${customThemeDir.path}/theme.json');
      await configFile.writeAsString(themeJson);

      await themeService.init();

      final theme = themeService.resolve('custom_theme');
      expect(theme.id, equals('custom_theme'));
      expect(theme.name, equals('Custom Theme'));
      expect(theme.kind, equals(ThemeKind.transparent));
    });

    test('loads legacy single file theme', () async {
      final themesDir = Directory('${tempDir.path}/themes');
      await themesDir.create(recursive: true);

      final themeJson = '''
      {
        "id": "legacy_theme",
        "name": "Legacy Theme",
        "kind": "solid"
      }
      ''';

      final configFile = File('${themesDir.path}/legacy_theme.json');
      await configFile.writeAsString(themeJson);

      await themeService.init();

      final theme = themeService.resolve('legacy_theme');
      expect(theme.id, equals('legacy_theme'));
      expect(theme.kind, equals(ThemeKind.solid));
    });
  });
}
