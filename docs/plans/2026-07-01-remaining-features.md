# Remaining Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the four `SizedBox` placeholders in `todo_screen.dart` with real Header, TabBar, TagFilterRow, and StatusBar components, and implement the two stubbed viewmodel methods (`addCategory`, `deleteCategory`).

**Architecture:** Each task creates one new file and wires it into `todo_screen.dart` immediately — no deferred wiring step. The TagFilterRow task is split into a backend task (DAO + viewmodel) and a UI task to keep diffs reviewable. All state is already in `TodoState`; no new state fields are needed.

**Tech Stack:** Flutter 3+, Riverpod 2.x (`@riverpod` codegen), Drift 2.x, `intl` for date/time, `phosphor_flutter` ^2.1.0 for icons.

---

## Pre-flight checks

Before starting any task, verify:
- `flutter pub get` passes
- `dart run build_runner build --delete-conflicting-outputs` produces no errors
- `flutter test` passes (currently 50 tests)

---

## Task 1: Header component

**Files:**
- Create: `lib/ui/components/header.dart`
- Modify: `lib/ui/todo_screen.dart` (line 29 — replace `SizedBox(84)`)

### Step 1: Create `lib/ui/components/header.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_state.dart';

class Header extends StatelessWidget {
  final TodoState state;
  const Header({super.key, required this.state});

  String _dateString() {
    final now = DateTime.now();
    const days = ['thứ hai','thứ ba','thứ tư','thứ năm','thứ sáu','thứ bảy','chủ nhật'];
    final day = days[now.weekday - 1];
    final d = now.day;
    final m = now.month;
    return '$day · $d tháng $m';
  }

  @override
  Widget build(BuildContext context) {
    final done  = state.doneCount;
    final total = state.totalCount;
    final ratio = total == 0 ? 0.0 : done / total;
    final pct   = (ratio * 100).round();
    final countString = state.pendingCount > 0
        ? '${state.pendingCount} việc còn lại'
        : 'tất cả xong rồi';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Text(_dateString(), style: AppText.dateLabel),
          const SizedBox(height: 5),

          // Title + count
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Hôm nay', style: AppText.title),
              const SizedBox(width: 10),
              Text(countString, style: AppText.taskCount),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          LayoutBuilder(builder: (_, constraints) {
            final maxW = constraints.maxWidth;
            final fillW = (ratio * maxW).clamp(0.0, maxW);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5, // tall enough to contain glow dot
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Track
                      Positioned(
                        top: 1.75, left: 0, right: 0,
                        child: Container(
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      // Fill
                      Positioned(
                        top: 1.75, left: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                          width: fillW,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      // Glow dot
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        left: fillW - 2.5,
                        top: 0,
                        child: AnimatedOpacity(
                          opacity: ratio > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: AppDim.dotSize,
                            height: AppDim.dotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Meta row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$done / $total xong', style: AppText.progressLabel),
                    Text('$pct%', style: AppText.progressPct),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
```

### Step 2: Wire into `todo_screen.dart`

Replace line 29:
```dart
// BEFORE
const SizedBox(height: 84),   // Header placeholder

// AFTER
Header(state: state),
```

Add import at top of `todo_screen.dart`:
```dart
import 'components/header.dart';
```

### Step 3: Run on device

```
flutter run --release
```

Verify: date string appears, "Hôm nay" + task count visible, progress bar fills when tasks are toggled.

### Step 4: Commit

```bash
git add lib/ui/components/header.dart lib/ui/todo_screen.dart
git commit -m "feat: add Header component (date, title, progress bar)"
```

---

## Task 2: TabBar component

**Files:**
- Create: `lib/ui/components/todo_tab_bar.dart`
- Modify: `lib/ui/todo_screen.dart` (line 31 — replace `SizedBox(38)`)
- Modify: `lib/ui/todo_viewmodel.dart` (line 110–114 — update `switchTab`)

### Step 1: Update `switchTab` in viewmodel

`switchTab` currently does NOT reset the category filter when switching tabs. Fix line 110–114 in `lib/ui/todo_viewmodel.dart`:

```dart
// BEFORE
void switchTab(ActiveTab tab) {
  final current = state.value;
  if (current == null) return;
  state = AsyncValue.data(current.copyWith(activeTab: tab));
}

// AFTER
void switchTab(ActiveTab tab) {
  final current = state.value;
  if (current == null) return;
  state = AsyncValue.data(current.copyWith(
    activeTab: tab,
    categoryFilter: const AllCategories(),
  ));
}
```

### Step 2: Create `lib/ui/components/todo_tab_bar.dart`

(Named `todo_tab_bar` to avoid shadowing Flutter's built-in `TabBar`.)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_state.dart';
import '../todo_viewmodel.dart';

class TodoTabBar extends ConsumerWidget {
  final ActiveTab activeTab;
  const TodoTabBar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(todoViewmodelProvider.notifier);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        _TabButton(
          label: 'đang làm',
          isActive: activeTab == ActiveTab.pending,
          onTap: () => vm.switchTab(ActiveTab.pending),
        ),
        _TabButton(
          label: 'xong rồi',
          isActive: activeTab == ActiveTab.done,
          onTap: () => vm.switchTab(ActiveTab.done),
        ),
      ]),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 9, bottom: 0, right: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.tabText.copyWith(
                color: isActive ? AppColors.accent : AppColors.textDim,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 1.5,
              width: _textWidth(label),
              color: isActive ? AppColors.accent : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  // Approximate pixel width for the underline — matches label at tabText size (12sp)
  double _textWidth(String text) => text.length * 7.0;
}
```

> **Note on underline width:** `_textWidth` uses a rough approximation. A more precise approach is to use a `GlobalKey` + `RenderBox`, but the approximation is close enough for Vietnamese monospace text at 12sp. If it looks wrong on device, adjust the multiplier.

### Step 3: Wire into `todo_screen.dart`

Replace line 31 (after the Header wire-up shifts lines):
```dart
// BEFORE
const SizedBox(height: 38),   // TabBar placeholder

// AFTER
TodoTabBar(activeTab: state.activeTab),
```

Add import:
```dart
import 'components/todo_tab_bar.dart';
```

### Step 4: Run on device

Verify: two tabs visible, tapping "xong rồi" shows done tasks, tapping "đang làm" returns to pending. Underline animates between tabs.

### Step 5: Commit

```bash
git add lib/ui/components/todo_tab_bar.dart lib/ui/todo_screen.dart lib/ui/todo_viewmodel.dart
git commit -m "feat: add TodoTabBar component, implement switchTab with filter reset"
```

---

## Task 3: DAO + model — deleteCategory support

**Files:**
- Modify: `lib/data/task.dart` (line 20 — update `copyWith`)
- Modify: `lib/data/task_dao.dart` (add `deleteCategory`)

### Step 1: Fix `Task.copyWith` to support null `categorySlug`

The current `copyWith` uses `??` so passing `categorySlug: null` has no effect. Add `clearCategorySlug` parameter.

In `lib/data/task.dart`, replace lines 20–27:

```dart
// BEFORE
Task copyWith({bool? done, String? categorySlug}) => Task(
  id: id,
  text: text,
  done: done ?? this.done,
  categorySlug: categorySlug ?? this.categorySlug,
  priority: priority,
  timeLabel: timeLabel,
);

// AFTER
Task copyWith({bool? done, String? categorySlug, bool clearCategorySlug = false}) => Task(
  id: id,
  text: text,
  done: done ?? this.done,
  categorySlug: clearCategorySlug ? null : (categorySlug ?? this.categorySlug),
  priority: priority,
  timeLabel: timeLabel,
);
```

### Step 2: Add `deleteCategory` to `task_dao.dart`

Append after `deleteTask` (line 49):

```dart
Future<void> deleteCategory(String slug) async {
  await (_db.delete(_db.categories)..where((c) => c.slug.equals(slug))).go();
}
```

Note: The `tasks` table has `ON DELETE SET NULL` for `categorySlug` defined via Drift's FK, so deleting the category row automatically nulls the FK in all tasks rows. Verify this is set in `task_database.dart` — if not, the viewmodel will null them manually in memory and the DAO `updateTask` call handles DB side.

### Step 3: Check FK cascade in `task_database.dart`

Open `lib/data/task_database.dart` and verify the `Tasks` table definition. The `categorySlug` column should reference `categories` with `ON DELETE SET NULL`. If the Drift table doesn't declare a FK (Drift doesn't auto-cascade unless declared), the viewmodel `deleteCategory` handles the null-out loop manually — which is fine.

### Step 4: Run tests

```bash
flutter test
```

Expected: all existing tests still pass. No new tests needed here — the null-out logic is covered by viewmodel tests in the next task.

### Step 5: Commit

```bash
git add lib/data/task.dart lib/data/task_dao.dart
git commit -m "feat: fix Task.copyWith null categorySlug, add DAO deleteCategory"
```

---

## Task 4: ViewModel — implement addCategory + deleteCategory

**Files:**
- Modify: `lib/ui/todo_viewmodel.dart` (lines 129–130 — replace stubs)

### Step 1: Add `toSlug` import check

`lib/utils/slug.dart` already exists with `toSlug()`. Confirm it's exported and the import path is `'../utils/slug.dart'`.

### Step 2: Replace stubs in `todo_viewmodel.dart`

Add import at top if not present:
```dart
import '../utils/slug.dart';
```

Replace lines 129–130:
```dart
// BEFORE
Future<void> addCategory(String label) async {}
Future<void> deleteCategory(String slug) async {}

// AFTER
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
  // Null out categorySlug on affected tasks in DB
  final affected = s.tasks.where((t) => t.categorySlug == slug).toList();
  for (final t in affected) {
    final cleared = t.copyWith(clearCategorySlug: true);
    await _dao.updateTask(cleared);
  }
  await _dao.deleteCategory(slug);
  // Update in-memory state
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
```

Also add the `_showToast` helper if not present (check viewmodel — `addTask` calls it inline; extract or duplicate):

```dart
void _showToast(String message) {
  final s = state.requireValue;
  state = AsyncValue.data(s.copyWith(toastMessage: message));
  _scheduleToastDismiss();
}
```

> **Check first:** search for `_showToast` in `todo_viewmodel.dart`. If `addTask` sets `toastMessage` inline rather than calling a helper, extract a `_showToast` method and update `addTask` to call it too. This avoids duplication.

### Step 3: Run tests

```bash
flutter test
```

Expected: all tests pass.

### Step 4: Commit

```bash
git add lib/ui/todo_viewmodel.dart lib/utils/slug.dart
git commit -m "feat: implement addCategory and deleteCategory in viewmodel"
```

---

## Task 5: TagFilterRow UI

**Files:**
- Create: `lib/ui/components/tag_filter_row.dart`
- Modify: `lib/ui/todo_screen.dart` (replace `SizedBox(36)`)

### Step 1: Create `lib/ui/components/tag_filter_row.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/category.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_state.dart';
import '../todo_viewmodel.dart';

class TagFilterRow extends ConsumerWidget {
  final List<Category> categories;
  final CategoryFilter activeFilter;

  const TagFilterRow({
    super.key,
    required this.categories,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(todoViewmodelProvider.notifier);
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          spacing: 5,
          children: [
            _TagPill(
              slug: 'all',
              label: 'tất cả',
              isActive: activeFilter is AllCategories,
              canDelete: false,
              onTap: () => vm.filterByCategory(const AllCategories()),
              onDelete: null,
            ),
            ...categories.map((c) => _TagPill(
              slug: c.slug,
              label: c.label,
              isActive: activeFilter is SpecificCategory &&
                  (activeFilter as SpecificCategory).slug == c.slug,
              canDelete: true,
              onTap: () => vm.filterByCategory(SpecificCategory(c.slug)),
              onDelete: () => vm.deleteCategory(c.slug),
            )),
            _AddCategoryButton(onAdd: (label) => vm.addCategory(label)),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatefulWidget {
  final String slug;
  final String label;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TagPill({
    required this.slug,
    required this.label,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_TagPill> createState() => _TagPillState();
}

class _TagPillState extends State<_TagPill> {
  bool _deletable = false;

  void _enterDeleteMode() {
    if (!widget.canDelete) return;
    setState(() => _deletable = true);
  }

  void _exitDeleteMode() {
    setState(() => _deletable = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_deletable) {
          widget.onDelete?.call();
          _exitDeleteMode();
        } else {
          widget.onTap();
        }
      },
      onLongPress: _enterDeleteMode,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.isActive ? AppColors.accentGlow : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDim.radiusLg),
              border: Border.all(
                color: widget.isActive ? AppColors.accentDim : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
            child: Text(
              widget.label,
              style: AppText.tagText.copyWith(
                color: widget.isActive ? AppColors.accent : AppColors.textDim,
              ),
            ),
          ),
          if (widget.canDelete)
            Positioned(
              top: -5,
              right: -5,
              child: AnimatedOpacity(
                opacity: _deletable ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: () {
                    widget.onDelete?.call();
                    _exitDeleteMode();
                  },
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.x,
                      size: 8,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddCategoryButton extends StatefulWidget {
  final Future<void> Function(String label) onAdd;
  const _AddCategoryButton({required this.onAdd});

  @override
  State<_AddCategoryButton> createState() => _AddCategoryButtonState();
}

class _AddCategoryButtonState extends State<_AddCategoryButton> {
  bool _inputVisible = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _inputVisible) {
        setState(() => _inputVisible = false);
        _controller.clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _inputVisible = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) widget.onAdd(text);
    _controller.clear();
    setState(() => _inputVisible = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _inputVisible
              ? SizedBox(
                  width: 88,
                  height: 27,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: AppText.tagText,
                    cursorColor: AppColors.accent,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 4,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDim.radiusLg),
                        borderSide: const BorderSide(color: AppColors.accentDim),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDim.radiusLg),
                        borderSide: const BorderSide(color: AppColors.accentDim),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDim.radiusLg),
                        borderSide: const BorderSide(color: AppColors.accentDim),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (!_inputVisible)
          GestureDetector(
            onTap: _open,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: _DashedCirclePainter(color: AppColors.border),
                child: const Center(
                  child: Icon(
                    PhosphorIconsRegular.plus,
                    size: 11,
                    color: AppColors.textDim2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashCount = 12;
    const gapRatio = 0.4; // fraction of arc that's a gap
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 0.5;
    const fullAngle = 2 * 3.14159;
    final dashAngle = (fullAngle / dashCount) * (1 - gapRatio);
    final gapAngle  = (fullAngle / dashCount) * gapRatio;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, dashAngle, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
```

> **Phosphor icon names:** In `phosphor_flutter` ^2.x, use `PhosphorIconsRegular.x` and `PhosphorIconsRegular.plus`. If the package version uses a different API (e.g. `PhosphorIcons.x()` or `PhosphorIconsBold.x`), adjust accordingly. Check `pubspec.lock` for the exact version installed, then look up the correct import in the package's README.

### Step 2: Wire into `todo_screen.dart`

Replace `SizedBox(36)` placeholder:
```dart
// BEFORE
const SizedBox(height: 36),   // TagFilterRow placeholder

// AFTER
TagFilterRow(
  categories: state.categories,
  activeFilter: state.categoryFilter,
),
```

Add import:
```dart
import 'components/tag_filter_row.dart';
```

### Step 3: Run on device

Verify:
- Pills render: "tất cả" + seed categories
- Tapping a pill filters the task list
- Active pill gets gold border + glow
- Long-press pill → red × badge appears
- Tapping × badge deletes category + toast shows + filter resets
- Tapping "+" → 88dp input field animates in
- Type category name + Enter → new pill appears + toast shows
- Focus lost → input disappears without adding

### Step 4: Commit

```bash
git add lib/ui/components/tag_filter_row.dart lib/ui/todo_screen.dart
git commit -m "feat: add TagFilterRow with category pills, add/delete category UI"
```

---

## Task 6: StatusBar component

**Files:**
- Create: `lib/ui/components/status_bar.dart`
- Modify: `lib/ui/todo_screen.dart` (replace `SizedBox(52)`)

### Step 1: Create `lib/ui/components/status_bar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.only(left: 26, right: 26, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Time — updates every minute
            StreamBuilder<DateTime>(
              initialData: DateTime.now(),
              stream: Stream.periodic(
                const Duration(minutes: 1),
                (_) => DateTime.now(),
              ),
              builder: (_, snap) {
                final time = DateFormat('HH:mm').format(snap.data!);
                return Text(time, style: AppText.statusTime);
              },
            ),
            // Status icons
            const Row(
              spacing: 6,
              children: [
                Icon(PhosphorIconsRegular.cellSignalFull, size: 16, color: AppColors.text),
                Icon(PhosphorIconsRegular.wifiHigh,       size: 16, color: AppColors.text),
                Icon(PhosphorIconsRegular.battery,        size: 16, color: AppColors.text),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Phosphor icon names to verify:** `cellSignalFull`, `wifiHigh`, `battery` — check that these exist in the installed version. Alternatives: `cellSignal`, `wifi`, `batteryFull`. Run `flutter pub deps` and look at the phosphor_flutter source or README for the exact icon list.

### Step 2: Wire into `todo_screen.dart`

Replace `SizedBox(52)` placeholder:
```dart
// BEFORE
const SizedBox(height: 52),   // StatusBar placeholder

// AFTER
const StatusBar(),
```

Add import:
```dart
import 'components/status_bar.dart';
```

### Step 3: Run on device

Verify: time displays in top-left in correct format, 3 icons in top-right, height feels right.

### Step 4: Commit

```bash
git add lib/ui/components/status_bar.dart lib/ui/todo_screen.dart
git commit -m "feat: add StatusBar with live clock and status icons"
```

---

## Final verification

After all 6 tasks complete:

```bash
flutter test
flutter run --release
```

Full checklist:
- [ ] Date string correct format: "thứ X · DD tháng M"
- [ ] "Hôm nay" + count aligned on baseline
- [ ] Progress bar animates on task toggle (500ms)
- [ ] Glow dot visible at any progress > 0
- [ ] "đang làm" / "xong rồi" tabs switch correctly
- [ ] Underline animates between tabs (150ms)
- [ ] Switching tabs resets category filter to "tất cả"
- [ ] Category pills filter task list correctly
- [ ] Active pill: gold border + accentGlow background
- [ ] Long press pill → × badge, tap → category deleted
- [ ] Deleted category tasks lose their tag chip
- [ ] "+" button opens inline input, Enter commits
- [ ] Adding category shows toast '+ "label"'
- [ ] Deleting category shows toast 'category đã xoá'
- [ ] StatusBar shows current time
- [ ] No Material ripple anywhere
- [ ] All 50 tests pass

```bash
git log --oneline -8
```

Expected recent commits (newest first):
```
feat: add StatusBar with live clock and status icons
feat: add TagFilterRow with category pills, add/delete category UI
feat: implement addCategory and deleteCategory in viewmodel
feat: fix Task.copyWith null categorySlug, add DAO deleteCategory
feat: add TodoTabBar component, implement switchTab with filter reset
feat: add Header component (date, title, progress bar)
```
