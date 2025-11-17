// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get theme => 'Theme';

  @override
  String get themeReload => 'Reload themes';

  @override
  String themeFolderHint(String path) {
    return 'Add or edit JSON theme files under $path and press Reload to apply.';
  }

  @override
  String get opacity => 'Opacity';

  @override
  String get scale => 'Scale';

  @override
  String get showSeconds => 'Show Seconds';

  @override
  String get hideSeconds => 'Hide Seconds';

  @override
  String get lockPosition => 'Lock Position';

  @override
  String get unlockPosition => 'Unlock Position';

  @override
  String get hideShow => 'Hide/Show';

  @override
  String get layer => 'Layer';

  @override
  String get layerDesktop => 'Desktop';

  @override
  String get layerNormal => 'Normal';

  @override
  String get layerTop => 'Always on Top';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get close => 'Close';

  @override
  String get exit => 'Exit';
}
