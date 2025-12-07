import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/core/models/clock_config.dart';
import 'package:neko_time/core/services/config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigService', () {
    late ConfigService configService;

    // Mock window_manager channel
    setUp(() {
      const channel = MethodChannel('window_manager');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return null;
      });

      SharedPreferences.setMockInitialValues({});
      configService = ConfigService();
    });

    tearDown(() {
      const channel = MethodChannel('window_manager');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('init loads default config when prefs are empty', () async {
      await configService.init();
      
      expect(configService.config.scale, equals(1.0));
      expect(configService.config.opacity, equals(0.85));
    });

    test('init loads saved config', () async {
      SharedPreferences.setMockInitialValues({
        'clock_config': '{"scale": 2.5, "opacity": 0.5, "themeId": "saved_theme"}'
      });
      
      // Re-init to load new values
      await configService.init();

      expect(configService.config.scale, equals(2.5));
      expect(configService.config.opacity, equals(0.5));
      expect(configService.config.themeId, equals("saved_theme"));
    });

    test('saveConfig updates config and persists it', () async {
      await configService.init();
      
      final newConfig = ClockConfig(scale: 3.0, themeId: 'new_theme');
      await configService.saveConfig(newConfig);

      expect(configService.config.scale, equals(3.0));
      expect(configService.config.themeId, equals('new_theme'));

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('clock_config');
      expect(savedJson, contains('"scale":3.0'));
      expect(savedJson, contains('"themeId":"new_theme"'));
    });

    test('setScale updates scale and notifies listeners', () async {
      await configService.init();
      bool notified = false;
      configService.addListener(() => notified = true);

      await configService.setScale(1.5);

      expect(configService.config.scale, equals(1.5));
      expect(notified, isTrue);
    });

    test('setOpacity updates opacity and notifies listeners', () async {
      await configService.init();
      bool notified = false;
      configService.addListener(() => notified = true);

      await configService.setOpacity(0.3);

      expect(configService.config.opacity, equals(0.3));
      expect(notified, isTrue);
    });
    
    test('setTheme updates themeId', () async {
      await configService.init();
      await configService.setTheme('dark_theme');
      expect(configService.config.themeId, equals('dark_theme'));
    });

    test('setLayer updates layer', () async {
      await configService.init();
      await configService.setLayer(ClockLayer.top);
      expect(configService.config.layer, equals(ClockLayer.top));
    });

    test('toggleLockPosition toggles value', () async {
      await configService.init();
      expect(configService.config.lockPosition, isFalse);
      
      await configService.toggleLockPosition();
      expect(configService.config.lockPosition, isTrue);
      
      await configService.toggleLockPosition();
      expect(configService.config.lockPosition, isFalse);
    });
  });
}
