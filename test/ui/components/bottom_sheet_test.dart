import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/task_database.dart';
import 'package:todo/ui/components/bottom_sheet.dart';
import 'package:todo/ui/todo_viewmodel.dart';

Widget buildSheet() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: const MaterialApp(home: Scaffold(body: TaskBottomSheet())),
  );
}

void main() {
  testWidgets('renders hint text', (t) async {
    await t.pumpWidget(buildSheet());
    expect(find.text('thêm việc cần làm...'), findsOneWidget);
  });

  testWidgets('renders + prefix', (t) async {
    await t.pumpWidget(buildSheet());
    expect(find.text('+'), findsOneWidget);
  });
}
