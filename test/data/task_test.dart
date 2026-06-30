import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/category.dart';

void main() {
  group('Task.copyWith', () {
    const task = Task(
      id: 1, text: 'test', done: false,
      categorySlug: 'work', priority: TaskPriority.high, timeLabel: '9:00',
    );

    test('toggles done', () {
      final t = task.copyWith(done: true);
      expect(t.done, true);
      expect(t.id, 1);
      expect(t.text, 'test');
    });

    test('preserves unmodified fields', () {
      final t = task.copyWith(done: true);
      expect(t.categorySlug, 'work');
      expect(t.priority, TaskPriority.high);
      expect(t.timeLabel, '9:00');
    });

    test('seed tasks count', () => expect(seedTasks.length, 6));
    test('seed categories count', () => expect(seedCategories.length, 4));
  });
}
