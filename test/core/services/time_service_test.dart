import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/core/services/time_service.dart';

void main() {
  group('TimeService', () {
    late TimeService timeService;

    setUp(() {
      timeService = TimeService();
    });

    test('formatTime returns correct format for HH:MM', () {
      final time = DateTime(2023, 1, 1, 9, 5); // 09:05
      final parts = timeService.formatTime(time);

      expect(parts, equals(['0', '9', ':', '0', '5']));
    });

    test('formatTime handles double digits correctly', () {
      final time = DateTime(2023, 1, 1, 23, 59); // 23:59
      final parts = timeService.formatTime(time);

      expect(parts, equals(['2', '3', ':', '5', '9']));
    });

    test('formatTime handles noon/midnight correctly', () {
      final noon = DateTime(2023, 1, 1, 12, 0);
      expect(timeService.formatTime(noon), equals(['1', '2', ':', '0', '0']));

      final midnight = DateTime(2023, 1, 1, 0, 0);
      expect(timeService.formatTime(midnight), equals(['0', '0', ':', '0', '0']));
    });

    test('timeStream emits values', () async {
      // Just check if it emits at least one value
      final stream = timeService.timeStream;
      final value = await stream.first;
      expect(value, isA<DateTime>());
    });
  });
}
