import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/core/models/clock_config.dart';
import 'package:neko_time/core/models/theme_definition.dart';

void main() {
  group('ClockConfig', () {
    test('initialization with defaults', () {
      final config = ClockConfig();
      expect(config.themeId, equals(ThemeDefinition.defaultThemeId));
      expect(config.scale, equals(1.0));
      expect(config.opacity, equals(0.85));
      expect(config.layer, equals(ClockLayer.top));
      expect(config.lockPosition, isFalse);
      expect(config.locale, equals('en'));
    });

    test('initialization with custom values', () {
      final config = ClockConfig(
        themeId: 'custom_theme',
        scale: 1.5,
        opacity: 0.5,
        layer: ClockLayer.desktop,
        lockPosition: true,
        locale: 'zh',
      );

      expect(config.themeId, equals('custom_theme'));
      expect(config.scale, equals(1.5));
      expect(config.opacity, equals(0.5));
      expect(config.layer, equals(ClockLayer.desktop));
      expect(config.lockPosition, isTrue);
      expect(config.locale, equals('zh'));
    });

    test('fromJson handles valid JSON', () {
      final json = {
        'scale': 2.0,
        'opacity': 0.8,
        'themeId': 'test_theme',
        'layerIndex': 1, // ClockLayer.top
        'lockPosition': true,
        'locale': 'ja',
      };

      final config = ClockConfig.fromJson(json);
      expect(config.scale, equals(2.0));
      expect(config.opacity, equals(0.8));
      expect(config.themeId, equals('test_theme'));
      expect(config.layer, equals(ClockLayer.top));
      expect(config.lockPosition, isTrue);
      expect(config.locale, equals('ja'));
    });

    test('fromJson handles legacy layer index', () {
      // Old index 2 was top, new index 1 is top
      final json = {
        'layerIndex': 2,
      };
      final config = ClockConfig.fromJson(json);
      expect(config.layer, equals(ClockLayer.top));
    });

    test('toJson returns correct map', () {
      final config = ClockConfig(
        themeId: 'my_theme',
        scale: 1.2,
        opacity: 0.9,
        layer: ClockLayer.desktop,
        lockPosition: true,
        locale: 'fr',
      );

      final json = config.toJson();
      expect(json['themeId'], equals('my_theme'));
      expect(json['scale'], equals(1.2));
      expect(json['opacity'], equals(0.9));
      expect(json['layerIndex'], equals(0)); // desktop
      expect(json['lockPosition'], isTrue);
      expect(json['locale'], equals('fr'));
    });

    test('copyWith creates new instance with updated values', () {
      final config = ClockConfig();
      final newConfig = config.copyWith(
        scale: 2.0,
        themeId: 'new_theme',
      );

      expect(newConfig.scale, equals(2.0));
      expect(newConfig.themeId, equals('new_theme'));
      // Should keep old values
      expect(newConfig.opacity, equals(config.opacity));
      expect(newConfig.layer, equals(config.layer));
    });
  });

  group('ThemeDefinition', () {
     test('defaults are correct', () {
      expect(ThemeDefinition.defaultThemeId, equals('builtin_frosted_glass'));
    });
  });
}
