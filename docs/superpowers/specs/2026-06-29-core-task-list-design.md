# Core Task List — Implementation Design

**Date:** 2026-06-29  
**Spec source:** `todo-flutter-spec.md` v3  
**Scope:** Feature 1 of N — project setup + data layer + state + core task list UI  
**Approach:** Foundation-first (data → state → UI), feature-by-feature overall strategy

---

## Goal

Build a runnable Flutter app with:
- Task list displaying seed data with correct visual spec
- Toggle task done/undone
- Delete task (long press)
- Add task (bottom sheet input)
- Toast feedback
- Correct dark theme, typography, spacing from spec v3

This is the foundation feature. All subsequent features (header, progress bar, category filter, tab bar) will build on top of this.

---

## Section 1: Project Setup & Theme Tokens

### Project creation
```
flutter create todo --org com.yourname --platforms android
```

`main.dart` — stripped of all boilerplate. `MaterialApp` configured with:
- `scaffoldBackgroundColor: AppColors.bg`
- `splashColor: Colors.transparent`
- `highlightColor: Colors.transparent`
- `fontFamily: 'IBMPlexMono'` as default
- Dark only — no `darkTheme` toggle

Fonts placed in `assets/fonts/`:
- IBMPlexMono: Light (300), LightItalic (300i), Regular (400), Medium (500)
- Inter: Light (300), Regular (400), Medium (500), SemiBold (600)

### Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  drift: ^2.x
  sqlite3_flutter_libs: ^0.x
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  intl: ^0.x
  phosphor_flutter: ^2.x

dev_dependencies:
  drift_dev: ^2.x
  build_runner: ^2.x
  riverpod_generator: ^2.x
```

### Theme tokens (constants only, never modified after)
- `lib/theme/colors.dart` — `AppColors` class, all values from spec section 1.1
- `lib/theme/text_styles.dart` — `AppText` class from spec 1.2, `AppDim` from spec 1.3

---

## Section 2: Data Layer

### Models

**`lib/data/category.dart`**
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

**`lib/data/task.dart`**
```dart
enum TaskPriority { high, mid, low }

class Task {
  final int id;
  final String text;
  final bool done;
  final String? categorySlug;
  final TaskPriority priority;
  final String? timeLabel;
  // + copyWith(done, categorySlug)
}
```
Seed tasks: 6 items from spec section 2.4.

### Drift DB (`lib/data/task_database.dart` + `task_dao.dart`)

Two tables:
```
categories:  slug TEXT PK, label TEXT NOT NULL
tasks:       id AUTOINCREMENT, text, done INT (0/1),
             categorySlug TEXT FK→categories ON DELETE SET NULL,
             priority TEXT, timeLabel TEXT
```

DAO methods exposed for this feature:
```dart
Future<List<Task>> getAllTasks()
Future<List<Category>> getAllCategories()
Future<void> insertTask(Task)
Future<void> updateTask(Task)      // toggle done
Future<void> deleteTask(int id)
Future<void> insertCategory(Category)
```

**Seed logic:** On DB open, if `categories` table is empty → insert seed categories then seed tasks.

---

## Section 3: State & ViewModel

### `lib/ui/todo_state.dart`
- `ActiveTab` enum: `pending`, `done`
- `CategoryFilter` sealed class: `AllCategories`, `SpecificCategory(slug)`
- `TodoState` with derived getters: `filtered`, `highPriority`, `restPriority`, `doneCount`, `totalCount`, `pendingCount`

### `lib/ui/todo_viewmodel.dart`
Riverpod `@riverpod` annotation, exposes `AsyncValue<TodoState>`.

**Init:** load tasks + categories from DB → build initial state.

**Events implemented in this feature:**
```dart
void toggleTask(int id)      // copyWith(done: !done), persist, rebuild
void addTask(String text)    // auto-detect category+priority (spec §6), insert DB
void deleteTask(int id)      // remove from DB, rebuild
void updateInput(String text)
void dismissToast()
```

**Stubbed (no logic yet, signature only):**
```dart
void switchTab(ActiveTab tab)
void filterByCategory(CategoryFilter filter)
void addCategory(String label)
void deleteCategory(String slug)
```

**`showToast` (internal):** sets `toastMessage`, schedules `Future.delayed(1800ms)` → `dismissToast()`.

**Auto-detect logic** (`lib/utils/task_auto_detect.dart`):
- Category: regex match per spec §6 rules, then check custom category slugs/labels
- Priority: HIGH `/gấp|urgent|quan trọng|ngay|trước|deadline/i`, MID `/hôm nay|today|lúc \d/i`, LOW default

---

## Section 4: UI Components

### `lib/ui/todo_screen.dart`
`Stack` containing:
1. `Column`: StatusBar placeholder (52dp SizedBox) → Header placeholder → TagFilterRow placeholder → TabBar placeholder → `Expanded(TaskList)`
2. `Positioned(bottom:0)` — BottomSheet
3. `Positioned(top:62)` — Toast

Placeholders are `SizedBox` with correct heights from spec §4 anatomy so layout is stable when sections are implemented later.

### `lib/ui/components/task_item.dart`
Full implementation per spec §5.6:
- `GestureDetector`: `onTap` → `toggleTask`, `onLongPress` → `deleteTask`
- Row: `PriorityDot` (5×5dp circle, color by priority) → `SizedBox(11)` → `CustomCheckbox` → `SizedBox(11)` → `Expanded(TaskContent)`
- `TaskContent`: Column with `StrikethroughText` + meta Row (`TagChip` if categorySlug, timeLabel text)
- `CustomCheckbox` (19×19dp): `AnimatedContainer` circle, `CheckmarkPainter` inside `AnimatedOpacity`
- `StrikethroughText`: Stack of `Text` + `CustomPaint(StrikethroughPainter)`, `AnimationController` 380ms `fastOutSlowIn`

Painters: `CheckmarkPainter` (spec §10), `StrikethroughPainter` (spec §11).

**Prohibited (per spec §8):** No Material Checkbox, no `TextDecoration.lineThrough`, no InkWell ripple, no swipe-to-delete.

### `lib/ui/components/task_list.dart`
`ListView.builder` with:
- Pending tab grouping: `SectionLabel("ưu tiên cao")` + highPriority items → `SectionLabel("còn lại")` + restPriority items
- Done tab: flat list, no section labels
- `EmptyState` when list is empty (spec §5.5 format)
- `contentPadding: EdgeInsets.only(bottom: 84)`

### `lib/ui/components/bottom_sheet.dart`
Positioned at bottom, per spec §5.7:
- `InputWrap`: `AnimatedContainer` border (accentDim when focused, border when not), `TextField` with hint, `textInputAction: done`
- `AddButton`: 41×41dp, accent color, `AnimatedScale(0.94)` on press, `PlusPainter`

### `lib/ui/components/toast.dart`
- `AnimatedOpacity` + `AnimatedSlide(offset: Y -0.3→0)`
- Enter 180ms, exit 180ms
- Auto-dismiss after 1800ms via ViewModel

---

## File structure after this feature

```
lib/
├── main.dart
├── theme/
│   ├── colors.dart
│   └── text_styles.dart
├── data/
│   ├── category.dart
│   ├── task.dart
│   ├── task_database.dart
│   └── task_dao.dart
├── ui/
│   ├── todo_state.dart
│   ├── todo_viewmodel.dart
│   ├── todo_screen.dart
│   └── components/
│       ├── task_item.dart
│       ├── task_list.dart
│       ├── bottom_sheet.dart
│       └── toast.dart
└── utils/
    ├── task_auto_detect.dart
    └── slug.dart
```

---

## Out of scope for this feature

The following are stubbed/placeholder only and implemented in subsequent features:
- StatusBar (real time, icons)
- Header (eyebrow, title+count, progress bar)
- TagFilterRow (category pills, add category inline input)
- TabBar (pending/done switching)
- Category management UI (add, delete)

---

## Definition of done

- [ ] `flutter run` launches without error on Android
- [ ] Seed tasks visible with correct colors, typography, priority dots
- [ ] Tap task → checkbox animates, strikethrough draws
- [ ] Long press task → task disappears
- [ ] Type in bottom sheet + submit → task appears at top of list
- [ ] Toast "đã thêm" appears and auto-dismisses after 1800ms
- [ ] Auto-detect assigns category and priority correctly for seed-like inputs
- [ ] No Material ripple visible on any tap
