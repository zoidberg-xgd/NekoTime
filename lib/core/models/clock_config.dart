// 定义时钟层级
enum ClockLayer {
  desktop, // 桌面层 (可被其他窗口遮挡)
  normal, // 普通窗口层
  top, // 置顶层
}

// 主题风格
enum ThemeStyle {
  transparent, // 完全透明
  frostedGlass, // 磨砂玻璃
  aquaGlass, // 水玻璃（带蓝色冷色调）
}

class ClockConfig {
  // 是否显示秒
  bool showSeconds;
  // 缩放比例（基础缩放因子）
  double scale;
  // 透明度（0-1）：整体不透明度/主题强度
  double opacity;
  // 主题风格
  ThemeStyle themeStyle;
  // 时钟层级
  ClockLayer layer;
  // 是否锁定位置（不可拖动）
  bool lockPosition;

  ClockConfig({
    this.showSeconds = false, // 默认不显示秒
    this.scale = 1.0,
    this.opacity = 0.85,
    this.themeStyle = ThemeStyle.transparent,
    this.layer = ClockLayer.desktop,
    this.lockPosition = false,
  });

  // 从 JSON 创建配置
  factory ClockConfig.fromJson(Map<String, dynamic> json) {
    return ClockConfig(
      showSeconds: json['showSeconds'] ?? false,
      scale: (json['scale'] ?? 1.0) * 1.0,
      opacity: (json['opacity'] ?? 0.85) * 1.0,
      themeStyle: ThemeStyle.values[json['themeStyleIndex'] ?? 0],
      layer: ClockLayer.values[json['layerIndex'] ?? 0],
      lockPosition: json['lockPosition'] ?? false,
    );
  }

  // 将配置转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'showSeconds': showSeconds,
      'scale': scale,
      'opacity': opacity,
      'themeStyleIndex': themeStyle.index,
      'layerIndex': layer.index,
      'lockPosition': lockPosition,
    };
  }

  // 复制配置并修改
  ClockConfig copyWith({
    bool? showSeconds,
    double? scale,
    double? opacity,
    ThemeStyle? themeStyle,
    ClockLayer? layer,
    bool? lockPosition,
  }) {
    return ClockConfig(
      showSeconds: showSeconds ?? this.showSeconds,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      themeStyle: themeStyle ?? this.themeStyle,
      layer: layer ?? this.layer,
      lockPosition: lockPosition ?? this.lockPosition,
    );
  }
}
