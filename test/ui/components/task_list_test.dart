import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart' hide Category, Task;
import 'package:todo/ui/components/task_list.dart';
import 'package:todo/ui/todo_state.dart';
import 'package:todo/ui/todo_viewmodel.dart';

Widget buildList(TodoState state) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(home: Scaffold(body: TaskList(state: state))),
  );
}

TodoState make(List<Task> tasks) => TodoState(
  tasks: tasks, categories: seedCategories.toList(),
  activeTab: ActiveTab.pending, categoryFilter: const AllCategories(),
  inputText: '', toastMessage: null,
);

void main() {
  testWidgets('section labels when high priority exists', (t) async {
    await t.pumpWidget(buildList(make([
      const Task(id:1, text:'A', done:false, categorySlug:null, priority:TaskPriority.high, timeLabel:null),
      const Task(id:2, text:'B', done:false, categorySlug:null, priority:TaskPriority.low,  timeLabel:null),
    ])));
    expect(find.text('ƯU TIÊN CAO'), findsOneWidget);
    expect(find.text('CÒN LẠI'),    findsOneWidget);
  });

  testWidgets('empty state message for pending', (t) async {
    await t.pumpWidget(buildList(make([])));
    expect(find.text('không có việc gì'), findsOneWidget);
  });

  testWidgets('renders task text', (t) async {
    await t.pumpWidget(buildList(make([
      const Task(id:1, text:'Task one', done:false, categorySlug:null, priority:TaskPriority.low, timeLabel:null),
    ])));
    await t.pump();
    expect(find.text('Task one'), findsOneWidget);
  });
}
