import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:neko_time/core/models/theme_definition.dart';
import 'package:neko_time/core/services/config_service.dart';
import 'package:neko_time/core/services/log_service.dart';
import 'package:neko_time/core/services/theme_service.dart';
import 'package:neko_time/ui/widgets/log_viewer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:neko_time/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = context.watch<ConfigService>();
    final themeService = context.watch<ThemeService>();
    final config = configService.config;
    final l10n = AppLocalizations.of(context)!;
    final themes = themeService.themes;

    return Dialog(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: const Color.fromRGBO(158, 158, 158, 0.15),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.theme,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => themeService.reload(),
                      child: Text(l10n.themeReload),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final theme in themes)
                      ChoiceChip(
                        label: Text(
                          _localizedThemeName(l10n, theme),
                        ),
                        selected: config.themeId == theme.id,
                        onSelected: (_) => configService.setTheme(theme.id),
                      ),
                  ],
                ),
                if (themeService.themesDirectoryPath != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.themeFolderHint(
                            themeService.themesDirectoryPath!,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        tooltip: '复制路径',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: themeService.themesDirectoryPath!,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('路径已复制'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.folder_open, size: 16),
                        tooltip: '打开文件夹',
                        onPressed: () {
                          Process.run('open', [themeService.themesDirectoryPath!]);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(l10n.opacity),
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
                    Text(l10n.scale),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const LogViewerDialog(),
                        );
                      },
                      icon: const Icon(Icons.description),
                      label: const Text('查看日志'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final logService = LogService();
                        final logsDir = await logService.getLogsDirectory();
                        if (logsDir != null) {
                          Process.run('open', [logsDir.path]);
                        }
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text('打开日志文件夹'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _localizedThemeName(
  AppLocalizations l10n,
  ThemeDefinition theme,
) {
  return theme.name;
}
