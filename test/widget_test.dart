import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/task_database.dart' hide Category, Task;
import 'package:todo/ui/todo_screen.dart';
import 'package:todo/ui/todo_viewmodel.dart';

void main() {
  testWidgets('TodoScreen renders seed tasks', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TodoScreen()),
      ),
    );
    await tester.pump(); // start async load
    await tester.pumpAndSettle(); // complete
    expect(find.text('Review PR trước 11h'), findsOneWidget);
    await db.close();
  });
}
