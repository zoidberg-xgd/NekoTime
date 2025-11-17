import 'dart:ui';

enum ThemeKind { transparent, blur, solid }
enum LayoutAlignment { left, center, right }

class ThemeDefinition {
  static const defaultThemeId = 'builtin_frosted_glass';

  final String id;
  final String name;
  final ThemeKind kind;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final String? paddingPreset;
  final LayoutAlignment alignment;
  final double blurSigmaX;
  final double blurSigmaY;
  final Color? backgroundColor;
  final double backgroundOpacityMultiplier;
  final Color? tintColor;
  final double tintOpacityMultiplier;
  final String? backgroundImagePath;
  final String? overlayImagePath;
  final double overlayOpacityMultiplier;
  final double? digitSpacing;
  final String? fontFamily;
  final List<String>? fontFiles;
  final String? digitGifPath; // Path to digit images directory (e.g., 'assets/gif' or 'gif')
  final String? digitImageFormat; // Image format: 'gif', 'png', 'jpg', 'webp', or null for auto-detect
  final String? assetsBasePath; // runtime-only; not serialized

  const ThemeDefinition({
    required this.id,
    required this.name,
    required this.kind,
    this.borderRadius = 0,
    this.paddingHorizontal = 16,
    this.paddingVertical = 8,
    this.paddingPreset,
    this.alignment = LayoutAlignment.center,
    this.blurSigmaX = 0,
    this.blurSigmaY = 0,
    this.backgroundColor,
    this.backgroundOpacityMultiplier = 1,
    this.tintColor,
    this.tintOpacityMultiplier = 1,
    this.backgroundImagePath,
    this.overlayImagePath,
    this.overlayOpacityMultiplier = 0.5,
    this.digitSpacing,
    this.fontFamily,
    this.fontFiles,
    this.digitGifPath,
    this.digitImageFormat,
    this.assetsBasePath,
  });

  factory ThemeDefinition.fromJson(Map<String, dynamic> json) {
    final String? alignRaw = (json['layout']?['alignment'] ?? json['alignment']) as String?;
    return ThemeDefinition(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['id'] as String,
      kind: _parseKind(json['kind'] as String?),
      borderRadius: (json['borderRadius'] ?? 0).toDouble(),
      paddingHorizontal:
          (json['padding']?['horizontal'] ?? json['paddingHorizontal'] ?? 16)
              .toDouble(),
      paddingVertical:
          (json['padding']?['vertical'] ?? json['paddingVertical'] ?? 8)
              .toDouble(),
      paddingPreset: (json['padding']?['preset'] ?? json['paddingPreset']) as String?,
      alignment: _parseAlignment(alignRaw),
      blurSigmaX:
          (json['blur']?['sigmaX'] ?? json['blurSigmaX'] ?? 0).toDouble(),
      blurSigmaY:
          (json['blur']?['sigmaY'] ?? json['blurSigmaY'] ?? 0).toDouble(),
      backgroundColor: _colorFromHex(json['backgroundColor'] as String?),
      backgroundOpacityMultiplier:
          (json['backgroundOpacityMultiplier'] ?? 1).toDouble(),
      tintColor: _colorFromHex(json['tintColor'] as String?),
      tintOpacityMultiplier: (json['tintOpacityMultiplier'] ?? 1).toDouble(),
      backgroundImagePath: json['backgroundImage'] as String?,
      overlayImagePath: json['overlayImage'] as String?,
      overlayOpacityMultiplier: (json['overlayOpacityMultiplier'] ?? 0.5).toDouble(),
      digitSpacing: (json['digit']?['spacing'] ?? json['digitSpacing']) == null
          ? null
          : (json['digit']?['spacing'] ?? json['digitSpacing']).toDouble(),
      fontFamily: json['fontFamily'] as String?,
      fontFiles: (json['fonts'] as List?)
          ?.map((e) {
            if (e is String) return e;
            if (e is Map<String, dynamic>) return e['file']?.toString();
            return null;
          })
          .whereType<String>()
          .toList(),
      digitGifPath: (json['digit']?['gifPath'] ?? json['digitGifPath']) as String?,
      digitImageFormat: (json['digit']?['format'] ?? json['digitImageFormat']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kind': kind.name,
      'borderRadius': borderRadius,
      'paddingHorizontal': paddingHorizontal,
      'paddingVertical': paddingVertical,
      if (paddingPreset != null) 'paddingPreset': paddingPreset,
      'alignment': alignment.name,
      'blurSigmaX': blurSigmaX,
      'blurSigmaY': blurSigmaY,
      'backgroundColor': _colorToHex(backgroundColor),
      'backgroundOpacityMultiplier': backgroundOpacityMultiplier,
      'tintColor': _colorToHex(tintColor),
      'tintOpacityMultiplier': tintOpacityMultiplier,
      if (backgroundImagePath != null) 'backgroundImage': backgroundImagePath,
      if (overlayImagePath != null) 'overlayImage': overlayImagePath,
      'overlayOpacityMultiplier': overlayOpacityMultiplier,
      if (digitSpacing != null) 'digitSpacing': digitSpacing,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontFiles != null) 'fonts': fontFiles,
      if (digitGifPath != null) 'digitGifPath': digitGifPath,
      if (digitImageFormat != null) 'digitImageFormat': digitImageFormat,
    };
  }

  ThemeDefinition copyWith({
    String? id,
    String? name,
    ThemeKind? kind,
    double? borderRadius,
    double? paddingHorizontal,
    double? paddingVertical,
    String? paddingPreset,
    LayoutAlignment? alignment,
    double? blurSigmaX,
    double? blurSigmaY,
    Color? backgroundColor,
    double? backgroundOpacityMultiplier,
    Color? tintColor,
    double? tintOpacityMultiplier,
    String? backgroundImagePath,
    String? overlayImagePath,
    double? overlayOpacityMultiplier,
    double? digitSpacing,
    String? fontFamily,
    List<String>? fontFiles,
    String? digitGifPath,
    String? digitImageFormat,
    String? assetsBasePath,
  }) {
    return ThemeDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      borderRadius: borderRadius ?? this.borderRadius,
      paddingHorizontal: paddingHorizontal ?? this.paddingHorizontal,
      paddingVertical: paddingVertical ?? this.paddingVertical,
      paddingPreset: paddingPreset ?? this.paddingPreset,
      alignment: alignment ?? this.alignment,
      blurSigmaX: blurSigmaX ?? this.blurSigmaX,
      blurSigmaY: blurSigmaY ?? this.blurSigmaY,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundOpacityMultiplier:
          backgroundOpacityMultiplier ?? this.backgroundOpacityMultiplier,
      tintColor: tintColor ?? this.tintColor,
      tintOpacityMultiplier: tintOpacityMultiplier ?? this.tintOpacityMultiplier,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      overlayImagePath: overlayImagePath ?? this.overlayImagePath,
      overlayOpacityMultiplier:
          overlayOpacityMultiplier ?? this.overlayOpacityMultiplier,
      digitSpacing: digitSpacing ?? this.digitSpacing,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFiles: fontFiles ?? this.fontFiles,
      digitGifPath: digitGifPath ?? this.digitGifPath,
      digitImageFormat: digitImageFormat ?? this.digitImageFormat,
      assetsBasePath: assetsBasePath ?? this.assetsBasePath,
    );
  }

  static ThemeKind _parseKind(String? raw) {
    switch (raw) {
      case 'blur':
        return ThemeKind.blur;
      case 'solid':
        return ThemeKind.solid;
      case 'transparent':
      default:
        return ThemeKind.transparent;
    }
  }

  static LayoutAlignment _parseAlignment(String? raw) {
    switch (raw) {
      case 'left':
        return LayoutAlignment.left;
      case 'right':
        return LayoutAlignment.right;
      case 'center':
      default:
        return LayoutAlignment.center;
    }
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceFirst('#', '').toUpperCase();
    final buffer = StringBuffer(cleaned.length == 6 ? 'FF$cleaned' : cleaned);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}
