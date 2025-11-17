// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:digital_clock/core/services/config_service.dart';
import 'package:digital_clock/main.dart';
import 'package:digital_clock/ui/screens/clock_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final configService = ConfigService();
    await configService.init();

    await tester.pumpWidget(MyApp(configService: configService));

    // Verify that our clock screen is present.
    expect(find.byType(ClockScreen), findsOneWidget);
  });
}



