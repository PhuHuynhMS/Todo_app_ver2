# Core Task List — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a runnable Flutter Todo app implementing the core task list — task display with seed data, toggle done, delete, add task, and toast feedback — per `todo-flutter-spec.md` v3.

**Architecture:** Foundation-first within a feature-by-feature strategy. Drift DB and models are established first, then Riverpod ViewModel, then UI components. Placeholders stand in for StatusBar, Header, TagFilterRow, and TabBar (implemented in later features).

**Tech Stack:** Flutter 3+, Dart, Drift 2.x (SQLite ORM), Riverpod 2.x with code generation, intl, phosphor_flutter, path_provider, path

## Global Constraints

- Android-first, `minSdkVersion 26`
- Dark only — no light theme, no dark mode toggle
- Fonts: IBMPlexMono (300/300i/400/500) + Inter (300/400/500/600)
- No Material Checkbox, no `TextDecoration.lineThrough`, no InkWell ripple, no elevation/shadows
- No FloatingActionButton, AppBar, BottomNavigationBar, SnackBar, showModalBottomSheet
- No swipe-to-delete — long press only
- `TaskTag` enum removed — use `String? categorySlug`
- All colors from `AppColors`, all text from `AppText`, all spacing from `AppDim`
- Strikethrough via `StrikethroughPainter` only
- Checkmark via `CheckmarkPainter` only
- `InkWell.splashColor = Colors.transparent` everywhere (prefer `GestureDetector`)

---

### Task 1: Project Setup & Dependencies

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle`
- Create: `assets/fonts/` (8 font files — manual step)
- Modify: `lib/main.dart` (strip boilerplate)

**Interfaces:**
- Produces: Runnable Flutter scaffold, all packages available via `flutter pub get`

- [ ] **Step 1: Scaffold Flutter project**

In PowerShell at `D:\Projects\Android\TODO`:
```powershell
flutter create . --project-name todo --org com.example --platforms android
```
Expected: Flutter scaffold created. Existing `docs/` and spec files are preserved.

- [ ] **Step 2: Replace `pubspec.yaml`**

```yaml
name: todo
description: Flutter Todo App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  intl: ^0.19.0
  phosphor_flutter: ^2.1.0
  path_provider: ^2.1.3
  path: ^1.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0

flutter:
  fonts:
    - family: IBMPlexMono
      fonts:
        - asset: assets/fonts/IBMPlexMono-Light.ttf
          weight: 300
        - asset: assets/fonts/IBMPlexMono-LightItalic.ttf
          weight: 300
          style: italic
        - asset: assets/fonts/IBMPlexMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/IBMPlexMono-Medium.ttf
          weight: 500
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Light.ttf
          weight: 300
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
  uses-material-design: true
```

- [ ] **Step 3: Set minSdkVersion**

In `android/app/build.gradle`, find the `defaultConfig` block and set:
```gradle
minSdkVersion 26
```

- [ ] **Step 4: Place font files**

Copy 8 font files into `assets/fonts/`:
- `IBMPlexMono-Light.ttf`, `IBMPlexMono-LightItalic.ttf`, `IBMPlexMono-Regular.ttf`, `IBMPlexMono-Medium.ttf`
- `Inter-Light.ttf`, `Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`

Sources: IBM Plex Mono from fonts.google.com, Inter from rsms.me/inter.

- [ ] **Step 5: Install dependencies**

```powershell
flutter pub get
```
Expected: "Got dependencies!" with no errors.

- [ ] **Step 6: Strip `lib/main.dart`**

Replace entire file with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MaterialApp(home: Scaffold())));
}
```

- [ ] **Step 7: Verify it compiles**

```powershell
flutter build apk --debug
```
Expected: Build succeeds. No errors.

- [ ] **Step 8: Commit**

```powershell
git add pubspec.yaml pubspec.lock android/app/build.gradle assets/fonts/ lib/main.dart
git commit -m "feat: scaffold Flutter project with dependencies and fonts"
```

---

### Task 2: Theme Tokens

**Files:**
- Create: `lib/theme/colors.dart`
- Create: `lib/theme/text_styles.dart`

**Interfaces:**
- Produces: `AppColors`, `AppText`, `AppDim` — compile-time constants, imported by all UI files

No tests — pure constants, verified by compilation.

- [ ] **Step 1: Create `lib/theme/colors.dart`**

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg         = Color(0xFF111111);
  static const surface    = Color(0xFF191919);
  static const surface2   = Color(0xFF222222);
  static const surface3   = Color(0xFF2A2A2A);
  static const border     = Color(0xFF282828);

  static const text       = Color(0xFFE4DDD4);
  static const textDim    = Color(0xFF5A5550);
  static const textDim2   = Color(0xFF3D3A37);

  static const accent     = Color(0xFFC9A96E);
  static const accentDim  = Color(0xFF7A6440);
  static const accentGlow = Color(0x1FC9A96E);

  static const doneText   = Color(0xFF3E3B38);
  static const red        = Color(0xFFB85A45);
  static const pressHold  = Color(0x0AB85A45);
}
```

- [ ] **Step 2: Create `lib/theme/text_styles.dart`**

```dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppText {
  static const taskText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 14.5, fontWeight: FontWeight.w400,
    color: AppColors.text, height: 1.5,
  );
  static const metaText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim2,
  );
  static const tagText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 10.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.25,
  );
  static const labelText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9, fontWeight: FontWeight.w400,
    color: AppColors.textDim2, letterSpacing: 1.8,
  );
  static const tabText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );
  static const inputText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 13.5, fontWeight: FontWeight.w400,
    color: AppColors.text,
  );
  static const title = TextStyle(
    fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w600,
    color: AppColors.text, letterSpacing: -1.0,
  );
  static const dateLabel = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 10, fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic, color: AppColors.textDim, letterSpacing: 0.8,
  );
  static const taskCount = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.3,
  );
  static const statusTime = TextStyle(
    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.text, letterSpacing: -0.4,
  );
  static const progressLabel = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.3,
  );
  static const progressPct = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.accentDim, letterSpacing: 0.3,
  );
}

class AppDim {
  static const screenPadH = 24.0;
  static const taskPadV   = 13.0;
  static const radiusSm   = 3.0;
  static const radiusMd   = 12.0;
  static const radiusLg   = 100.0;
  static const borderW    = 1.0;
  static const progressH  = 1.5;
  static const dotSize    = 5.0;
  static const checkboxSz = 19.0;
  static const addBtnSz   = 41.0;
}
```

- [ ] **Step 3: Commit**

```powershell
git add lib/theme/
git commit -m "feat: add AppColors, AppText, AppDim theme tokens"
```

---

### Task 3: Data Models

**Files:**
- Create: `lib/data/category.dart`
- Create: `lib/data/task.dart`
- Create: `test/data/task_test.dart`

**Interfaces:**
- Produces:
  - `Category({required String slug, required String label})`
  - `List<Category> seedCategories` (4 items)
  - `enum TaskPriority { high, mid, low }`
  - `Task({required int id, required String text, required bool done, String? categorySlug, required TaskPriority priority, String? timeLabel})`
  - `Task copyWith({bool? done, String? categorySlug})`
  - `List<Task> seedTasks` (6 items)

- [ ] **Step 1: Write failing test**

Create `test/data/task_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/category.dart';

void main() {
  group('Task.copyWith', () {
    const task = Task(
      id: 1, text: 'test', done: false,
      categorySlug: 'work', priority: TaskPriority.high, timeLabel: '9:00',
    );

    test('toggles done', () {
      final t = task.copyWith(done: true);
      expect(t.done, true);
      expect(t.id, 1);
      expect(t.text, 'test');
    });

    test('preserves unmodified fields', () {
      final t = task.copyWith(done: true);
      expect(t.categorySlug, 'work');
      expect(t.priority, TaskPriority.high);
      expect(t.timeLabel, '9:00');
    });

    test('seed tasks count', () => expect(seedTasks.length, 6));
    test('seed categories count', () => expect(seedCategories.length, 4));
  });
}
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/data/task_test.dart
```
Expected: FAIL — `package:todo/data/task.dart` not found.

- [ ] **Step 3: Create `lib/data/category.dart`**

```dart
class Category {
  final String slug;
  final String label;

  const Category({required this.slug, required this.label});
}

const seedCategories = [
  Category(slug: 'work',     label: 'work'),
  Category(slug: 'personal', label: 'cá nhân'),
  Category(slug: 'startup',  label: 'startup'),
  Category(slug: 'buy',      label: 'mua đồ'),
];
```

- [ ] **Step 4: Create `lib/data/task.dart`**

```dart
enum TaskPriority { high, mid, low }

class Task {
  final int id;
  final String text;
  final bool done;
  final String? categorySlug;
  final TaskPriority priority;
  final String? timeLabel;

  const Task({
    required this.id,
    required this.text,
    required this.done,
    this.categorySlug,
    required this.priority,
    this.timeLabel,
  });

  Task copyWith({bool? done, String? categorySlug}) => Task(
    id: id,
    text: text,
    done: done ?? this.done,
    categorySlug: categorySlug ?? this.categorySlug,
    priority: priority,
    timeLabel: timeLabel,
  );
}

const seedTasks = [
  Task(id:1, text:'Review PR trước 11h',      done:false, categorySlug:'work',     priority:TaskPriority.high, timeLabel:'9:00'),
  Task(id:2, text:'Họp sync team lúc 2h',      done:false, categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:'14:00'),
  Task(id:3, text:'Mua sữa và trứng',          done:false, categorySlug:'buy',      priority:TaskPriority.low,  timeLabel:null),
  Task(id:4, text:'Viết spec cho feature mới', done:true,  categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:null),
  Task(id:5, text:'Gọi điện cho nhà',          done:false, categorySlug:'personal', priority:TaskPriority.low,  timeLabel:'20:00'),
  Task(id:6, text:'Update deck cho investor',  done:false, categorySlug:'startup',  priority:TaskPriority.high, timeLabel:null),
];
```

- [ ] **Step 5: Run — verify PASS**

```powershell
flutter test test/data/task_test.dart
```
Expected: 4 tests PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/data/ test/data/task_test.dart
git commit -m "feat: add Category and Task models with seed data"
```

---

### Task 4: Utility Functions

**Files:**
- Create: `lib/utils/slug.dart`
- Create: `lib/utils/task_auto_detect.dart`
- Create: `test/utils/slug_test.dart`
- Create: `test/utils/task_auto_detect_test.dart`

**Interfaces:**
- Consumes: `Category` from `lib/data/category.dart`, `TaskPriority` from `lib/data/task.dart`
- Produces:
  - `String toSlug(String label)` — lowercase-hyphen, strips special chars
  - `String? detectCategory(String text, List<Category> categories)` — returns slug or null
  - `TaskPriority detectPriority(String text)` — returns high/mid/low

- [ ] **Step 1: Write failing tests**

Create `test/utils/slug_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/utils/slug.dart';

void main() {
  group('toSlug', () {
    test('lowercases', () => expect(toSlug('Work'), 'work'));
    test('spaces to hyphens', () => expect(toSlug('affi tiktok'), 'affi-tiktok'));
    test('trims whitespace', () => expect(toSlug('  hello  '), 'hello'));
    test('removes special chars', () => expect(toSlug('hello!@#'), 'hello'));
    test('collapses multiple spaces', () => expect(toSlug('a  b'), 'a-b'));
  });
}
```

Create `test/utils/task_auto_detect_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/utils/task_auto_detect.dart';

void main() {
  final categories = seedCategories.toList();

  group('detectCategory', () {
    test('buy from "mua"',       () => expect(detectCategory('mua sữa', categories), 'buy'));
    test('work from "họp"',      () => expect(detectCategory('họp sync', categories), 'work'));
    test('personal from "gọi"',  () => expect(detectCategory('gọi điện', categories), 'personal'));
    test('startup from "investor"', () => expect(detectCategory('gặp investor', categories), 'startup'));
    test('null for unmatched',   () => expect(detectCategory('xyz abc', categories), null));
  });

  group('detectPriority', () {
    test('high for "gấp"',    () => expect(detectPriority('làm gấp'), TaskPriority.high));
    test('high for "urgent"', () => expect(detectPriority('urgent task'), TaskPriority.high));
    test('mid for "hôm nay"', () => expect(detectPriority('làm hôm nay'), TaskPriority.mid));
    test('low for generic',   () => expect(detectPriority('mua bánh'), TaskPriority.low));
  });
}
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/utils/
```
Expected: FAIL — files not found.

- [ ] **Step 3: Create `lib/utils/slug.dart`**

```dart
String toSlug(String label) =>
    label.toLowerCase().trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^\w\-]'), '');
```

- [ ] **Step 4: Create `lib/utils/task_auto_detect.dart`**

```dart
import '../data/category.dart';
import '../data/task.dart';

String? detectCategory(String text, List<Category> categories) {
  final t = text.toLowerCase();
  if (RegExp(r'mua|chợ|siêu thị|order', caseSensitive: false).hasMatch(t)) return 'buy';
  if (RegExp(r'họp|pr|deploy|code|review|api|bug|spec', caseSensitive: false).hasMatch(t)) return 'work';
  if (RegExp(r'gọi|điện|nhà|gia đình|bạn', caseSensitive: false).hasMatch(t)) return 'personal';
  if (RegExp(r'investor|startup|deck|pitch|fund', caseSensitive: false).hasMatch(t)) return 'startup';
  for (final cat in categories) {
    if (t.contains(cat.slug) || t.contains(cat.label.toLowerCase())) return cat.slug;
  }
  return null;
}

TaskPriority detectPriority(String text) {
  if (RegExp(r'gấp|urgent|quan trọng|ngay|trước|deadline', caseSensitive: false).hasMatch(text)) {
    return TaskPriority.high;
  }
  if (RegExp(r'hôm nay|today|lúc \d', caseSensitive: false).hasMatch(text)) {
    return TaskPriority.mid;
  }
  return TaskPriority.low;
}
```

- [ ] **Step 5: Run — verify PASS**

```powershell
flutter test test/utils/
```
Expected: 9 tests PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/utils/ test/utils/
git commit -m "feat: add toSlug and auto-detect category/priority utilities"
```

---

### Task 5: Drift Database

**Files:**
- Create: `lib/data/task_database.dart`
- Create: `lib/data/task_dao.dart`
- Create: `test/data/task_dao_test.dart`

**Interfaces:**
- Consumes: `Task`, `TaskPriority`, `Category` from `lib/data/`
- Produces:
  - `AppDatabase` — Drift DB, opens `todo.db` in documents dir; `AppDatabase.forTesting(QueryExecutor)` for tests
  - `TaskDao(AppDatabase db)` with: `getAllTasks()`, `getAllCategories()`, `insertTask(Task)`, `updateTask(Task)`, `deleteTask(int)`, `insertCategory(Category)`

- [ ] **Step 1: Write failing test**

Create `test/data/task_dao_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart';
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
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/data/task_dao_test.dart
```
Expected: FAIL — `task_database.dart` not found.

- [ ] **Step 3: Create `lib/data/task_database.dart`**

```dart
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
  TextColumn get text        => text()();
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
```

- [ ] **Step 4: Create `lib/data/task_dao.dart`**

```dart
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
    final rows = await _db.select(_db.tasks).get();
    return rows.map(_rowToTask).toList();
  }

  Future<void> insertTask(model.Task task) async {
    await _db.into(_db.tasks).insert(TasksCompanion.insert(
      text: task.text,
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
    text: row.text,
    done: row.done,
    categorySlug: row.categorySlug,
    priority: model.TaskPriority.values.byName(row.priority),
    timeLabel: row.timeLabel,
  );
}
```

- [ ] **Step 5: Run code generation**

```powershell
dart run build_runner build --delete-conflicting-outputs
```
Expected: Generates `lib/data/task_database.g.dart`. "Succeeded after..." message.

- [ ] **Step 6: Run — verify PASS**

```powershell
flutter test test/data/task_dao_test.dart
```
Expected: 5 tests PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/data/task_database.dart lib/data/task_database.g.dart lib/data/task_dao.dart test/data/task_dao_test.dart
git commit -m "feat: add Drift database schema and TaskDao CRUD operations"
```

---

### Task 6: App State

**Files:**
- Create: `lib/ui/todo_state.dart`
- Create: `test/ui/todo_state_test.dart`

**Interfaces:**
- Consumes: `Task`, `TaskPriority`, `Category` from `lib/data/`
- Produces:
  - `enum ActiveTab { pending, done }`
  - `sealed class CategoryFilter` with subtypes `AllCategories`, `SpecificCategory(String slug)`
  - `TodoState({tasks, categories, activeTab, categoryFilter, inputText, toastMessage})`
  - Derived getters: `filtered`, `highPriority`, `restPriority`, `doneCount`, `totalCount`, `pendingCount`
  - `TodoState copyWith({..., bool clearToast = false})`

- [ ] **Step 1: Write failing tests**

Create `test/ui/todo_state_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/ui/todo_state.dart';

void main() {
  final tasks = [
    const Task(id:1, text:'A', done:false, categorySlug:'work',     priority:TaskPriority.high, timeLabel:null),
    const Task(id:2, text:'B', done:false, categorySlug:'personal', priority:TaskPriority.low,  timeLabel:null),
    const Task(id:3, text:'C', done:true,  categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:null),
  ];

  TodoState make({ActiveTab tab = ActiveTab.pending, CategoryFilter? filter}) => TodoState(
    tasks: tasks,
    categories: seedCategories.toList(),
    activeTab: tab,
    categoryFilter: filter ?? const AllCategories(),
    inputText: '',
    toastMessage: null,
  );

  group('filtered', () {
    test('pending returns undone tasks', () {
      expect(make().filtered.every((t) => !t.done), true);
      expect(make().filtered.length, 2);
    });
    test('done returns done tasks', () {
      expect(make(tab: ActiveTab.done).filtered.every((t) => t.done), true);
      expect(make(tab: ActiveTab.done).filtered.length, 1);
    });
    test('category filter narrows results', () {
      final s = make(filter: const SpecificCategory('work'));
      expect(s.filtered.every((t) => t.categorySlug == 'work'), true);
      expect(s.filtered.length, 1);
    });
  });

  group('priority grouping', () {
    test('highPriority', () => expect(make().highPriority.every((t) => t.priority == TaskPriority.high), true));
    test('restPriority',  () => expect(make().restPriority.every((t) => t.priority != TaskPriority.high), true));
  });

  group('counts', () {
    test('doneCount',    () => expect(make().doneCount, 1));
    test('totalCount',   () => expect(make().totalCount, 3));
    test('pendingCount', () => expect(make().pendingCount, 2));
  });
}
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/ui/todo_state_test.dart
```
Expected: FAIL — `todo_state.dart` not found.

- [ ] **Step 3: Create `lib/ui/todo_state.dart`**

```dart
import '../data/category.dart';
import '../data/task.dart';

enum ActiveTab { pending, done }

sealed class CategoryFilter {
  const CategoryFilter();
}

class AllCategories extends CategoryFilter {
  const AllCategories();
}

class SpecificCategory extends CategoryFilter {
  final String slug;
  const SpecificCategory(this.slug);
}

class TodoState {
  final List<Task> tasks;
  final List<Category> categories;
  final ActiveTab activeTab;
  final CategoryFilter categoryFilter;
  final String inputText;
  final String? toastMessage;

  const TodoState({
    required this.tasks,
    required this.categories,
    required this.activeTab,
    required this.categoryFilter,
    required this.inputText,
    required this.toastMessage,
  });

  List<Task> get filtered => tasks.where((t) {
    final tabOk = activeTab == ActiveTab.pending ? !t.done : t.done;
    final catOk = categoryFilter is AllCategories ||
        t.categorySlug == (categoryFilter as SpecificCategory).slug;
    return tabOk && catOk;
  }).toList();

  List<Task> get highPriority => filtered.where((t) => t.priority == TaskPriority.high).toList();
  List<Task> get restPriority  => filtered.where((t) => t.priority != TaskPriority.high).toList();

  int get doneCount    => tasks.where((t) => t.done).length;
  int get totalCount   => tasks.length;
  int get pendingCount => tasks.where((t) => !t.done).length;

  TodoState copyWith({
    List<Task>? tasks,
    List<Category>? categories,
    ActiveTab? activeTab,
    CategoryFilter? categoryFilter,
    String? inputText,
    String? toastMessage,
    bool clearToast = false,
  }) => TodoState(
    tasks: tasks ?? this.tasks,
    categories: categories ?? this.categories,
    activeTab: activeTab ?? this.activeTab,
    categoryFilter: categoryFilter ?? this.categoryFilter,
    inputText: inputText ?? this.inputText,
    toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
  );
}
```

- [ ] **Step 4: Run — verify PASS**

```powershell
flutter test test/ui/todo_state_test.dart
```
Expected: 8 tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/ui/todo_state.dart test/ui/todo_state_test.dart
git commit -m "feat: add TodoState with filtering, priority grouping, and counts"
```

---

### Task 7: ViewModel

**Files:**
- Create: `lib/ui/todo_viewmodel.dart`
- Create: `test/ui/todo_viewmodel_test.dart`

**Interfaces:**
- Consumes: `TodoState`, `ActiveTab`, `AllCategories`, `CategoryFilter`, `SpecificCategory` from `lib/ui/todo_state.dart`; `AppDatabase` from `task_database.dart`; `TaskDao` from `task_dao.dart`; `detectCategory`, `detectPriority` from `task_auto_detect.dart`; seed data from `lib/data/`
- Produces:
  - `appDatabaseProvider` — `Provider<AppDatabase>`
  - `TodoViewmodel extends _$TodoViewmodel` — `AsyncNotifier<TodoState>`
  - `todoViewmodelProvider` — generated
  - Public methods: `toggleTask(int)`, `addTask(String)`, `deleteTask(int)`, `updateInput(String)`, `switchTab(ActiveTab)`, `filterByCategory(CategoryFilter)`, `dismissToast()`, `addCategory(String)` (stub), `deleteCategory(String)` (stub)

- [ ] **Step 1: Write failing tests**

Create `test/ui/todo_viewmodel_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart';
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
}
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/ui/todo_viewmodel_test.dart
```
Expected: FAIL — `todo_viewmodel.dart` not found.

- [ ] **Step 3: Create `lib/ui/todo_viewmodel.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/category.dart';
import '../data/task.dart';
import '../data/task_database.dart';
import '../data/task_dao.dart';
import '../utils/task_auto_detect.dart';
import 'todo_state.dart';

part 'todo_viewmodel.g.dart';

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
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
      for (final c in seedCategories) await dao.insertCategory(c);
      for (final t in seedTasks)      await dao.insertTask(t);
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
```

- [ ] **Step 4: Run code generation**

```powershell
dart run build_runner build --delete-conflicting-outputs
```
Expected: Generates `lib/ui/todo_viewmodel.g.dart`.

- [ ] **Step 5: Run — verify PASS**

```powershell
flutter test test/ui/todo_viewmodel_test.dart
```
Expected: 6 tests PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/ui/todo_viewmodel.dart lib/ui/todo_viewmodel.g.dart test/ui/todo_viewmodel_test.dart
git commit -m "feat: add TodoViewmodel — toggle, add, delete, toast with seed data"
```

---

### Task 8: Custom Painters

**Files:**
- Create: `lib/ui/components/checkmark_painter.dart`
- Create: `lib/ui/components/strikethrough_painter.dart`

**Interfaces:**
- Produces: `CheckmarkPainter extends CustomPainter`, `StrikethroughPainter({required double progress}) extends CustomPainter`

No unit tests — visual. Exercised in Task 9 widget tests.

- [ ] **Step 1: Create `lib/ui/components/checkmark_painter.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.11, size.height * 0.50)
        ..lineTo(size.width * 0.38, size.height * 0.86)
        ..lineTo(size.width * 0.89, size.height * 0.14),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
```

- [ ] **Step 2: Create `lib/ui/components/strikethrough_painter.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class StrikethroughPainter extends CustomPainter {
  final double progress;
  const StrikethroughPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      Paint()
        ..color = AppColors.doneText
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(StrikethroughPainter old) => old.progress != progress;
}
```

- [ ] **Step 3: Commit**

```powershell
git add lib/ui/components/checkmark_painter.dart lib/ui/components/strikethrough_painter.dart
git commit -m "feat: add CheckmarkPainter and StrikethroughPainter"
```

---

### Task 9: TaskItem Component

**Files:**
- Create: `lib/ui/components/task_item.dart`
- Create: `test/ui/components/task_item_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppText`, `AppDim`; `Task`, `TaskPriority`, `Category`; `CheckmarkPainter`; `StrikethroughPainter`; `todoViewmodelProvider`
- Produces: `TaskItem({required Task task, required List<Category> categories})` — `ConsumerStatefulWidget`

- [ ] **Step 1: Write failing widget test**

Create `test/ui/components/task_item_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart';
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
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/ui/components/task_item_test.dart
```
Expected: FAIL — `task_item.dart` not found.

- [ ] **Step 3: Create `lib/ui/components/task_item.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/category.dart';
import '../../data/task.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_viewmodel.dart';
import 'checkmark_painter.dart';
import 'strikethrough_painter.dart';

class TaskItem extends ConsumerStatefulWidget {
  final Task task;
  final List<Category> categories;

  const TaskItem({super.key, required this.task, required this.categories});

  @override
  ConsumerState<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: widget.task.done ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.fastOutSlowIn);
  }

  @override
  void didUpdateWidget(TaskItem old) {
    super.didUpdateWidget(old);
    if (widget.task.done && !old.task.done) _ctrl.forward();
    if (!widget.task.done && old.task.done) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return GestureDetector(
      onTap: () => ref.read(todoViewmodelProvider.notifier).toggleTask(task.id),
      onLongPress: () => ref.read(todoViewmodelProvider.notifier).deleteTask(task.id),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDim.screenPadH, vertical: AppDim.taskPadV,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: AppDim.borderW)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PriorityDot(priority: task.priority),
            const SizedBox(width: 11),
            _CustomCheckbox(isDone: task.done),
            const SizedBox(width: 11),
            Expanded(
              child: _TaskContent(
                task: task,
                categories: widget.categories,
                strikeAnim: _anim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.high => AppColors.red,
      TaskPriority.mid  => AppColors.accent,
      TaskPriority.low  => AppColors.border,
    };
    return Container(
      width: AppDim.dotSize,
      height: AppDim.dotSize,
      margin: const EdgeInsets.only(top: 7),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool isDone;
  const _CustomCheckbox({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppDim.checkboxSz,
      height: AppDim.checkboxSz,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.accentDim : Colors.transparent,
        border: Border.all(
          color: isDone ? AppColors.accentDim : AppColors.surface3,
          width: 1.5,
        ),
      ),
      child: AnimatedOpacity(
        opacity: isDone ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: CustomPaint(painter: CheckmarkPainter()),
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  final Task task;
  final List<Category> categories;
  final Animation<double> strikeAnim;

  const _TaskContent({required this.task, required this.categories, required this.strikeAnim});

  @override
  Widget build(BuildContext context) {
    final cat = task.categorySlug != null
        ? categories.where((c) => c.slug == task.categorySlug).firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StrikethroughText(text: task.text, isDone: task.done, anim: strikeAnim),
        if (cat != null || task.timeLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(children: [
              if (cat != null) _TagChip(label: cat.label),
              if (cat != null && task.timeLabel != null) const SizedBox(width: 5),
              if (task.timeLabel != null)
                Text(task.timeLabel!, style: AppText.metaText),
            ]),
          ),
      ],
    );
  }
}

class _StrikethroughText extends StatelessWidget {
  final String text;
  final bool isDone;
  final Animation<double> anim;

  const _StrikethroughText({required this.text, required this.isDone, required this.anim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Stack(
        children: [
          Text(
            text,
            style: AppText.taskText.copyWith(
              color: isDone ? AppColors.doneText : AppColors.text,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: StrikethroughPainter(progress: anim.value)),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppDim.radiusSm),
      ),
      child: Text(label, style: AppText.metaText),
    );
  }
}
```

- [ ] **Step 4: Run — verify PASS**

```powershell
flutter test test/ui/components/task_item_test.dart
```
Expected: 4 tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/ui/components/task_item.dart test/ui/components/task_item_test.dart
git commit -m "feat: add TaskItem with animated checkbox, strikethrough, priority dot, and tag chip"
```

---

### Task 10: TaskList Component

**Files:**
- Create: `lib/ui/components/task_list.dart`
- Create: `test/ui/components/task_list_test.dart`

**Interfaces:**
- Consumes: `TodoState`, `ActiveTab`, `AllCategories` from `lib/ui/todo_state.dart`; `TaskItem` from `task_item.dart`; `AppText`
- Produces: `TaskList({required TodoState state})` — `StatelessWidget`

- [ ] **Step 1: Write failing widget test**

Create `test/ui/components/task_list_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/category.dart';
import 'package:todo/data/task.dart';
import 'package:todo/data/task_database.dart';
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
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/ui/components/task_list_test.dart
```
Expected: FAIL — `task_list.dart` not found.

- [ ] **Step 3: Create `lib/ui/components/task_list.dart`**

```dart
import 'package:flutter/material.dart';

import '../../theme/text_styles.dart';
import '../todo_state.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final TodoState state;
  const TaskList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isPending = state.activeTab == ActiveTab.pending;
    final items = _buildItems(isPending);
    if (items.isEmpty) return _EmptyState(isPending: isPending);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 84),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }

  List<Widget> _buildItems(bool isPending) {
    if (!isPending) {
      return state.filtered
          .map((t) => TaskItem(task: t, categories: state.categories))
          .toList();
    }
    final items = <Widget>[];
    if (state.highPriority.isNotEmpty) {
      items.add(const _SectionLabel('ưu tiên cao'));
      items.addAll(state.highPriority.map((t) => TaskItem(task: t, categories: state.categories)));
    }
    if (state.restPriority.isNotEmpty) {
      items.add(const _SectionLabel('còn lại'));
      items.addAll(state.restPriority.map((t) => TaskItem(task: t, categories: state.categories)));
    }
    return items;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 7),
    child: Text(text.toUpperCase(), style: AppText.labelText),
  );
}

class _EmptyState extends StatelessWidget {
  final bool isPending;
  const _EmptyState({required this.isPending});

  @override
  Widget build(BuildContext context) {
    final msg = isPending ? 'không có việc gì' : 'chưa xong gì hết';
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('─────', style: AppText.labelText),
        const SizedBox(height: 10),
        Text(msg, style: AppText.labelText.copyWith(letterSpacing: .6)),
        Text('─────', style: AppText.labelText),
      ]),
    );
  }
}
```

- [ ] **Step 4: Run — verify PASS**

```powershell
flutter test test/ui/components/task_list_test.dart
```
Expected: 3 tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/ui/components/task_list.dart test/ui/components/task_list_test.dart
git commit -m "feat: add TaskList with section grouping and empty state"
```

---

### Task 11: BottomSheet & Toast

**Files:**
- Create: `lib/ui/components/bottom_sheet.dart`
- Create: `lib/ui/components/toast.dart`
- Create: `test/ui/components/bottom_sheet_test.dart`

**Interfaces:**
- Consumes: `todoViewmodelProvider`; `AppColors`, `AppText`, `AppDim`
- Produces:
  - `TaskBottomSheet()` — `ConsumerStatefulWidget`
  - `TaskToast({required String? message})` — `StatelessWidget`

- [ ] **Step 1: Write failing widget test**

Create `test/ui/components/bottom_sheet_test.dart`:
```dart
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
```

- [ ] **Step 2: Run — verify FAIL**

```powershell
flutter test test/ui/components/bottom_sheet_test.dart
```
Expected: FAIL — `bottom_sheet.dart` not found.

- [ ] **Step 3: Create `lib/ui/components/bottom_sheet.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_viewmodel.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  final _ctrl      = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused  = false;
  bool _isPressed  = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(todoViewmodelProvider.notifier).addTask(_ctrl.text);
    _ctrl.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(children: [
        Expanded(child: _InputWrap(
          controller: _ctrl,
          focusNode: _focusNode,
          isFocused: _isFocused,
          onSubmitted: (_) => _submit(),
        )),
        const SizedBox(width: 9),
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp:   (_) { setState(() => _isPressed = false); _submit(); },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 41, height: 41,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(painter: _PlusPainter()),
            ),
          ),
        ),
      ]),
    );
  }
}

class _InputWrap extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onSubmitted;

  const _InputWrap({
    required this.controller, required this.focusNode,
    required this.isFocused,  required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.accentDim : AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(children: [
        const Text('+', style: TextStyle(
          fontFamily: 'IBMPlexMono', fontSize: 14, color: AppColors.textDim2,
        )),
        const SizedBox(width: 9),
        Expanded(child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: AppText.inputText,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'thêm việc cần làm...',
            hintStyle: AppText.inputText.copyWith(color: AppColors.textDim2),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
        )),
      ]),
    );
  }
}

class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const h = 7.0;
    canvas.drawLine(Offset(cx - h, cy), Offset(cx + h, cy), paint);
    canvas.drawLine(Offset(cx, cy - h), Offset(cx, cy + h), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
```

- [ ] **Step 4: Create `lib/ui/components/toast.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class TaskToast extends StatelessWidget {
  final String? message;
  const TaskToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final visible = message != null;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, -0.3),
        duration: const Duration(milliseconds: 180),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surface3, width: 1),
            ),
            child: Text(message ?? '', style: AppText.progressLabel),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run — verify PASS**

```powershell
flutter test test/ui/components/bottom_sheet_test.dart
```
Expected: 2 tests PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/ui/components/bottom_sheet.dart lib/ui/components/toast.dart test/ui/components/bottom_sheet_test.dart
git commit -m "feat: add TaskBottomSheet and TaskToast"
```

---

### Task 12: TodoScreen & App Entry Point

**Files:**
- Create: `lib/ui/todo_screen.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: all previously created files
- Produces: complete runnable app with core task list feature

- [ ] **Step 1: Create `lib/ui/todo_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/colors.dart';
import 'components/bottom_sheet.dart';
import 'components/task_list.dart';
import 'components/toast.dart';
import 'todo_viewmodel.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(todoViewmodelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Center(
            child: Text('$e', style: const TextStyle(color: AppColors.text)),
          ),
          data: (state) => Stack(
            children: [
              Column(children: [
                const SizedBox(height: 52),   // StatusBar placeholder
                const SizedBox(height: 84),   // Header placeholder
                const SizedBox(height: 36),   // TagFilterRow placeholder
                const SizedBox(height: 38),   // TabBar placeholder
                Expanded(child: TaskList(state: state)),
              ]),
              const Positioned(
                bottom: 0, left: 0, right: 0,
                child: TaskBottomSheet(),
              ),
              Positioned(
                top: 62, left: 0, right: 0,
                child: TaskToast(message: state.toastMessage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/colors.dart';
import 'ui/todo_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        fontFamily: 'IBMPlexMono',
      ),
      home: const TodoScreen(),
    );
  }
}
```

- [ ] **Step 3: Run all tests**

```powershell
flutter test
```
Expected: All tests PASS.

- [ ] **Step 4: Run the app**

```powershell
flutter run
```
Verify manually:
- Dark screen loads, 5 pending tasks visible (id 4 is done, shows in done tab)
- Section "ƯU TIÊN CAO": Review PR, Update deck
- Section "CÒN LẠI": Họp sync, Mua sữa, Gọi điện
- Bottom input with hint "thêm việc cần làm..."
- Tap task → checkbox animates, strikethrough draws over 380ms
- Long press → task disappears
- Type text + submit → task added at list position, toast "đã thêm" appears then fades

- [ ] **Step 5: Commit**

```powershell
git add lib/ui/todo_screen.dart lib/main.dart
git commit -m "feat: wire TodoScreen and main entry — core task list complete"
```
