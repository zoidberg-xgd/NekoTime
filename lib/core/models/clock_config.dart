import 'dart:ui';

import 'package:digital_clock/core/models/theme_definition.dart';

// 定义时钟层级
enum ClockLayer {
  desktop, // 桌面层 (可被其他窗口遮挡)
  normal, // 普通窗口层
  top, // 置顶层
}

class ClockConfig {
  // 是否显示秒
  bool showSeconds;
  // 缩放比例（基础缩放因子）
  double scale;
  // 透明度（0-1）：整体不透明度/主题强度
  double opacity;
  // 当前主题 ID
  String themeId;
  // 时钟层级
  ClockLayer layer;
  // 是否锁定位置（不可拖动）
  bool lockPosition;
  // 语言环境
  String locale;

  ClockConfig({
    this.showSeconds = false, // 默认不显示秒
    this.scale = 1.0,
    this.opacity = 0.85,
    String? themeId,
    this.layer = ClockLayer.top,
    this.lockPosition = false,
    this.locale = 'en',
  }) : themeId = themeId ?? ThemeDefinition.defaultThemeId;

  // 从 JSON 创建配置
  factory ClockConfig.fromJson(Map<String, dynamic> json) {
    final legacyThemeIndex = json['themeStyleIndex'] as int?;
    return ClockConfig(
      showSeconds: json['showSeconds'] ?? false,
      scale: (json['scale'] ?? 1.0) * 1.0,
      opacity: (json['opacity'] ?? 0.85) * 1.0,
      themeId: json['themeId'] as String? ??
          _themeIdFromLegacyIndex(legacyThemeIndex),
      layer: ClockLayer.values[json['layerIndex'] ?? 0],
      lockPosition: json['lockPosition'] ?? false,
      locale: json['locale'] ?? 'en',
    );
  }

  // 将配置转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'showSeconds': showSeconds,
      'scale': scale,
      'opacity': opacity,
      'themeId': themeId,
      'layerIndex': layer.index,
      'lockPosition': lockPosition,
      'locale': locale,
    };
  }

  // 复制配置并修改
  ClockConfig copyWith({
    bool? showSeconds,
    double? scale,
    double? opacity,
    String? themeId,
    ClockLayer? layer,
    bool? lockPosition,
    String? locale,
  }) {
    return ClockConfig(
      showSeconds: showSeconds ?? this.showSeconds,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      themeId: themeId ?? this.themeId,
      layer: layer ?? this.layer,
      lockPosition: lockPosition ?? this.lockPosition,
      locale: locale ?? this.locale,
    );
  }
}

Size calculateWindowSizeFromConfig(ClockConfig config) {
  final double digitHeight = 80 * config.scale;
  final double digitWidth = digitHeight * 0.58; // 更紧凑的宽度
  final double colonWidth = digitHeight * 0.25; // 冒号宽度
  
  // 计算实际内容宽度：4个数字 + 1个冒号
  final double baseW = config.showSeconds 
      ? (6 * digitWidth + 2 * colonWidth) // HH:MM:SS
      : (4 * digitWidth + colonWidth);    // HH:MM
  
  final double baseH = digitHeight;
  
  // padding 也要随着 scale 缩放，保持比例
  final double padH = 8 * config.scale;  // 左右边距按比例缩放
  final double padV = 4 * config.scale;  // 上下边距按比例缩放
  
  return Size(baseW + padH, baseH + padV);
}

String _themeIdFromLegacyIndex(int? index) {
  return ThemeDefinition.defaultThemeId;
}
