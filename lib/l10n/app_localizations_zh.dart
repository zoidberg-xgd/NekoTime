// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get theme => '主题';

  @override
  String get themeReload => '重新加载主题';

  @override
  String themeFolderHint(String path) {
    return '在 $path 中放置或修改 JSON 主题文件，点击“重新加载”即可生效。';
  }

  @override
  String get opacity => '透明度';

  @override
  String get scale => '缩放';

  @override
  String get showSeconds => '显示秒';

  @override
  String get hideSeconds => '隐藏秒';

  @override
  String get lockPosition => '锁定位置';

  @override
  String get unlockPosition => '解锁位置';

  @override
  String get hideShow => '隐藏/显示';

  @override
  String get layer => '显示层级';

  @override
  String get layerDesktop => '桌面层';

  @override
  String get layerTop => '置顶层';

  @override
  String get language => '语言';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageChinese => '简体中文';

  @override
  String get close => '关闭';

  @override
  String get exit => '退出';
}
