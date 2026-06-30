import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/category.dart';
import '../data/task.dart';
import '../data/task_database.dart' hide Category, Task;
import '../data/task_dao.dart';
import '../utils/task_auto_detect.dart';
import 'todo_state.dart';

part 'todo_viewmodel.g.dart';

@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@riverpod
class TodoViewmodel extends _$TodoViewmodel {
  TaskDao get _dao => TaskDao(ref.read(appDatabaseProvider));

  @override
  Future<TodoState> build() async {
    final dao = _dao;
    var tasks = await dao.getAllTasks();
    var cats  = await dao.getAllCategories();

    if (cats.isEmpty) {
      for (final c in seedCategories) {
        await dao.insertCategory(c);
      }
      for (final t in seedTasks) {
        await dao.insertTask(t);
      }
      tasks = await dao.getAllTasks();
      cats  = await dao.getAllCategories();
    }

    return TodoState(
      tasks: tasks,
      categories: cats,
      activeTab: ActiveTab.pending,
      categoryFilter: const AllCategories(),
      inputText: '',
      toastMessage: null,
    );
  }

  Future<void> toggleTask(int id) async {
    final current = state.value!;
    final task = current.tasks.firstWhere((t) => t.id == id);
    final toggled = task.copyWith(done: !task.done);
    await _dao.updateTask(toggled);
    state = AsyncValue.data(current.copyWith(
      tasks: current.tasks.map((t) => t.id == id ? toggled : t).toList(),
    ));
  }

  Future<void> addTask(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final current = state.value!;
    await _dao.insertTask(Task(
      id: 0,
      text: trimmed,
      done: false,
      categorySlug: detectCategory(trimmed, current.categories),
      priority: detectPriority(trimmed),
      timeLabel: null,
    ));
    final tasks = await _dao.getAllTasks();
    state = AsyncValue.data(current.copyWith(
      tasks: tasks,
      inputText: '',
      toastMessage: 'đã thêm',
    ));
    _scheduleToastDismiss();
  }

  Future<void> deleteTask(int id) async {
    await _dao.deleteTask(id);
    final current = state.value!;
    state = AsyncValue.data(current.copyWith(
      tasks: current.tasks.where((t) => t.id != id).toList(),
    ));
  }

  void updateInput(String text) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(inputText: text));
  }

  void switchTab(ActiveTab tab) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(activeTab: tab));
  }

  void filterByCategory(CategoryFilter filter) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(categoryFilter: filter));
  }

  void dismissToast() {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(clearToast: true));
  }

  // Stubs — implemented in later features
  Future<void> addCategory(String label) async {}
  Future<void> deleteCategory(String slug) async {}

  void _scheduleToastDismiss() {
    Future.delayed(const Duration(milliseconds: 1800), dismissToast);
  }
}
