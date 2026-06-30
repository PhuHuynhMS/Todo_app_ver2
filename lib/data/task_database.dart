import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'task_database.g.dart';

class Categories extends Table {
  TextColumn get slug  => text()();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {slug};
}

class Tasks extends Table {
  IntColumn get id           => integer().autoIncrement()();
  TextColumn get taskText    => text().named('text')();
  BoolColumn get done        => boolean().withDefault(const Constant(false))();
  TextColumn get categorySlug => text().nullable()();
  TextColumn get priority    => text()();
  TextColumn get timeLabel   => text().nullable()();
}

@DriftDatabase(tables: [Categories, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'todo.db'));
    return NativeDatabase.createInBackground(file);
  });
}
