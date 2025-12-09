// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:neko_time/core/models/clock_config.dart';
import 'package:neko_time/core/models/theme_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NekoTime Tests', () {
    test('ClockConfig initialization', () {
      // Test ClockConfig creation with default values
      final config = ClockConfig(
        themeId: ThemeDefinition.defaultThemeId,
        scale: 1.0,
        opacity: 1.0,
        layer: ClockLayer.desktop,
        lockPosition: false,
        locale: 'en',
      );

      expect(config.themeId, equals(ThemeDefinition.defaultThemeId));
      expect(config.scale, equals(1.0));
      expect(config.opacity, equals(1.0));
      expect(config.layer, equals(ClockLayer.desktop));
      expect(config.lockPosition, isFalse);
      expect(config.locale, equals('en'));
    });

    test('ThemeDefinition defaults', () {
      // Test theme definition constants
      expect(ThemeDefinition.defaultThemeId, equals('frosted_glass'));
      expect(ThemeKind.values.length, equals(3));
      expect(ThemeKind.values, contains(ThemeKind.transparent));
      expect(ThemeKind.values, contains(ThemeKind.blur));
      expect(ThemeKind.values, contains(ThemeKind.solid));
    });

    test('ClockLayer enum', () {
      // Test ClockLayer enum values
      expect(ClockLayer.values.length, equals(2));
      expect(ClockLayer.values, contains(ClockLayer.desktop));
      expect(ClockLayer.values, contains(ClockLayer.top));
    });
  });
}
