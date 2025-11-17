import 'dart:io';
import 'package:neko_time/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogViewerDialog extends StatefulWidget {
  const LogViewerDialog({super.key});

  @override
  State<LogViewerDialog> createState() => _LogViewerDialogState();
}

class _LogViewerDialogState extends State<LogViewerDialog> {
  String _logs = '加载中...';
  bool _autoRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await LogService().readLogs(maxLines: 500);
      if (mounted) {
        setState(() {
          _logs = logs;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logs = '加载日志失败: $e';
        });
      }
    }
  }

  Future<void> _clearLogs() async {
    try {
      await LogService().clearLogs();
      await _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志已清空')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空日志失败: $e')),
        );
      }
    }
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _logs));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日志已复制到剪贴板')),
      );
    }
  }

  Future<void> _openLogsFolder() async {
    final logsDir = await LogService().getLogsDirectory();
    if (logsDir != null) {
      Process.run('open', [logsDir.path]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '应用日志',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadLogs,
                  tooltip: '刷新',
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open, color: Colors.white),
                  onPressed: _openLogsFolder,
                  tooltip: '打开日志文件夹',
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: _copyLogs,
                  tooltip: '复制全部',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认'),
                        content: const Text('确定要清空所有日志吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _clearLogs();
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: '清空日志',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  tooltip: '关闭',
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  _logs,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _autoRefresh,
                  onChanged: (value) {
                    setState(() {
                      _autoRefresh = value ?? false;
                    });
                    if (_autoRefresh) {
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted && _autoRefresh) {
                          _loadLogs();
                        }
                      });
                    }
                  },
                ),
                const Text(
                  '自动刷新 (每2秒)',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  '显示最后 500 行',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
