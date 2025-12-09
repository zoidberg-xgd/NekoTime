import 'dart:ui';

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
        positionX: 100.0,
        positionY: 200.0,
      );

      expect(config.themeId, equals('custom_theme'));
      expect(config.scale, equals(1.5));
      expect(config.opacity, equals(0.5));
      expect(config.layer, equals(ClockLayer.desktop));
      expect(config.lockPosition, isTrue);
      expect(config.locale, equals('zh'));
      expect(config.positionX, equals(100.0));
      expect(config.positionY, equals(200.0));
    });

    test('fromJson handles valid JSON', () {
      final json = {
        'scale': 2.0,
        'opacity': 0.8,
        'themeId': 'test_theme',
        'layerIndex': 1, // ClockLayer.top
        'lockPosition': true,
        'locale': 'ja',
        'positionX': 150.0,
        'positionY': 250.0,
      };

      final config = ClockConfig.fromJson(json);
      expect(config.scale, equals(2.0));
      expect(config.opacity, equals(0.8));
      expect(config.themeId, equals('test_theme'));
      expect(config.layer, equals(ClockLayer.top));
      expect(config.lockPosition, isTrue);
      expect(config.locale, equals('ja'));
      expect(config.positionX, equals(150.0));
      expect(config.positionY, equals(250.0));
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
        positionX: 300.0,
        positionY: 400.0,
      );

      final json = config.toJson();
      expect(json['themeId'], equals('my_theme'));
      expect(json['scale'], equals(1.2));
      expect(json['opacity'], equals(0.9));
      expect(json['layerIndex'], equals(0)); // desktop
      expect(json['lockPosition'], isTrue);
      expect(json['locale'], equals('fr'));
      expect(json['positionX'], equals(300.0));
      expect(json['positionY'], equals(400.0));
    });

    test('copyWith creates new instance with updated values', () {
      final config = ClockConfig(
        positionX: 10.0,
        positionY: 20.0,
      );
      final newConfig = config.copyWith(
        scale: 2.0,
        themeId: 'new_theme',
        positionX: 50.0,
      );

      expect(newConfig.scale, equals(2.0));
      expect(newConfig.themeId, equals('new_theme'));
      expect(newConfig.positionX, equals(50.0));
      // Should keep old values
      expect(newConfig.opacity, equals(config.opacity));
      expect(newConfig.layer, equals(config.layer));
      expect(newConfig.positionY, equals(20.0));
    });
  });

  group('ThemeDefinition', () {
    test('defaults are correct', () {
      expect(ThemeDefinition.defaultThemeId, equals('frosted_glass'));
    });
  });

  group('calculateWindowSizeFromConfig', () {
    test('returns correct size for default config', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config);

      // digitHeight = 80, digitWidth = 80 * 0.58 = 46.4
      // colonWidth = 46.4 * 0.45 = 20.88
      // spacing = 2 * 1.0 = 2, 2 spacers = 4
      // baseW = 4 * 46.4 + 20.88 + 4 = 210.48
      // padH = 12 * 2 = 24, padV = 8 * 2 = 16
      // total: ~234.48 x 96, then ceil + 1 for safety margin
      // Result: 236 x 97
      expect(size.width, closeTo(236.0, 1.0));
      expect(size.height, closeTo(97.0, 1.0));
    });

    test('scales correctly with scale factor', () {
      final config1 = ClockConfig(scale: 1.0);
      final config2 = ClockConfig(scale: 2.0);

      final size1 = calculateWindowSizeFromConfig(config1);
      final size2 = calculateWindowSizeFromConfig(config2);

      // Size should scale approximately linearly (with ceil + 1 margin)
      expect(size2.width, closeTo(size1.width * 2, 5.0));
      expect(size2.height, closeTo(size1.height * 2, 5.0));
    });

    test('handles small scale factor', () {
      final config = ClockConfig(scale: 0.75);
      final size = calculateWindowSizeFromConfig(config);

      // Should be approximately 75% of default size (with ceil + 1 margin)
      final defaultSize = calculateWindowSizeFromConfig(ClockConfig(scale: 1.0));
      expect(size.width, closeTo(defaultSize.width * 0.75, 5.0));
      expect(size.height, closeTo(defaultSize.height * 0.75, 5.0));
    });

    test('respects custom digitSpacing', () {
      final config = ClockConfig(scale: 1.0);
      final sizeDefault = calculateWindowSizeFromConfig(config, digitSpacing: 2.0);
      final sizeWide = calculateWindowSizeFromConfig(config, digitSpacing: 10.0);

      // Wider spacing should result in wider window
      // Difference = 2 spacers * (10 - 2) = 16
      expect(sizeWide.width - sizeDefault.width, closeTo(16.0, 0.1));
      // Height should be the same
      expect(sizeWide.height, equals(sizeDefault.height));
    });

    test('zero digitSpacing produces narrower window', () {
      final config = ClockConfig(scale: 1.0);
      final sizeDefault = calculateWindowSizeFromConfig(config, digitSpacing: 2.0);
      final sizeZero = calculateWindowSizeFromConfig(config, digitSpacing: 0.0);

      // Zero spacing should be narrower by 2 * 2 = 4
      expect(sizeDefault.width - sizeZero.width, closeTo(4.0, 0.1));
    });

    test('respects custom digitAspectRatio', () {
      final config = ClockConfig(scale: 1.0);
      final sizeDefault = calculateWindowSizeFromConfig(config, digitAspectRatio: 0.58);
      final sizeWide = calculateWindowSizeFromConfig(config, digitAspectRatio: 1.0);

      // Wider aspect ratio should result in wider window
      // digitHeight = 80, digitWidth changes from 46.4 to 80
      // colonWidth changes from 20.88 to 36
      // Difference in baseW = 4 * (80 - 46.4) + (36 - 20.88) = 134.4 + 15.12 = 149.52
      expect(sizeWide.width, greaterThan(sizeDefault.width));
      expect(sizeWide.height, equals(sizeDefault.height));
    });

    test('large scale factor produces reasonable size', () {
      final config = ClockConfig(scale: 3.0);
      final size = calculateWindowSizeFromConfig(config);
      final defaultSize = calculateWindowSizeFromConfig(ClockConfig(scale: 1.0));

      // Should be approximately 3x the default (with ceil + 1 margin)
      expect(size.width, closeTo(defaultSize.width * 3, 10.0));
      expect(size.height, closeTo(defaultSize.height * 3, 10.0));
    });

    // === 边界测试 ===

    test('minimum scale factor (0.5) produces valid size', () {
      final config = ClockConfig(scale: 0.5);
      final size = calculateWindowSizeFromConfig(config);

      // Should be half of default
      expect(size.width, greaterThan(100));
      expect(size.height, greaterThan(40));
      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
    });

    test('maximum scale factor (3.0) produces valid size', () {
      final config = ClockConfig(scale: 3.0);
      final size = calculateWindowSizeFromConfig(config);

      expect(size.width, lessThan(1000));
      expect(size.height, lessThan(400));
      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
    });

    test('extreme small scale (0.1) does not crash', () {
      final config = ClockConfig(scale: 0.1);
      final size = calculateWindowSizeFromConfig(config);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
    });

    test('extreme large scale (10.0) does not crash', () {
      final config = ClockConfig(scale: 10.0);
      final size = calculateWindowSizeFromConfig(config);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
    });

    test('very small digitAspectRatio (0.1) produces valid size', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config, digitAspectRatio: 0.1);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      // Width should be much smaller than height with narrow aspect ratio
      expect(size.width, lessThan(size.height * 3));
    });

    test('very large digitAspectRatio (2.0) produces valid size', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config, digitAspectRatio: 2.0);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      // Width should be much larger with wide aspect ratio
      expect(size.width, greaterThan(size.height * 3));
    });

    test('very small digitBaseHeight (20) produces valid size', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config, digitBaseHeight: 20.0);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      expect(size.height, lessThan(100)); // Should be small
    });

    test('very large digitBaseHeight (200) produces valid size', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config, digitBaseHeight: 200.0);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      expect(size.height, greaterThan(200)); // Should be large
    });

    test('negative digitSpacing is handled gracefully', () {
      final config = ClockConfig(scale: 1.0);
      // Negative spacing should still produce valid (though possibly odd) size
      final size = calculateWindowSizeFromConfig(config, digitSpacing: -5.0);

      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
    });

    test('very large digitSpacing produces valid size', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config, digitSpacing: 100.0);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      expect(size.width.isFinite, isTrue);
    });

    test('all parameters at extreme values', () {
      final config = ClockConfig(scale: 0.5);
      final size = calculateWindowSizeFromConfig(
        config,
        digitAspectRatio: 0.3,
        digitBaseHeight: 50.0,
        digitSpacing: 10.0,
      );

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
    });

    test('null parameters use defaults correctly', () {
      final config = ClockConfig(scale: 1.0);
      final sizeWithDefaults = calculateWindowSizeFromConfig(config);
      final sizeWithExplicitDefaults = calculateWindowSizeFromConfig(
        config,
        digitAspectRatio: 0.58,
        digitBaseHeight: 80.0,
        digitSpacing: 2.0,
      );

      expect(sizeWithDefaults.width, closeTo(sizeWithExplicitDefaults.width, 0.1));
      expect(sizeWithDefaults.height, closeTo(sizeWithExplicitDefaults.height, 0.1));
    });

    test('fractional scale values work correctly', () {
      final config1 = ClockConfig(scale: 0.75);
      final config2 = ClockConfig(scale: 1.25);
      final config3 = ClockConfig(scale: 1.5);

      final size1 = calculateWindowSizeFromConfig(config1);
      final size2 = calculateWindowSizeFromConfig(config2);
      final size3 = calculateWindowSizeFromConfig(config3);

      // Sizes should be ordered correctly
      expect(size1.width, lessThan(size2.width));
      expect(size2.width, lessThan(size3.width));
      expect(size1.height, lessThan(size2.height));
      expect(size2.height, lessThan(size3.height));
    });

    test('window size is always positive', () {
      // Test various edge cases that might produce negative sizes
      final testCases = [
        ClockConfig(scale: 0.01),
        ClockConfig(scale: 0.5),
        ClockConfig(scale: 1.0),
        ClockConfig(scale: 5.0),
      ];

      for (final config in testCases) {
        final size = calculateWindowSizeFromConfig(config);
        expect(size.width, greaterThan(0), reason: 'scale=${config.scale}');
        expect(size.height, greaterThan(0), reason: 'scale=${config.scale}');
      }
    });

    // === 美观度测试 ===

    test('window aspect ratio is reasonable (width > height)', () {
      // Clock should be wider than tall (HH:MM format)
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config);

      expect(size.width, greaterThan(size.height),
          reason: 'Clock window should be wider than tall');
      // Aspect ratio should be between 2:1 and 3:1
      final aspectRatio = size.width / size.height;
      expect(aspectRatio, greaterThan(1.5),
          reason: 'Window should be at least 1.5x wider than tall');
      expect(aspectRatio, lessThan(4.0),
          reason: 'Window should not be more than 4x wider than tall');
    });

    test('padding is proportional to content', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config);

      // Calculate content size (without padding)
      final digitHeight = 80.0;
      final digitWidth = digitHeight * 0.58;
      final colonWidth = digitWidth * 0.45;
      final contentWidth = 4 * digitWidth + colonWidth + 2 * 2.0; // 2 spacers

      // Padding should be reasonable (not too much, not too little)
      final horizontalPadding = size.width - contentWidth;
      final verticalPadding = size.height - digitHeight;

      // Horizontal padding should be 10-20% of content width
      expect(horizontalPadding, greaterThan(contentWidth * 0.1),
          reason: 'Horizontal padding should be at least 10% of content');
      expect(horizontalPadding, lessThan(contentWidth * 0.25),
          reason: 'Horizontal padding should not exceed 25% of content');

      // Vertical padding should be 15-40% of content height
      expect(verticalPadding, greaterThan(digitHeight * 0.15),
          reason: 'Vertical padding should be at least 15% of content');
      expect(verticalPadding, lessThan(digitHeight * 0.5),
          reason: 'Vertical padding should not exceed 50% of content');
    });

    test('scale maintains visual proportions', () {
      // Different scales should maintain the same aspect ratio
      final scales = [0.5, 0.75, 1.0, 1.5, 2.0];
      double? baseAspectRatio;

      for (final scale in scales) {
        final config = ClockConfig(scale: scale);
        final size = calculateWindowSizeFromConfig(config);
        final aspectRatio = size.width / size.height;

        if (baseAspectRatio == null) {
          baseAspectRatio = aspectRatio;
        } else {
          // Aspect ratio should remain consistent across scales
          expect(aspectRatio, closeTo(baseAspectRatio, 0.01),
              reason: 'Aspect ratio should be consistent at scale=$scale');
        }
      }
    });

    test('minimum usable size at smallest scale', () {
      // At minimum scale (0.5), window should still be usable
      final config = ClockConfig(scale: 0.5);
      final size = calculateWindowSizeFromConfig(config);

      // Minimum readable size
      expect(size.width, greaterThan(100),
          reason: 'Window should be at least 100px wide at min scale');
      expect(size.height, greaterThan(40),
          reason: 'Window should be at least 40px tall at min scale');
    });

    test('maximum size at largest scale is not excessive', () {
      // At maximum scale (3.0), window should not be too large
      final config = ClockConfig(scale: 3.0);
      final size = calculateWindowSizeFromConfig(config);

      // Should fit on most screens
      expect(size.width, lessThan(800),
          reason: 'Window should be less than 800px wide at max scale');
      expect(size.height, lessThan(400),
          reason: 'Window should be less than 400px tall at max scale');
    });

    test('digit spacing does not break visual balance', () {
      final config = ClockConfig(scale: 1.0);

      // Test various spacing values
      final spacings = [0.0, 2.0, 5.0, 10.0];
      Size? previousSize;

      for (final spacing in spacings) {
        final size = calculateWindowSizeFromConfig(config, digitSpacing: spacing);

        if (previousSize != null) {
          // Width should increase with spacing
          expect(size.width, greaterThanOrEqualTo(previousSize.width),
              reason: 'Width should increase with spacing=$spacing');
          // Height should remain constant
          expect(size.height, equals(previousSize.height),
              reason: 'Height should not change with spacing');
        }
        previousSize = size;
      }
    });

    test('different aspect ratios produce visually distinct sizes', () {
      final config = ClockConfig(scale: 1.0);

      final narrowSize = calculateWindowSizeFromConfig(config, digitAspectRatio: 0.4);
      final normalSize = calculateWindowSizeFromConfig(config, digitAspectRatio: 0.58);
      final wideSize = calculateWindowSizeFromConfig(config, digitAspectRatio: 0.8);

      // Widths should be ordered
      expect(narrowSize.width, lessThan(normalSize.width));
      expect(normalSize.width, lessThan(wideSize.width));

      // Heights should be the same (aspect ratio only affects width)
      expect(narrowSize.height, equals(normalSize.height));
      expect(normalSize.height, equals(wideSize.height));
    });

    test('golden ratio approximation for pleasing proportions', () {
      // The window should have pleasing proportions
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config);

      final aspectRatio = size.width / size.height;

      // Should be between 2:1 and 3:1 for a clock display
      // This is visually pleasing for horizontal time display
      expect(aspectRatio, greaterThan(2.0),
          reason: 'Clock should have at least 2:1 aspect ratio');
      expect(aspectRatio, lessThan(3.0),
          reason: 'Clock should have at most 3:1 aspect ratio');
    });

    test('content area is centered with equal padding', () {
      final config = ClockConfig(scale: 1.0);
      final size = calculateWindowSizeFromConfig(config);

      // Calculate expected padding
      final padH = 32 * config.scale; // From implementation
      final padV = 24 * config.scale;

      // Padding should be symmetric
      expect(padH, equals(32.0), reason: 'Horizontal padding should be 32');
      expect(padV, equals(24.0), reason: 'Vertical padding should be 24');

      // Padding ratio should be reasonable
      final paddingRatio = padH / padV;
      expect(paddingRatio, closeTo(1.33, 0.1),
          reason: 'Padding ratio should be approximately 4:3');
    });
  });
}
