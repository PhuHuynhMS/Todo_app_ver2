import 'package:drift/drift.dart';
import '../data/category.dart' as model;
import '../data/task.dart' as model;
import 'task_database.dart';

class TaskDao {
  final AppDatabase _db;
  TaskDao(this._db);

  Future<List<model.Category>> getAllCategories() async {
    final rows = await _db.select(_db.categories).get();
    return rows.map((r) => model.Category(slug: r.slug, label: r.label)).toList();
  }

  Future<void> insertCategory(model.Category cat) async {
    await _db.into(_db.categories).insertOnConflictUpdate(
      CategoriesCompanion.insert(slug: cat.slug, label: cat.label),
    );
  }

  Future<List<model.Task>> getAllTasks() async {
    final rows = await (_db.select(_db.tasks)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
    return rows.map(_rowToTask).toList();
  }

  Future<void> insertTask(model.Task task) async {
    await _db.into(_db.tasks).insert(TasksCompanion.insert(
      taskText: task.text,
      done: Value(task.done),
      categorySlug: Value(task.categorySlug),
      priority: task.priority.name,
      timeLabel: Value(task.timeLabel),
    ));
  }

  Future<void> updateTask(model.Task task) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(
        done: Value(task.done),
        categorySlug: Value(task.categorySlug),
      ),
    );
  }

  Future<void> deleteTask(int id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  model.Task _rowToTask(Task row) => model.Task(
    id: row.id,
    text: row.taskText,
    done: row.done,
    categorySlug: row.categorySlug,
    priority: model.TaskPriority.values.byName(row.priority),
    timeLabel: row.timeLabel,
  );
}
