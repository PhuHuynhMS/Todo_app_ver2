import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart' hide Category, Task;
import 'package:todo/ui/todo_state.dart';
import 'package:todo/ui/todo_viewmodel.dart';

ProviderContainer makeContainer() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
  ]);
}

void main() {
  test('initial state loads seed data', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    final state = c.read(todoViewmodelProvider).value!;
    expect(state.tasks.length, 6);
    expect(state.categories.length, 4);
  });

  test('toggleTask flips done', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    await c.read(todoViewmodelProvider.notifier).toggleTask(1);
    final state = c.read(todoViewmodelProvider).value!;
    expect(state.tasks.firstWhere((t) => t.id == 1).done, true);
  });

  test('deleteTask removes task', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    await c.read(todoViewmodelProvider.notifier).deleteTask(1);
    final state = c.read(todoViewmodelProvider).value!;
    expect(state.tasks.length, 5);
    expect(state.tasks.any((t) => t.id == 1), false);
  });

  test('addTask inserts with auto-detect', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    await c.read(todoViewmodelProvider.notifier).addTask('mua đồ gấp');
    final state = c.read(todoViewmodelProvider).value!;
    expect(state.tasks.length, 7);
    final t = state.tasks.firstWhere((t) => t.text == 'mua đồ gấp');
    expect(t.categorySlug, 'buy');
    expect(t.priority, TaskPriority.high);
  });

  test('addTask empty text does nothing', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    await c.read(todoViewmodelProvider.notifier).addTask('   ');
    expect(c.read(todoViewmodelProvider).value!.tasks.length, 6);
  });

  test('addTask sets toast message', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    await c.read(todoViewmodelProvider.notifier).addTask('new task');
    expect(c.read(todoViewmodelProvider).value!.toastMessage, 'đã thêm');
  });

  test('addTask shows toast that is replaced by second add', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    final vm = c.read(todoViewmodelProvider.notifier);

    await vm.addTask('task one');
    expect(c.read(todoViewmodelProvider).value?.toastMessage, 'đã thêm');

    await vm.addTask('task two');
    expect(c.read(todoViewmodelProvider).value?.toastMessage, 'đã thêm');
  });

  test('switchTab changes activeTab', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    final vm = c.read(todoViewmodelProvider.notifier);

    vm.switchTab(ActiveTab.done);
    expect(c.read(todoViewmodelProvider).value?.activeTab, ActiveTab.done);
  });

  test('filterByCategory filters tasks', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(todoViewmodelProvider.future);
    final vm = c.read(todoViewmodelProvider.notifier);

    vm.filterByCategory(const SpecificCategory('work'));
    final state = c.read(todoViewmodelProvider).value!;
    expect(state.categoryFilter, isA<SpecificCategory>());
    for (final task in state.filtered) {
      expect(task.categorySlug, 'work');
    }
  });
}
