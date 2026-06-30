import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart' hide Category, Task;
import 'package:todo/data/task_dao.dart';

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = TaskDao(db);
  });
  tearDown(() async => db.close());

  test('getAllCategories returns empty initially', () async {
    expect(await dao.getAllCategories(), isEmpty);
  });

  test('insertCategory and getAllCategories', () async {
    await dao.insertCategory(const Category(slug: 'work', label: 'work'));
    final cats = await dao.getAllCategories();
    expect(cats.length, 1);
    expect(cats.first.slug, 'work');
  });

  test('insertTask and getAllTasks', () async {
    await dao.insertTask(const Task(
      id: 0, text: 'Test', done: false,
      categorySlug: null, priority: TaskPriority.high, timeLabel: null,
    ));
    final tasks = await dao.getAllTasks();
    expect(tasks.length, 1);
    expect(tasks.first.text, 'Test');
    expect(tasks.first.priority, TaskPriority.high);
  });

  test('updateTask toggles done', () async {
    await dao.insertTask(const Task(
      id: 0, text: 'T', done: false,
      categorySlug: null, priority: TaskPriority.low, timeLabel: null,
    ));
    final tasks = await dao.getAllTasks();
    await dao.updateTask(tasks.first.copyWith(done: true));
    final updated = await dao.getAllTasks();
    expect(updated.first.done, true);
  });

  test('deleteTask removes it', () async {
    await dao.insertTask(const Task(
      id: 0, text: 'D', done: false,
      categorySlug: null, priority: TaskPriority.low, timeLabel: null,
    ));
    final tasks = await dao.getAllTasks();
    await dao.deleteTask(tasks.first.id);
    expect(await dao.getAllTasks(), isEmpty);
  });
}
