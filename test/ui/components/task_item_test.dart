import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart' hide Category, Task;
import 'package:todo/ui/components/task_item.dart';
import 'package:todo/ui/todo_viewmodel.dart';

Widget buildItem(Task task, [List<Category>? cats]) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: TaskItem(task: task, categories: cats ?? seedCategories.toList()),
      ),
    ),
  );
}

void main() {
  const task = Task(
    id: 1, text: 'Test task', done: false,
    categorySlug: 'work', priority: TaskPriority.high, timeLabel: '9:00',
  );

  testWidgets('renders task text', (t) async {
    await t.pumpWidget(buildItem(task));
    expect(find.text('Test task'), findsOneWidget);
  });

  testWidgets('renders time label', (t) async {
    await t.pumpWidget(buildItem(task));
    expect(find.text('9:00'), findsOneWidget);
  });

  testWidgets('renders category chip', (t) async {
    await t.pumpWidget(buildItem(task));
    expect(find.text('work'), findsOneWidget);
  });

  testWidgets('done task renders text', (t) async {
    const done = Task(
      id: 2, text: 'Done task', done: true,
      categorySlug: null, priority: TaskPriority.low, timeLabel: null,
    );
    await t.pumpWidget(buildItem(done, []));
    expect(find.text('Done task'), findsOneWidget);
  });
}
