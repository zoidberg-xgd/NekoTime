import 'dart:async';

class TimeService {
  // 提供一个每秒更新一次的时间流
  Stream<DateTime> get timeStream =>
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

  // 将时间格式化为数字和冒号的列表 (HH:MM)
  List<String> formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');

    List<String> parts = [];
    parts.addAll(hours.split(''));
    parts.add(':');
    parts.addAll(minutes.split(''));

    return parts;
  }
}
