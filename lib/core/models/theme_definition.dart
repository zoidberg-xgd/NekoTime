import 'dart:ui';

enum ThemeKind { transparent, blur, solid }

class ThemeDefinition {
  static const defaultThemeId = 'transparent';

  final String id;
  final String name;
  final ThemeKind kind;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final double blurSigmaX;
  final double blurSigmaY;
  final Color? backgroundColor;
  final double backgroundOpacityMultiplier;
  final Color? tintColor;
  final double tintOpacityMultiplier;

  const ThemeDefinition({
    required this.id,
    required this.name,
    required this.kind,
    this.borderRadius = 0,
    this.paddingHorizontal = 16,
    this.paddingVertical = 8,
    this.blurSigmaX = 0,
    this.blurSigmaY = 0,
    this.backgroundColor,
    this.backgroundOpacityMultiplier = 1,
    this.tintColor,
    this.tintOpacityMultiplier = 1,
  });

  factory ThemeDefinition.fromJson(Map<String, dynamic> json) {
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
      blurSigmaX:
          (json['blur']?['sigmaX'] ?? json['blurSigmaX'] ?? 0).toDouble(),
      blurSigmaY:
          (json['blur']?['sigmaY'] ?? json['blurSigmaY'] ?? 0).toDouble(),
      backgroundColor: _colorFromHex(json['backgroundColor'] as String?),
      backgroundOpacityMultiplier:
          (json['backgroundOpacityMultiplier'] ?? 1).toDouble(),
      tintColor: _colorFromHex(json['tintColor'] as String?),
      tintOpacityMultiplier: (json['tintOpacityMultiplier'] ?? 1).toDouble(),
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
      'blurSigmaX': blurSigmaX,
      'blurSigmaY': blurSigmaY,
      'backgroundColor': _colorToHex(backgroundColor),
      'backgroundOpacityMultiplier': backgroundOpacityMultiplier,
      'tintColor': _colorToHex(tintColor),
      'tintOpacityMultiplier': tintOpacityMultiplier,
    };
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
