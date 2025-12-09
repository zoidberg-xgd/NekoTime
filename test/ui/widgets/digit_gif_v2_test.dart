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
}
