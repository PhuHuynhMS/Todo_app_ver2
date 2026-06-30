import '../data/category.dart';
import '../data/task.dart';

String? detectCategory(String text, List<Category> categories) {
  final t = text.toLowerCase();
  if (RegExp(r'mua|chợ|siêu thị|order', caseSensitive: false).hasMatch(t)) return 'buy';
  if (RegExp(r'họp|pr|deploy|code|review|api|bug|spec', caseSensitive: false).hasMatch(t)) return 'work';
  if (RegExp(r'gọi|điện|nhà|gia đình|bạn', caseSensitive: false).hasMatch(t)) return 'personal';
  if (RegExp(r'investor|startup|deck|pitch|fund', caseSensitive: false).hasMatch(t)) return 'startup';
  for (final cat in categories) {
    if (t.contains(cat.slug) || t.contains(cat.label.toLowerCase())) return cat.slug;
  }
  return null;
}

TaskPriority detectPriority(String text) {
  if (RegExp(r'gấp|urgent|quan trọng|ngay|trước|deadline', caseSensitive: false).hasMatch(text)) {
    return TaskPriority.high;
  }
  if (RegExp(r'hôm nay|today|lúc \d', caseSensitive: false).hasMatch(text)) {
    return TaskPriority.mid;
  }
  return TaskPriority.low;
}
