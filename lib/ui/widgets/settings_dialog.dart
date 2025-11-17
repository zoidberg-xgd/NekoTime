import 'dart:ui';

import 'package:digital_clock/core/models/clock_config.dart';
import 'package:digital_clock/core/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = context.watch<ConfigService>();
    final config = configService.config;

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.2),
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: Colors.grey.withOpacity(0.15),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('主题', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('透明'),
                      selected: config.themeStyle == ThemeStyle.transparent,
                      onSelected: (_) => configService.setThemeStyle(ThemeStyle.transparent),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('磨砂玻璃'),
                      selected: config.themeStyle == ThemeStyle.frostedGlass,
                      onSelected: (_) => configService.setThemeStyle(ThemeStyle.frostedGlass),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('水玻璃'),
                      selected: config.themeStyle == ThemeStyle.aquaGlass,
                      onSelected: (_) => configService.setThemeStyle(ThemeStyle.aquaGlass),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('透明度'),
                    Expanded(
                      child: Slider(
                        value: config.opacity.clamp(0.0, 1.0),
                        onChanged: (v) => configService.setOpacity(v),
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                    Text(config.opacity.toStringAsFixed(2)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('缩放'),
                    Expanded(
                      child: Slider(
                        value: config.scale.clamp(0.5, 3.0),
                        onChanged: (v) => configService.setScale(v),
                        min: 0.5,
                        max: 3.0,
                      ),
                    ),
                    Text('${(config.scale * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('显示秒'),
                    const SizedBox(width: 8),
                    Switch(
                      value: config.showSeconds,
                      onChanged: (_) => configService.toggleShowSeconds(),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

