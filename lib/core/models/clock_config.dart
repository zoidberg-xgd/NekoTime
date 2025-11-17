import 'dart:ui';

import 'package:neko_time/core/models/theme_definition.dart';

// 定义时钟层级
enum ClockLayer {
  desktop, // 桌面层 (可被其他窗口遮挡)
  top, // 置顶层 (始终在最前)
}

class ClockConfig {
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
    // 兼容旧版本的三层级配置 (desktop/normal/top -> desktop/top)
    // 旧版本: 0=desktop, 1=normal, 2=top
    // 新版本: 0=desktop, 1=top
    int layerIndex = json['layerIndex'] ?? 0;
    if (layerIndex >= ClockLayer.values.length) {
      // 如果是旧的 index 2 (top)，映射到新的 index 1 (top)
      layerIndex = ClockLayer.top.index;
    }
    return ClockConfig(
      scale: (json['scale'] ?? 1.0) * 1.0,
      opacity: (json['opacity'] ?? 0.85) * 1.0,
      themeId: json['themeId'] as String? ??
          _themeIdFromLegacyIndex(legacyThemeIndex),
      layer: ClockLayer.values[layerIndex],
      lockPosition: json['lockPosition'] ?? false,
      locale: json['locale'] ?? 'en',
    );
  }

  // 将配置转为 JSON
  Map<String, dynamic> toJson() {
    return {
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
    double? scale,
    double? opacity,
    String? themeId,
    ClockLayer? layer,
    bool? lockPosition,
    String? locale,
  }) {
    return ClockConfig(
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
  final double digitWidth = digitHeight * 0.58; // 数字宽度
  final double colonWidth = digitHeight * 0.25; // 冒号宽度
  final double digitSpacing = 2 * config.scale; // 数字间距也随scale缩放

  // 计算实际内容宽度：4个数字 + 1个冒号 (HH:MM) + 数字间距
  // 间距在数字之间，不包括冒号前后
  final double baseW =
      4 * digitWidth + colonWidth + 2 * digitSpacing; // 2个间距（HH之间和MM之间）

  final double baseH = digitHeight;

  // padding 也要随着 scale 缩放，保持比例
  final double padH = 24 * config.scale; // 左右边距 (12*2)
  final double padV = 16 * config.scale; // 上下边距 (8*2)

  return Size(baseW + padH, baseH + padV);
}

String _themeIdFromLegacyIndex(int? index) {
  return ThemeDefinition.defaultThemeId;
}
