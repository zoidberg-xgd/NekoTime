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
  // 窗口位置 X 坐标
  double? positionX;
  // 窗口位置 Y 坐标
  double? positionY;

  ClockConfig({
    this.scale = 1.0,
    this.opacity = 0.85,
    String? themeId,
    this.layer = ClockLayer.top,
    this.lockPosition = false,
    this.locale = 'en',
    this.positionX,
    this.positionY,
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
      positionX: json['positionX'] as double?,
      positionY: json['positionY'] as double?,
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
      'positionX': positionX,
      'positionY': positionY,
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
    double? positionX,
    double? positionY,
  }) {
    return ClockConfig(
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      themeId: themeId ?? this.themeId,
      layer: layer ?? this.layer,
      lockPosition: lockPosition ?? this.lockPosition,
      locale: locale ?? this.locale,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
    );
  }
}

/// Calculate window size based on config and theme properties.
/// [digitAspectRatio] is the width/height ratio of digit images (detected from theme).
/// [digitBaseHeight] is the original height of digit images in pixels (detected from theme).
/// [digitSpacing] is the spacing between digits.
/// [paddingHorizontal] is the horizontal padding from theme (default 12).
/// [paddingVertical] is the vertical padding from theme (default 8).
Size calculateWindowSizeFromConfig(
  ClockConfig config, {
  double? digitAspectRatio,
  double? digitBaseHeight,
  double digitSpacing = 2.0,
  double paddingHorizontal = 12.0,
  double paddingVertical = 8.0,
}) {
  // Use detected base height, or fallback to default 80
  final double baseHeight = digitBaseHeight ?? 80.0;
  final double digitHeight = baseHeight * config.scale;
  // Use detected aspect ratio, or fallback to default 0.58
  final double aspectRatio = digitAspectRatio ?? 0.58;
  final double digitWidth = digitHeight * aspectRatio;
  // Colon width is proportional to digit width
  final double colonWidth = digitWidth * 0.45;
  final double spacing = digitSpacing * config.scale;

  // 计算实际内容宽度：4个数字 + 1个冒号 (HH:MM) + 数字间距
  // 间距在数字之间，不包括冒号前后 (HH之间和MM之间各一个)
  final double baseW = 4 * digitWidth + colonWidth + 2 * spacing;

  final double baseH = digitHeight;

  // padding 使用主题的值，并随 scale 缩放
  final double padH = paddingHorizontal * 2 * config.scale; // 左右边距
  final double padV = paddingVertical * 2 * config.scale; // 上下边距

  // 向上取整并添加 1 像素安全边距，防止浮点精度导致的溢出
  return Size(
    (baseW + padH).ceilToDouble() + 1,
    (baseH + padV).ceilToDouble() + 1,
  );
}

String _themeIdFromLegacyIndex(int? index) {
  return ThemeDefinition.defaultThemeId;
}
