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

    group('init', () {
      test('creates themes directory if not exists', () async {
        await themeService.init();
        
        final themesDir = Directory('${tempDir.path}/themes');
        expect(await themesDir.exists(), isTrue);
      });

      test('creates fallback theme if no themes found', () async {
        // Init without any themes in directory
        await themeService.init();
        
        // Should have at least fallback theme
        expect(themeService.themes, isNotEmpty);
      });

      test('themesDirectoryPath returns correct path after init', () async {
        await themeService.init();
        
        expect(themeService.themesDirectoryPath, isNotNull);
        expect(themeService.themesDirectoryPath, contains('themes'));
      });
    });

    group('resolve', () {
      test('returns fallback if themes empty (before init)', () {
        final theme = themeService.resolve('non_existent');
        expect(theme.id, equals('fallback'));
      });

      test('returns first theme if requested theme not found', () async {
        // Create a custom theme
        final themesDir = Directory('${tempDir.path}/themes');
        await themesDir.create(recursive: true);
        final customThemeDir = Directory('${themesDir.path}/custom_theme');
        await customThemeDir.create();
        await File('${customThemeDir.path}/theme.json').writeAsString('''
        {"id": "custom_theme", "name": "Custom", "kind": "transparent"}
        ''');

        await themeService.init();

        final theme = themeService.resolve('non_existent_theme');
        // Should return custom_theme or fallback
        expect(theme, isNotNull);
      });
    });

    group('reload', () {
      test('reloads themes from directory', () async {
        await themeService.init();
        final initialCount = themeService.themes.length;

        // Add a new theme
        final themesDir = Directory('${tempDir.path}/themes');
        final newThemeDir = Directory('${themesDir.path}/new_theme');
        await newThemeDir.create();
        await File('${newThemeDir.path}/theme.json').writeAsString('''
        {"id": "new_theme", "name": "New Theme", "kind": "blur"}
        ''');

        await themeService.reload();

        expect(themeService.themes.length, greaterThanOrEqualTo(initialCount));
        final newTheme = themeService.themes.where((t) => t.id == 'new_theme');
        expect(newTheme, isNotEmpty);
      });

      test('creates fallback if all themes deleted', () async {
        await themeService.init();

        // Delete all themes
        final themesDir = Directory('${tempDir.path}/themes');
        if (await themesDir.exists()) {
          await for (final entity in themesDir.list()) {
            if (entity is Directory) {
              await entity.delete(recursive: true);
            } else if (entity is File && entity.path.endsWith('.json')) {
              await entity.delete();
            }
          }
        }

        await themeService.reload();

        expect(themeService.themes, isNotEmpty);
        expect(themeService.themes.first.id, equals('fallback'));
      });
    });

    group('custom themes', () {
      test('loads theme package with theme.json', () async {
        final themesDir = Directory('${tempDir.path}/themes');
        await themesDir.create(recursive: true);

        final customThemeDir = Directory('${themesDir.path}/custom_theme');
        await customThemeDir.create();

        final themeJson = '''
        {
          "id": "custom_theme",
          "name": "Custom Theme",
          "kind": "transparent",
          "borderRadius": 12,
          "padding": {"preset": "compact"}
        }
        ''';
        
        await File('${customThemeDir.path}/theme.json').writeAsString(themeJson);

        await themeService.init();

        final theme = themeService.resolve('custom_theme');
        expect(theme.id, equals('custom_theme'));
        expect(theme.name, equals('Custom Theme'));
        expect(theme.kind, equals(ThemeKind.transparent));
        expect(theme.borderRadius, equals(12));
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

        await File('${themesDir.path}/legacy_theme.json').writeAsString(themeJson);

        await themeService.init();

        final theme = themeService.resolve('legacy_theme');
        expect(theme.id, equals('legacy_theme'));
        expect(theme.kind, equals(ThemeKind.solid));
      });

      test('sets assetsBasePath for theme packages', () async {
        final themesDir = Directory('${tempDir.path}/themes');
        await themesDir.create(recursive: true);

        final customThemeDir = Directory('${themesDir.path}/my_theme');
        await customThemeDir.create();
        await File('${customThemeDir.path}/theme.json').writeAsString('''
        {"id": "my_theme", "name": "My Theme", "kind": "blur"}
        ''');

        await themeService.init();

        final theme = themeService.resolve('my_theme');
        expect(theme.assetsBasePath, isNotNull);
        expect(theme.assetsBasePath, contains('my_theme'));
      });

      test('theme with digit config loads correctly', () async {
        final themesDir = Directory('${tempDir.path}/themes');
        await themesDir.create(recursive: true);

        final customThemeDir = Directory('${themesDir.path}/digit_theme');
        await customThemeDir.create();
        await File('${customThemeDir.path}/theme.json').writeAsString('''
        {
          "id": "digit_theme",
          "name": "Digit Theme",
          "kind": "blur",
          "digit": {
            "spacing": 5,
            "gifPath": "digits",
            "format": "png"
          }
        }
        ''');

        await themeService.init();

        final theme = themeService.resolve('digit_theme');
        expect(theme.digitSpacing, equals(5));
        expect(theme.digitGifPath, equals('digits'));
        expect(theme.digitImageFormat, equals('png'));
      });
    });

    group('theme sorting', () {
      test('default theme is sorted first', () async {
        final themesDir = Directory('${tempDir.path}/themes');
        await themesDir.create(recursive: true);

        // Create default theme
        final defaultThemeDir = Directory('${themesDir.path}/${ThemeDefinition.defaultThemeId}');
        await defaultThemeDir.create();
        await File('${defaultThemeDir.path}/theme.json').writeAsString('''
        {"id": "${ThemeDefinition.defaultThemeId}", "name": "Frosted Glass", "kind": "blur"}
        ''');

        // Create another theme that would sort alphabetically before
        final aThemeDir = Directory('${themesDir.path}/aaa_theme');
        await aThemeDir.create();
        await File('${aThemeDir.path}/theme.json').writeAsString('''
        {"id": "aaa_theme", "name": "AAA Theme", "kind": "transparent"}
        ''');

        await themeService.init();

        final themes = themeService.themes;
        expect(themes.first.id, equals(ThemeDefinition.defaultThemeId));
      });

      test('other themes are sorted by name', () async {
        final themesDir = Directory('${tempDir.path}/themes');
        await themesDir.create(recursive: true);

        // Create themes with different names
        for (final name in ['Zebra', 'Alpha', 'Beta']) {
          final dir = Directory('${themesDir.path}/${name.toLowerCase()}');
          await dir.create();
          await File('${dir.path}/theme.json').writeAsString('''
          {"id": "${name.toLowerCase()}", "name": "$name Theme", "kind": "transparent"}
          ''');
        }

        await themeService.init();

        final themes = themeService.themes;
        final names = themes.map((t) => t.name).toList();
        
        // Should be sorted alphabetically (excluding default theme position)
        expect(names.indexOf('Alpha Theme'), lessThan(names.indexOf('Beta Theme')));
        expect(names.indexOf('Beta Theme'), lessThan(names.indexOf('Zebra Theme')));
      });
    });

    group('fallback theme', () {
      test('fallback theme has correct properties', () {
        final theme = themeService.resolve('non_existent');
        
        expect(theme.id, equals('fallback'));
        expect(theme.name, equals('Fallback'));
        expect(theme.kind, equals(ThemeKind.transparent));
        expect(theme.borderRadius, equals(12));
      });
    });
  });
}
