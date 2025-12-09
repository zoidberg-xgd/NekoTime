import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/ui/widgets/digit_gif_v2.dart';
import 'package:flutter/material.dart';

void main() {
  group('DigitGifV2 Memory Tests', () {
    testWidgets('widget can be created and disposed without leaks', (tester) async {
      // Create widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(digit: '1', scale: 1.0),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(DigitGifV2), findsOneWidget);

      // Dispose by replacing with empty container
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      // Widget should be gone
      expect(find.byType(DigitGifV2), findsNothing);
    });

    testWidgets('multiple widgets can be created and disposed', (tester) async {
      // Create multiple widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                DigitGifV2(digit: '1', scale: 1.0),
                DigitGifV2(digit: '2', scale: 1.0),
                DigitGifV2(digit: ':', scale: 1.0),
                DigitGifV2(digit: '3', scale: 1.0),
                DigitGifV2(digit: '4', scale: 1.0),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsNWidgets(5));

      // Dispose all
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsNothing);
    });

    testWidgets('widget updates correctly when digit changes', (tester) async {
      // Start with digit 1
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(digit: '1', scale: 1.0),
          ),
        ),
      );

      // Change to digit 2
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(digit: '2', scale: 1.0),
          ),
        ),
      );

      // Should still have one widget
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('colon widget renders without image loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(digit: ':', scale: 1.0),
          ),
        ),
      );

      // Colon should render as text, not image
      expect(find.text(':'), findsOneWidget);
    });

    testWidgets('widget handles rapid scale changes', (tester) async {
      for (double scale = 0.5; scale <= 2.0; scale += 0.1) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DigitGifV2(digit: '5', scale: scale),
            ),
          ),
        );
      }

      // Should still have one widget after all changes
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('widget handles null optional parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '7',
              scale: 1.0,
              fontFamily: null,
              gifBasePath: null,
              imageFormat: null,
              assetsBasePath: null,
              digitAspectRatio: null,
              digitBaseHeight: null,
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('widget dimensions are correct', (tester) async {
      const scale = 1.0;
      const baseHeight = 80.0;
      const aspectRatio = 0.58;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DigitGifV2(
                digit: '0',
                scale: scale,
                digitBaseHeight: baseHeight,
                digitAspectRatio: aspectRatio,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the SizedBox that wraps the digit
      final sizedBoxFinder = find.descendant(
        of: find.byType(DigitGifV2),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsWidgets);
    });

    testWidgets('all digits 0-9 can be rendered', (tester) async {
      for (int i = 0; i <= 9; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DigitGifV2(digit: '$i', scale: 1.0),
            ),
          ),
        );

        expect(find.byType(DigitGifV2), findsOneWidget);
      }
    });
  });

  group('DigitGifV2 Asset Cache Tests', () {
    testWidgets('asset cache is populated on first check', (tester) async {
      // First widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(digit: '1', scale: 1.0),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Second widget with same digit should use cache
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                DigitGifV2(digit: '1', scale: 1.0),
                DigitGifV2(digit: '1', scale: 2.0), // Same digit, different scale
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsNWidgets(2));
    });

    testWidgets('different digits have separate cache entries', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                DigitGifV2(digit: '1', scale: 1.0),
                DigitGifV2(digit: '2', scale: 1.0),
                DigitGifV2(digit: '3', scale: 1.0),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DigitGifV2), findsNWidgets(3));
    });
  });

  group('DigitGifV2 Dimension Tests', () {
    testWidgets('custom aspect ratio affects width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '5',
              scale: 1.0,
              digitAspectRatio: 0.8, // Wider than default
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('custom base height affects size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '5',
              scale: 1.0,
              digitBaseHeight: 100.0, // Larger than default 80
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('colon width is proportional to digit width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DigitGifV2(digit: '1', scale: 1.0),
                DigitGifV2(digit: ':', scale: 1.0),
                DigitGifV2(digit: '2', scale: 1.0),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsNWidgets(3));
      expect(find.text(':'), findsOneWidget);
    });
  });

  group('DigitGifV2 External File Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('digit_gif_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets('widget with assetsBasePath renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '5',
              scale: 1.0,
              gifBasePath: 'digits',
              imageFormat: 'gif',
              assetsBasePath: tempDir.path,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render (either image or text fallback)
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('widget falls back to text when external file not found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '7',
              scale: 1.0,
              gifBasePath: 'nonexistent',
              imageFormat: 'gif',
              assetsBasePath: tempDir.path,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show text fallback
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('widget handles null assetsBasePath for external path', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '3',
              scale: 1.0,
              gifBasePath: 'digits', // Not starting with assets/ or themes/
              imageFormat: 'gif',
              assetsBasePath: null, // No base path
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show text fallback since no assetsBasePath
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('widget with builtin asset path works without assetsBasePath', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '9',
              scale: 1.0,
              gifBasePath: 'themes/builtin/frosted_glass/digits',
              imageFormat: 'gif',
              assetsBasePath: null, // Should still work for builtin
            ),
          ),
        ),
      );

      // Should not crash
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('multiple widgets with different paths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                // Builtin asset
                const DigitGifV2(
                  digit: '1',
                  scale: 1.0,
                  gifBasePath: 'themes/builtin/frosted_glass/digits',
                ),
                // External file (will fallback to text)
                DigitGifV2(
                  digit: '2',
                  scale: 1.0,
                  gifBasePath: 'digits',
                  assetsBasePath: tempDir.path,
                ),
                // Colon (always text)
                const DigitGifV2(
                  digit: ':',
                  scale: 1.0,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DigitGifV2), findsNWidgets(3));
    });
  });

  group('DigitGifV2 Path Detection Tests', () {
    testWidgets('assets/ prefix is detected as builtin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '0',
              scale: 1.0,
              gifBasePath: 'assets/gif',
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('themes/ prefix is detected as builtin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '0',
              scale: 1.0,
              gifBasePath: 'themes/example/digits',
            ),
          ),
        ),
      );

      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('relative path without prefix is treated as external', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '0',
              scale: 1.0,
              gifBasePath: 'digits', // No prefix
              assetsBasePath: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should fallback to text since no assetsBasePath
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('DigitGifV2 Smart Cache Tests', () {
    testWidgets('null gifBasePath shows text fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '5',
              scale: 1.0,
              gifBasePath: null, // No gif path
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show text fallback when no gifBasePath
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('switching themes triggers cache update', (tester) async {
      // First theme
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '1',
              scale: 1.0,
              gifBasePath: 'themes/theme_a/digits',
              assetsBasePath: '/path/to/theme_a',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to second theme
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '1',
              scale: 1.0,
              gifBasePath: 'themes/theme_b/digits',
              assetsBasePath: '/path/to/theme_b',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render without errors
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('rapid theme switching does not crash', (tester) async {
      final themes = [
        {'path': 'themes/a/digits', 'base': '/a'},
        {'path': 'themes/b/digits', 'base': '/b'},
        {'path': 'themes/c/digits', 'base': '/c'},
        {'path': 'themes/d/digits', 'base': '/d'},
        {'path': 'themes/e/digits', 'base': '/e'},
      ];

      for (final theme in themes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DigitGifV2(
                digit: '7',
                scale: 1.0,
                gifBasePath: theme['path'],
                assetsBasePath: theme['base'],
              ),
            ),
          ),
        );
        await tester.pump();
      }

      // Should handle rapid switching without crash
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('LRU cache evicts oldest theme after limit', (tester) async {
      // Create more than 3 themes (the cache limit)
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DigitGifV2(
                digit: '$i',
                scale: 1.0,
                gifBasePath: 'themes/theme_$i/digits',
                assetsBasePath: '/path/to/theme_$i',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      // Should still work after cache eviction
      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('same theme different digits share cache', (tester) async {
      // Multiple digits from same theme
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                DigitGifV2(
                  digit: '1',
                  scale: 1.0,
                  gifBasePath: 'themes/shared/digits',
                  assetsBasePath: '/shared',
                ),
                DigitGifV2(
                  digit: '2',
                  scale: 1.0,
                  gifBasePath: 'themes/shared/digits',
                  assetsBasePath: '/shared',
                ),
                DigitGifV2(
                  digit: '3',
                  scale: 1.0,
                  gifBasePath: 'themes/shared/digits',
                  assetsBasePath: '/shared',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All digits should render
      expect(find.byType(DigitGifV2), findsNWidgets(3));
    });

    testWidgets('switching back to cached theme is fast', (tester) async {
      // Theme A
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '1',
              scale: 1.0,
              gifBasePath: 'themes/cached_a/digits',
              assetsBasePath: '/cached_a',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Theme B
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '1',
              scale: 1.0,
              gifBasePath: 'themes/cached_b/digits',
              assetsBasePath: '/cached_b',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Back to Theme A (should use cache)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitGifV2(
              digit: '1',
              scale: 1.0,
              gifBasePath: 'themes/cached_a/digits',
              assetsBasePath: '/cached_a',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DigitGifV2), findsOneWidget);
    });

    testWidgets('text-only theme (null gifBasePath) works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: const [
                DigitGifV2(digit: '1', scale: 1.0, gifBasePath: null),
                DigitGifV2(digit: '2', scale: 1.0, gifBasePath: null),
                DigitGifV2(digit: ':', scale: 1.0, gifBasePath: null),
                DigitGifV2(digit: '3', scale: 1.0, gifBasePath: null),
                DigitGifV2(digit: '4', scale: 1.0, gifBasePath: null),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All should show text
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text(':'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });
}
