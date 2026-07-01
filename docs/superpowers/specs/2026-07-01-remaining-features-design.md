# Remaining Features — Implementation Design

**Date:** 2026-07-01
**Spec source:** `todo-flutter-spec.md` v3
**Scope:** Features 2–5 — Header, TabBar, TagFilterRow, StatusBar
**Order:** Functional-first (B): Header → TabBar → TagFilterRow → StatusBar

---

## Goal

Complete the full screen anatomy defined in spec §4. All placeholders (`SizedBox`) in `todo_screen.dart` are replaced with real components. All stubbed viewmodel methods are implemented.

---

## Section 1: Header

**File:** `lib/ui/components/header.dart`

`Padding(EdgeInsets.fromLTRB(24, 4, 24, 0))` containing a `Column` with 3 parts:

### Eyebrow (date)
```dart
Text(dateString, style: AppText.dateLabel)
// format: "thứ X · DD tháng M" via intl
// margin bottom: 5dp
```

Day-of-week mapping (Vietnamese):
```
1→thứ hai, 2→thứ ba, 3→thứ tư, 4→thứ năm,
5→thứ sáu, 6→thứ bảy, 7→chủ nhật
```

### Title + Count row
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Text('Hôm nay', style: AppText.title),
    SizedBox(width: 10),
    Text(countString, style: AppText.taskCount),
  ],
)
// countString: pendingCount > 0 → "$pendingCount việc còn lại"
//              pendingCount == 0 → "tất cả xong rồi"
// margin bottom: 16dp
```

### Progress block
Track + animated fill in a `LayoutBuilder` (to get maxWidth):
```dart
Stack(children: [
  // Track
  Container(height: 1.5, color: AppColors.border,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(1))),
  // Fill
  AnimatedContainer(
    duration: Duration(milliseconds: 500),
    curve: Curves.fastOutSlowIn,
    width: ratio * maxWidth,  // ratio = doneCount / totalCount (0.0 if totalCount==0)
    height: 1.5,
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(1),
    ),
  ),
  // Glow dot — Stack positioned at right edge of fill
  Positioned(
    left: ratio * maxWidth - 2.5,  // centered on tip
    top: -1.25,
    child: AnimatedOpacity(
      opacity: ratio > 0 ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        width: 5, height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
          boxShadow: [BoxShadow(
            color: AppColors.accent.withOpacity(.5),
            blurRadius: 8, spreadRadius: 2,
          )],
        ),
      ),
    ),
  ),
])
```

Progress meta row (margin top: 5dp, margin bottom: 12dp):
```dart
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  Text('$doneCount / $totalCount xong', style: AppText.progressLabel),
  Text('$pct%', style: AppText.progressPct),
  // pct = (ratio * 100).round()
])
```

**Existing file changes:**
- `todo_screen.dart`: replace `SizedBox(84)` placeholder with `Header()`

---

## Section 2: TabBar

**File:** `lib/ui/components/todo_tab_bar.dart`
(named `todo_tab_bar` to avoid conflict with Flutter's built-in `TabBar`)

```dart
Container(
  decoration: BoxDecoration(
    border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
  ),
  padding: EdgeInsets.symmetric(horizontal: 24),
  child: Row(children: [
    TabButton(label: 'đang làm', tab: ActiveTab.pending),
    TabButton(label: 'xong rồi', tab: ActiveTab.done),
  ]),
)
```

**TabButton:**
```dart
GestureDetector(
  onTap: () => viewModel.switchTab(tab),
  child: Padding(
    padding: EdgeInsets.only(top: 9, bottom: 9, right: 22),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: AppText.tabText.copyWith(
        color: isActive ? AppColors.accent : AppColors.textDim,
      )),
      SizedBox(height: 6),
      AnimatedContainer(
        duration: Duration(milliseconds: 150),
        height: 1.5,
        width: textWidth,  // intrinsic — wrap in IntrinsicWidth or fixed
        color: isActive ? AppColors.accent : Colors.transparent,
      ),
    ]),
  ),
)
```

**Viewmodel — implement `switchTab`:**
```dart
void switchTab(ActiveTab tab) {
  final s = state.requireValue;
  state = AsyncData(s.copyWith(
    activeTab: tab,
    categoryFilter: const AllCategories(),  // reset filter on tab switch
  ));
}
```

**Existing file changes:**
- `todo_screen.dart`: replace `SizedBox(38)` with `TodoTabBar()`
- `todo_viewmodel.dart`: implement `switchTab`

---

## Section 3: TagFilterRow

**Files:**
- `lib/ui/components/tag_filter_row.dart`
- `lib/ui/components/add_category_button.dart`

### Layout
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Row(spacing: 5, children: [
      TagPill(slug: 'all', label: 'tất cả', canDelete: false),
      ...categories.map((c) => TagPill(
        slug: c.slug, label: c.label, canDelete: true,
      )),
      AddCategoryButton(),
    ]),
  ),
)
```

### TagPill
State: `isActive` (slug matches filter), `isDeletable` (long-press mode).

```dart
// Outer Stack for delete badge overlay
Stack(clipBehavior: Clip.none, children: [
  GestureDetector(
    onTap: () {
      if (isDeletable) {
        viewModel.deleteCategory(slug);
      } else {
        viewModel.filterByCategory(
          slug == 'all' ? const AllCategories() : SpecificCategory(slug),
        );
      }
    },
    onLongPress: canDelete ? _startDeleteMode : null,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentGlow : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDim.radiusLg),
        border: Border.all(
          color: isActive ? AppColors.accentDim : AppColors.border,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
      child: Text(label, style: AppText.tagText.copyWith(
        color: isActive ? AppColors.accent : AppColors.textDim,
      )),
    ),
  ),
  // Delete badge
  if (canDelete)
    Positioned(top: -4, right: -4,
      child: AnimatedOpacity(
        opacity: isDeletable ? 1.0 : 0.0,
        duration: Duration(milliseconds: 150),
        child: Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: AppColors.red, shape: BoxShape.circle,
          ),
          child: Icon(PhosphorIcons.x, size: 8, color: AppColors.text),
        ),
      ),
    ),
])
```

Long-press delete flow:
1. `onLongPress` fires after 600ms (Flutter default) → set `isDeletable = true` (local `StatefulWidget` state)
2. Tap while `isDeletable` → `viewModel.deleteCategory(slug)`
3. Tap anywhere else / new filter tap → `isDeletable = false`

### AddCategoryButton
```dart
// Dashed border via CustomPainter (Flutter has no native dashed border)
GestureDetector(
  onTap: _openInlineInput,
  child: SizedBox(
    width: 24, height: 24,
    child: CustomPaint(painter: DashedCirclePainter(color: AppColors.border)),
    // Icon centered
    child: Icon(PhosphorIcons.plus, size: 11, color: AppColors.textDim2),
  ),
)
```

Inline input — managed in `TagFilterRow` local state:
```dart
AnimatedSize(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  child: isInputVisible
    ? SizedBox(
        width: 88,
        child: TextField(
          style: AppText.tagText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDim.radiusLg),
              borderSide: BorderSide(color: AppColors.accentDim),
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (text) {
            viewModel.addCategory(text.trim());
            setState(() => isInputVisible = false);
          },
          onEditingComplete: () => setState(() => isInputVisible = false),
        ),
      )
    : SizedBox.shrink(),
)
```

Focus lost → cancel (use `FocusNode.addListener`).

### Viewmodel — implement 3 stubbed methods

**`filterByCategory(CategoryFilter filter)`:**
```dart
void filterByCategory(CategoryFilter filter) {
  state = AsyncData(state.requireValue.copyWith(categoryFilter: filter));
}
```

**`addCategory(String label)`:**
```dart
Future<void> addCategory(String label) async {
  label = label.trim();
  if (label.isEmpty) return;
  final slug = toSlug(label);
  final s = state.requireValue;
  if (s.categories.any((c) => c.slug == slug)) return;
  final category = Category(slug: slug, label: label);
  await _db.taskDao.insertCategory(category);
  state = AsyncData(s.copyWith(
    categories: [...s.categories, category],
  ));
  _showToast('+ "$label"');
}
```

**`deleteCategory(String slug)`:**
```dart
Future<void> deleteCategory(String slug) async {
  final s = state.requireValue;
  // Null out categorySlug on affected tasks in DB
  final affected = s.tasks.where((t) => t.categorySlug == slug).toList();
  for (final t in affected) {
    await _db.taskDao.updateTask(t.copyWith(categorySlug: null));  // explicit null
  }
  await _db.taskDao.deleteCategory(slug);
  final updatedTasks = s.tasks.map((t) =>
    t.categorySlug == slug ? t.copyWith(categorySlug: null) : t
  ).toList();
  final updatedFilter = s.categoryFilter is SpecificCategory &&
    (s.categoryFilter as SpecificCategory).slug == slug
      ? const AllCategories()
      : s.categoryFilter;
  state = AsyncData(s.copyWith(
    tasks: updatedTasks,
    categories: s.categories.where((c) => c.slug != slug).toList(),
    categoryFilter: updatedFilter,
  ));
  _showToast('category đã xoá');
}
```

**DAO additions needed:**
```dart
Future<void> insertCategory(Category c)
Future<void> deleteCategory(String slug)
// updateTask already exists
```

**Existing file changes:**
- `todo_screen.dart`: replace `SizedBox(36)` with `TagFilterRow()`
- `todo_viewmodel.dart`: implement 3 stubbed methods
- `task_dao.dart`: add `insertCategory`, `deleteCategory`

---

## Section 4: StatusBar

**File:** `lib/ui/components/status_bar.dart`

```dart
SizedBox(
  height: 52,
  child: Padding(
    padding: EdgeInsets.only(left: 26, right: 26, bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StreamBuilder<DateTime>(
          stream: Stream.periodic(Duration(minutes: 1), (_) => DateTime.now())
            .startWith(DateTime.now()),
          builder: (_, snap) {
            final now = snap.data ?? DateTime.now();
            final time = DateFormat('HH:mm').format(now);
            return Text(time, style: AppText.statusTime);
          },
        ),
        Row(spacing: 6, children: [
          Icon(PhosphorIcons.cellSignalFull, size: 16, color: AppColors.text),
          Icon(PhosphorIcons.wifiHigh,       size: 16, color: AppColors.text),
          Icon(PhosphorIcons.battery,        size: 16, color: AppColors.text),
        ]),
      ],
    ),
  ),
)
```

Note: `Stream.periodic` doesn't emit immediately — use `startWith(DateTime.now())` (from `rxdart`) or seed with a `BehaviorSubject`, or use an initial `DateTime.now()` via `initialData` on `StreamBuilder`.

**Existing file changes:**
- `todo_screen.dart`: replace `SizedBox(52)` with `StatusBar()`

---

## New files summary

```
lib/ui/components/
  header.dart               ← NEW
  todo_tab_bar.dart         ← NEW
  tag_filter_row.dart       ← NEW
  add_category_button.dart  ← NEW
  status_bar.dart           ← NEW
```

## Changed files summary

```
lib/ui/todo_screen.dart       ← replace 4 SizedBox placeholders
lib/ui/todo_viewmodel.dart    ← implement switchTab, filterByCategory,
                                 addCategory, deleteCategory
lib/data/task_dao.dart        ← add insertCategory, deleteCategory
```

---

## Definition of done

- [ ] Header shows correct date string, title, count, animated progress bar
- [ ] Progress bar fills/shrinks smoothly as tasks are toggled
- [ ] Glow dot appears when ratio > 0, hidden at 0%
- [ ] TabBar switches pending ↔ done, underline animates
- [ ] Switching tab resets category filter to "tất cả"
- [ ] TagFilterRow shows all categories as pills
- [ ] Tapping pill filters task list
- [ ] Long-press pill (600ms) → × badge appears
- [ ] Tapping × badge deletes category (tasks lose tag, filter resets if needed)
- [ ] Tapping "+" → inline TextField 88dp wide animates open
- [ ] Submitting inline field adds category and toast shows
- [ ] Focus lost on inline field closes it without adding
- [ ] StatusBar shows current time, updates each minute
- [ ] No Material ripple, no elevation, no prohibited widgets
