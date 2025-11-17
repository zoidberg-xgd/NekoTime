import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  File? _logFile;
  bool _initialized = false;
  final int _maxLogSize = 5 * 1024 * 1024; // 5MB
  final int _maxBackupFiles = 3;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final supportDir = await getApplicationSupportDirectory();
      final logsDir = Directory(p.join(supportDir.path, 'logs'));
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      _logFile = File(p.join(logsDir.path, 'app.log'));

      // 检查日志文件大小，如果太大则轮转
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > _maxLogSize) {
          await _rotateLogFile();
        }
      }

      _initialized = true;
      await info('LogService initialized. Log file: ${_logFile!.path}');
    } catch (e) {
      debugPrint('Failed to initialize LogService: $e');
    }
  }

  Future<void> _rotateLogFile() async {
    if (_logFile == null || !await _logFile!.exists()) return;

    try {
      // 删除最旧的备份
      final oldestBackup = File('${_logFile!.path}.$_maxBackupFiles');
      if (await oldestBackup.exists()) {
        await oldestBackup.delete();
      }

      // 轮转备份文件
      for (int i = _maxBackupFiles - 1; i > 0; i--) {
        final oldFile = File('${_logFile!.path}.$i');
        if (await oldFile.exists()) {
          await oldFile.rename('${_logFile!.path}.${i + 1}');
        }
      }

      // 将当前日志文件重命名为 .1
      await _logFile!.rename('${_logFile!.path}.1');

      // 创建新的日志文件
      _logFile = File(_logFile!.path);
    } catch (e) {
      debugPrint('Failed to rotate log file: $e');
    }
  }

  Future<void> _write(String level, String message,
      {Object? error, StackTrace? stackTrace}) async {
    if (!_initialized || _logFile == null) {
      debugPrint('[$level] $message');
      return;
    }

    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = StringBuffer();
      logEntry.writeln('[$timestamp] [$level] $message');

      if (error != null) {
        logEntry.writeln('Error: $error');
      }

      if (stackTrace != null) {
        logEntry.writeln('StackTrace:\n$stackTrace');
      }

      logEntry.writeln('---');

      await _logFile!.writeAsString(
        logEntry.toString(),
        mode: FileMode.append,
        flush: true,
      );

      // 同时输出到控制台
      debugPrint('[$level] $message');
      if (error != null) debugPrint('Error: $error');
    } catch (e) {
      debugPrint('Failed to write log: $e');
    }
  }

  Future<void> debug(String message) async {
    await _write('DEBUG', message);
  }

  Future<void> info(String message) async {
    await _write('INFO', message);
  }

  Future<void> warning(String message, {Object? error}) async {
    await _write('WARNING', message, error: error);
  }

  Future<void> error(String message,
      {Object? error, StackTrace? stackTrace}) async {
    await _write('ERROR', message, error: error, stackTrace: stackTrace);
  }

  Future<String?> getLogFilePath() async {
    if (!_initialized) await init();
    return _logFile?.path;
  }

  Future<String> readLogs({int? maxLines}) async {
    if (!_initialized || _logFile == null) {
      return 'Log service not initialized';
    }

    try {
      if (!await _logFile!.exists()) {
        return 'Log file not found';
      }

      final lines = await _logFile!.readAsLines();

      if (maxLines != null && lines.length > maxLines) {
        return lines.sublist(lines.length - maxLines).join('\n');
      }

      return lines.join('\n');
    } catch (e) {
      return 'Failed to read logs: $e';
    }
  }

  Future<void> clearLogs() async {
    if (!_initialized || _logFile == null) return;

    try {
      if (await _logFile!.exists()) {
        await _logFile!.delete();
        _logFile = File(_logFile!.path);
      }
      await info('Logs cleared');
    } catch (e) {
      debugPrint('Failed to clear logs: $e');
    }
  }

  Future<Directory?> getLogsDirectory() async {
    if (!_initialized) await init();
    return _logFile?.parent;
  }
}
