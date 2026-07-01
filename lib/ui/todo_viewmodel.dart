import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/category.dart';
import '../data/task.dart';
import '../data/task_database.dart' hide Category, Task;
import '../data/task_dao.dart';
import '../utils/slug.dart';
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
  Timer? _toastTimer;

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

    ref.onDispose(() => _toastTimer?.cancel());

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
    final current = state.requireValue;
    final task = current.tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(done: !task.done);
    await _dao.updateTask(updated);
    final newTasks = current.tasks.map((t) => t.id == id ? updated : t).toList();
    state = AsyncValue.data(
      current.copyWith(tasks: newTasks, animatingIds: {...current.animatingIds, id}),
    );
    Future.delayed(const Duration(milliseconds: 420), () {
      if (state.hasValue) {
        final s = state.requireValue;
        state = AsyncValue.data(
          s.copyWith(animatingIds: Set.from(s.animatingIds)..remove(id)),
        );
      }
    });
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
    ));
    _showToast('đã thêm');
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
    state = AsyncValue.data(current.copyWith(
      activeTab: tab,
      categoryFilter: const AllCategories(),
    ));
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

  Future<void> addCategory(String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final slug = toSlug(trimmed);
    final s = state.requireValue;
    if (s.categories.any((c) => c.slug == slug)) return;
    final cat = Category(slug: slug, label: trimmed);
    await _dao.insertCategory(cat);
    state = AsyncValue.data(s.copyWith(
      categories: [...s.categories, cat],
    ));
    _showToast('+ "$trimmed"');
  }

  Future<void> deleteCategory(String slug) async {
    final s = state.requireValue;
    final affected = s.tasks.where((t) => t.categorySlug == slug).toList();
    for (final t in affected) {
      final cleared = t.copyWith(clearCategorySlug: true);
      await _dao.updateTask(cleared);
    }
    await _dao.deleteCategory(slug);
    final updatedTasks = s.tasks
        .map((t) => t.categorySlug == slug ? t.copyWith(clearCategorySlug: true) : t)
        .toList();
    final updatedFilter = (s.categoryFilter is SpecificCategory &&
            (s.categoryFilter as SpecificCategory).slug == slug)
        ? const AllCategories()
        : s.categoryFilter;
    state = AsyncValue.data(s.copyWith(
      tasks: updatedTasks,
      categories: s.categories.where((c) => c.slug != slug).toList(),
      categoryFilter: updatedFilter,
    ));
    _showToast('category đã xoá');
  }

  void _showToast(String message) {
    final s = state.requireValue;
    state = AsyncValue.data(s.copyWith(toastMessage: message));
    _scheduleToastDismiss();
  }

  void _scheduleToastDismiss() {
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1800), dismissToast);
  }
}
