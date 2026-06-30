# Todo App — Flutter Design Specification v3
> **Platform:** Flutter (Android-first, min SDK 26)  
> **UI framework:** Flutter/Dart + Jetpack Compose bị loại bỏ  
> **Agent note:** Đọc toàn bộ spec trước khi viết bất kỳ dòng code nào. Mọi quyết định design đã final.

---

## 0. Conventions

- `dp` → logical pixel trong Flutter, mapping 1:1
- Màu dùng `Color(0xFFRRGGBB)` hoặc `Color(0xAARRGGBB)`
- Font size là `double` (sp equivalent)
- `→` = "kết quả" / "dẫn đến"
- `[UPDATED v3]` = thay đổi so với v2

---

## 1. Design tokens

### 1.1 Colors — `lib/theme/colors.dart` `[UPDATED v3]`

```dart
class AppColors {
  // Backgrounds — sâu hơn v2
  static const bg        = Color(0xFF111111);  // was #141414
  static const surface   = Color(0xFF191919);  // was #1E1E1E
  static const surface2  = Color(0xFF222222);  // was #252525
  static const surface3  = Color(0xFF2A2A2A);  // new — tertiary layer
  static const border    = Color(0xFF282828);  // was #2E2E2E

  // Text
  static const text      = Color(0xFFE4DDD4);  // was #E8E2D9 — slightly warmer
  static const textDim   = Color(0xFF5A5550);  // was #6B6560 — darker
  static const textDim2  = Color(0xFF3D3A37);  // new — very muted

  // Accent
  static const accent    = Color(0xFFC9A96E);  // unchanged
  static const accentDim = Color(0xFF7A6440);  // unchanged
  static const accentGlow = Color(0x1FC9A96E); // new — 12% alpha, bg tint for active pill

  // Semantic
  static const doneText  = Color(0xFF3E3B38);  // was #4A4540
  static const red       = Color(0xFFB85A45);  // was #C4604A — slightly darker
  static const pressHold = Color(0x0AB85A45);  // long-press tint
}
```

### 1.2 Typography — `lib/theme/text_styles.dart` `[UPDATED v3]`

Fonts: `IBMPlexMono` (300, 300i, 400, 500) + `Inter` (300, 400, 500, 600)

```dart
class AppText {
  // Task text — [UPDATED] 15→14.5sp, height 1.45→1.5
  static const taskText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 14.5, fontWeight: FontWeight.w400,
    color: AppColors.text, height: 1.5,
  );

  // Meta: tag chip, time
  static const metaText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim2,
  );

  // Tag filter pills — [UPDATED] 11→10.5sp
  static const tagText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 10.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.25,
  );

  // Section label "ưu tiên cao" / "còn lại" — [UPDATED] letterSpacing 1.5→1.8
  static const labelText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9, fontWeight: FontWeight.w400,
    color: AppColors.textDim2, letterSpacing: 1.8,
  );

  // Tab buttons
  static const tabText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );

  // Input field — [UPDATED] 14→13.5sp
  static const inputText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 13.5, fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  // Header title
  static const title = TextStyle(
    fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w600,
    color: AppColors.text, letterSpacing: -1.0,
  );

  // Header eyebrow date — [UPDATED] italic, letter-spacing 0.8
  static const dateLabel = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 10, fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
    color: AppColors.textDim, letterSpacing: 0.8,
  );

  // Header task count — [NEW] inline with title
  static const taskCount = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.3,
  );

  // Status bar time
  static const statusTime = TextStyle(
    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.text, letterSpacing: -0.4,
  );

  // Progress label + pct
  static const progressLabel = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.3,
  );
  static const progressPct = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.accentDim, letterSpacing: 0.3,
  );
}
```

### 1.3 Spacing & shape `[UPDATED v3]`

```dart
class AppDim {
  static const screenPadH = 24.0;
  static const taskPadV   = 13.0;   // was 14
  static const radiusSm   = 3.0;    // tag chip
  static const radiusMd   = 12.0;   // input, add button (was 10)
  static const radiusLg   = 100.0;  // tag filter pill — full pill
  static const borderW    = 1.0;
  static const progressH  = 1.5;    // was 2.0
  static const dotSize    = 5.0;
  static const checkboxSz = 19.0;   // was 20
  static const addBtnSz   = 41.0;   // was 42
}
```

**Không dùng elevation/shadow.** Phân tách bằng màu `border` và 1dp dividers.

---

## 2. Data model — `lib/data/` `[UPDATED v3]`

### 2.1 `category.dart` — `[NEW]`

Categories giờ là dynamic, user-created. Không còn là hardcoded enum.

```dart
class Category {
  final String slug;    // internal key, lowercase-hyphen, e.g. "affi-tiktok"
  final String label;   // display name, e.g. "affi tiktok"

  const Category({required this.slug, required this.label});
}
```

Seed categories (insert nếu bảng `categories` trống):
```dart
const seedCategories = [
  Category(slug: 'work',     label: 'work'),
  Category(slug: 'personal', label: 'cá nhân'),
  Category(slug: 'startup',  label: 'startup'),
  Category(slug: 'buy',      label: 'mua đồ'),
];
```

### 2.2 `task.dart` `[UPDATED v3]`

`TaskTag` enum bị xoá — tag giờ là `String? categorySlug`.

```dart
enum TaskPriority { high, mid, low }

class Task {
  final int id;
  final String text;
  final bool done;
  final String? categorySlug;   // nullable; references Category.slug
  final TaskPriority priority;
  final String? timeLabel;      // nullable, e.g. "14:00"

  const Task({
    required this.id,
    required this.text,
    required this.done,
    this.categorySlug,
    required this.priority,
    this.timeLabel,
  });

  Task copyWith({bool? done, String? categorySlug}) => Task(
    id: id, text: text,
    done: done ?? this.done,
    categorySlug: categorySlug ?? this.categorySlug,
    priority: priority, timeLabel: timeLabel,
  );
}
```

### 2.3 DB — `lib/data/task_database.dart` (Drift)

Hai tables:

```
Table: categories
  slug  TEXT PRIMARY KEY
  label TEXT NOT NULL

Table: tasks
  id            INTEGER PRIMARY KEY AUTOINCREMENT
  text          TEXT NOT NULL
  done          INTEGER NOT NULL DEFAULT 0    (0/1)
  categorySlug  TEXT REFERENCES categories(slug) ON DELETE SET NULL
  priority      TEXT NOT NULL                 ('high'|'mid'|'low')
  timeLabel     TEXT
```

### 2.4 Seed data

```dart
const seedTasks = [
  Task(id:1, text:'Review PR trước 11h',       done:false, categorySlug:'work',     priority:TaskPriority.high, timeLabel:'9:00'),
  Task(id:2, text:'Họp sync team lúc 2h',       done:false, categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:'14:00'),
  Task(id:3, text:'Mua sữa và trứng',           done:false, categorySlug:'buy',      priority:TaskPriority.low,  timeLabel:null),
  Task(id:4, text:'Viết spec cho feature mới',  done:true,  categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:null),
  Task(id:5, text:'Gọi điện cho nhà',           done:false, categorySlug:'personal', priority:TaskPriority.low,  timeLabel:'20:00'),
  Task(id:6, text:'Update deck cho investor',   done:false, categorySlug:'startup',  priority:TaskPriority.high, timeLabel:null),
];
```

---

## 3. State — `lib/ui/todo_state.dart` `[UPDATED v3]`

```dart
enum ActiveTab { pending, done }

sealed class CategoryFilter { const CategoryFilter(); }
class AllCategories extends CategoryFilter { const AllCategories(); }
class SpecificCategory extends CategoryFilter {
  final String slug;
  const SpecificCategory(this.slug);
}

class TodoState {
  final List<Task> tasks;
  final List<Category> categories;   // [NEW] dynamic list
  final ActiveTab activeTab;
  final CategoryFilter categoryFilter;
  final String inputText;
  final String? toastMessage;

  // derived
  List<Task> get filtered => tasks.where((t) {
    final tabOk = activeTab == ActiveTab.pending ? !t.done : t.done;
    final catOk = categoryFilter is AllCategories ||
                  t.categorySlug == (categoryFilter as SpecificCategory).slug;
    return tabOk && catOk;
  }).toList();

  List<Task> get highPriority => filtered.where((t) => t.priority == TaskPriority.high).toList();
  List<Task> get restPriority => filtered.where((t) => t.priority != TaskPriority.high).toList();

  int get doneCount    => tasks.where((t) => t.done).length;
  int get totalCount   => tasks.length;
  int get pendingCount => tasks.where((t) => !t.done).length;
}
```

### ViewModel events `[UPDATED v3]`

```dart
void toggleTask(int id)
void addTask(String text)
void deleteTask(int id)
void switchTab(ActiveTab tab)
void filterByCategory(CategoryFilter filter)
void updateInput(String text)
void dismissToast()

// [NEW] category management
void addCategory(String label)       // slug = label.toLowerCase().replaceAll(' ', '-')
void deleteCategory(String slug)     // also sets categorySlug=null on affected tasks
```

---

## 4. Screen anatomy

```
┌─────────────────────────────┐  SafeArea top
│ StatusBar           52dp    │
├─────────────────────────────┤
│ Header                      │  eyebrow + title+count row + progress
│   eyebrow           ~20dp   │  italic date label
│   title + count row ~36dp   │  "Hôm nay" baseline-aligned with count
│   progress block    ~28dp   │  bar 1.5dp + meta row (label + pct)
│   bottom gap        12dp    │
├─────────────────────────────┤
│ TagFilterRow         36dp   │  pills + "+" button
├─────────────────────────────┤
│ TabBar               38dp   │
├─────────────────────────────┤
│ TaskList             flex   │  pb=84dp
├─────────────────────────────┤
│ BottomSheet          ~74dp  │  input + add button
└─────────────────────────────┘
```

---

## 5. Components

### 5.1 StatusBar

- `height: 52`, `padding: EdgeInsets.only(left:26, right:26, bottom:8)`
- Time: `AppText.statusTime`, update via `Stream.periodic(Duration(minutes:1))`
- Right icons: signal bars, wifi arc, battery — custom SVG assets or `CustomPainter`

### 5.2 Header `[UPDATED v3]`

`padding: EdgeInsets.fromLTRB(24, 4, 24, 0)`

**Eyebrow (date)**
```
Text(dateString, style: AppText.dateLabel)
// format: "thứ X · DD tháng M"   ← dấu · thay dấu phẩy
// margin bottom: 5dp
```

**Title + Count row**
```
Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
  Text('Hôm nay', style: AppText.title),
  SizedBox(width: 10),
  Text(countString, style: AppText.taskCount),
  // countString:
  //   pendingCount > 0 → "${pendingCount} việc còn lại"
  //   pendingCount == 0 → "tất cả xong rồi"
])
// margin bottom: 16dp
```

**Progress bar**
```
// Track
Container(height: 1.5, color: AppColors.border, borderRadius: 1)

// Fill — AnimatedContainer
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  curve: Curves.fastOutSlowIn,
  width: ratio * maxWidth,
  height: 1.5,
  decoration: BoxDecoration(
    color: AppColors.accent,
    borderRadius: BorderRadius.circular(1),
  ),
  // Glow tip: CustomPaint hoặc Stack với positioned glowing dot
  // Dot 5×5dp, color accent, boxShadow: [BoxShadow(color: accent.withOpacity(.5), blurRadius:8, spreadRadius:2)]
  // Hiện khi ratio > 0, ẩn khi ratio == 0 (AnimatedOpacity)
)
```

**Progress meta row** (margin top: 5dp, margin bottom: 12dp)
```
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  Text('$doneCount / $totalCount xong', style: AppText.progressLabel),
  Text('$pct%', style: AppText.progressPct),
])
```

### 5.3 TagFilterRow `[UPDATED v3]`

```
SingleChildScrollView(scrollDirection: Axis.horizontal,
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Row(spacing: 5, children: [
      TagPill(slug:'all', label:'tất cả', canDelete: false),
      ...categories.map((c) => TagPill(slug:c.slug, label:c.label, canDelete:true)),
      AddCategoryButton(),
    ]),
  ),
)
```

**TagPill** `[UPDATED v3]`

```dart
// [ACTIVE] state — transparent bg → accentGlow tint
AnimatedContainer(
  duration: Duration(milliseconds: 150),
  decoration: BoxDecoration(
    color: isActive ? AppColors.accentGlow : Colors.transparent,   // was surface2
    borderRadius: BorderRadius.circular(AppDim.radiusLg),
    border: Border.all(
      color: isActive ? AppColors.accentDim : AppColors.border,
      width: 1,
    ),
  ),
  padding: EdgeInsets.symmetric(horizontal:11, vertical:4.5),
  child: Text(label, style: AppText.tagText.copyWith(
    color: isActive ? AppColors.accent : AppColors.textDim,
  )),
)
```

Interactions:
- `onTap` → `filterByCategory(SpecificCategory(slug))` hoặc `AllCategories()`
- `onLongPress` (nếu `canDelete`) → sau 600ms hiện badge `×` đỏ góc trên phải; tap tiếp để confirm xoá

**AddCategoryButton** `[NEW]`
```
GestureDetector(
  onTap: openInlineInput,
  child: Container(
    width:24, height:24,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.border, width:1, style: BorderStyle.dashed),  // approximate — dùng CustomPaint
    ),
    child: Icon(PhosphorIcons.plus, size:11, color: AppColors.textDim2),
  ),
)
```

**Inline category input flow:**
1. Tap `+` → `TextField` nhỏ hiện inline trong Row, `width:88dp`, border `accentDim`, `borderRadius: radiusLg`
2. `textInputAction: TextInputAction.done` → commit
3. Esc / focus lost → cancel, remove field
4. Commit: `addCategory(text.trim())` → slug tự tính

**Slug generation:**
```dart
String toSlug(String label) =>
  label.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '-')
       .replaceAll(RegExp(r'[^\w\-]'), '');
```

**Delete category flow:**
1. Long press pill → 600ms → badge `×` màu `red` hiện ở góc top-right
2. Tap pill (trong state deletable) → `deleteCategory(slug)`
3. `deleteCategory` sets `categorySlug = null` trên tất cả tasks có tag đó, rồi xoá category

### 5.4 TabBar

```
Container(
  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width:1))),
  padding: EdgeInsets.symmetric(horizontal: 24),
  child: Row(children: [
    TabButton(label:'đang làm', tab: ActiveTab.pending),
    TabButton(label:'xong rồi', tab: ActiveTab.done),
  ]),
)
```

**TabButton**
```
padding: EdgeInsets.only(top:9, bottom:9, right:22)
border-bottom: 1.5dp solid (active ? accent : transparent)
text style: tabText.copyWith(color: isActive ? accent : textDim)
Animate: AnimatedContainer color 150ms
```

### 5.5 TaskList

`ListView.builder`, `contentPadding: EdgeInsets.only(bottom: 84)`

Grouping (pending tab):
```
SectionLabel('ưu tiên cao')  if highPriority.isNotEmpty
...highPriority.map(TaskItem)
SectionLabel('còn lại')      if restPriority.isNotEmpty
...restPriority.map(TaskItem)
```

Done tab: flat, no labels.

**SectionLabel**
```
Padding(
  padding: EdgeInsets.fromLTRB(24, 16, 24, 7),
  child: Text(text.toUpperCase(), style: AppText.labelText),
)
```

**EmptyState**
```
Center(child: Column(children: [
  Text('─────', style: AppText.labelText),
  SizedBox(height: 10),
  Text(msg, style: AppText.labelText.copyWith(letterSpacing:.6)),
  SizedBox(height: 0),
  Text('─────', style: AppText.labelText),
]))
// msg: 'không có việc gì' (pending) | 'chưa xong gì hết' (done)
```

### 5.6 TaskItem

```dart
GestureDetector(
  onTap: () => viewModel.toggleTask(task.id),
  onLongPress: () => viewModel.deleteTask(task.id),
  child: Container(
    padding: EdgeInsets.symmetric(horizontal:24, vertical:13),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border, width:1)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PriorityDot(priority: task.priority),
      SizedBox(width: 11),
      CustomCheckbox(isDone: task.done),
      SizedBox(width: 11),
      Expanded(child: TaskContent(task: task, categories: categories)),
    ]),
  ),
)
```

**PriorityDot**
```
Container(
  width: 5, height: 5, margin: EdgeInsets.only(top:7),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: task.priority == high  ? AppColors.red
         : task.priority == mid   ? AppColors.accent
         :                          AppColors.border,
  ),
)
```

**CustomCheckbox** (19×19dp)
```
AnimatedContainer(
  width:19, height:19,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isDone ? AppColors.accentDim : Colors.transparent,
    border: Border.all(color: isDone ? AppColors.accentDim : AppColors.surface3, width:1.5),
  ),
  child: isDone
    ? AnimatedOpacity(opacity:1, duration:200ms,
        child: CustomPaint(painter: CheckmarkPainter()))
    : AnimatedOpacity(opacity:0, duration:200ms, child: CustomPaint(painter: CheckmarkPainter())),
)
// ⚠ KHÔNG dùng Material Checkbox widget
```

**StrikethroughText** (xem Section 10–11 cho painter code)
```dart
// Stack([
//   Text(task.text, style: isDone ? taskText.copyWith(color:doneText) : taskText),
//   CustomPaint(painter: StrikethroughPainter(progress: _anim.value)),
// ])
// AnimationController 380ms, FastOutSlowIn
// ⚠ KHÔNG dùng TextDecoration.lineThrough
```

**TagChip**
```
Container(
  padding: EdgeInsets.symmetric(horizontal:7, vertical:2),
  decoration: BoxDecoration(
    color: AppColors.surface2,
    borderRadius: BorderRadius.circular(AppDim.radiusSm),
  ),
  child: Text(categoryLabel, style: AppText.metaText),
)
// categoryLabel = categories.firstWhere((c)=>c.slug==task.categorySlug).label
```

### 5.7 BottomSheet

```dart
Positioned(bottom:0, left:0, right:0,
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border, width:1)),
    ),
    padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
    child: Row(children: [InputWrap, SizedBox(width:9), AddButton]),
  ),
)
```

**InputWrap**
```dart
AnimatedContainer(
  duration: Duration(milliseconds:200),
  decoration: BoxDecoration(
    color: AppColors.bg,      // bg, NOT surface2 — tạo depth
    borderRadius: BorderRadius.circular(AppDim.radiusMd),  // 12dp
    border: Border.all(color: isFocused ? AppColors.accentDim : AppColors.border, width:1),
  ),
  padding: EdgeInsets.symmetric(horizontal:13),
  child: Row(children: [
    Text('+', style: TextStyle(fontFamily:'IBMPlexMono', fontSize:14, color:AppColors.textDim2)),
    SizedBox(width:9),
    Expanded(child: TextField(
      style: AppText.inputText,
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: 'thêm việc cần làm...',
        hintStyle: AppText.inputText.copyWith(color: AppColors.textDim2),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical:11),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (t) => viewModel.addTask(t),
    )),
  ]),
)
```

**AddButton**
```dart
GestureDetector(
  onTap: () { viewModel.addTask(controller.text); controller.clear(); },
  child: AnimatedScale(
    scale: isPressed ? 0.94 : 1.0,
    duration: Duration(milliseconds:150),
    child: Container(
      width: AppDim.addBtnSz, height: AppDim.addBtnSz,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDim.radiusMd),
      ),
      child: CustomPaint(painter: PlusPainter()),
      // PlusPainter: vẽ "+" với stroke #111111, width 2dp, round cap
    ),
  ),
)
```

### 5.8 Toast

```dart
// Positioned(top:62, left:0, right:0, child: Center(...))
// AnimatedOpacity + AnimatedSlide(offset: Offset(0, isVisible ? 0 : -0.3))
// Duration: 180ms enter, 180ms exit
// Auto-dismiss: 1800ms

Container(
  padding: EdgeInsets.symmetric(horizontal:15, vertical:6),
  decoration: BoxDecoration(
    color: AppColors.surface2,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.surface3, width:1),
  ),
  child: Text(message, style: AppText.progressLabel),
)
```

---

## 6. Business logic `[UPDATED v3]`

### addTask(String text)

```
1. text = text.trim(); if empty → return
2. Auto-detect categorySlug (check theo thứ tự):
   'buy'      ← /mua|chợ|siêu thị|order/i
   'work'     ← /họp|pr|deploy|code|review|api|bug|spec/i
   'personal' ← /gọi|điện|nhà|gia đình|bạn/i
   'startup'  ← /investor|startup|deck|pitch|fund/i
   null       ← kiểm tra tiếp: nếu text chứa bất kỳ category slug hoặc label nào
                  → dùng category đó (cho phép custom cats tự match)
3. Auto-detect priority:
   HIGH ← /gấp|urgent|quan trọng|ngay|trước|deadline/i
   MID  ← /hôm nay|today|lúc \d/i
   LOW  ← default
4. tasks.insert(0, Task(...))
5. clearInput()
6. showToast('đã thêm')
7. Persist to DB
```

### addCategory(String label) `[NEW]`

```
1. label = label.trim(); if empty → return
2. slug = toSlug(label)
3. if categories.any((c) => c.slug == slug) → return (dupe)
4. categories.add(Category(slug, label))
5. Persist to DB
6. showToast('+ "$label"')
```

### deleteCategory(String slug) `[NEW]`

```
1. categories.removeWhere((c) => c.slug == slug)
2. tasks: forEach(t) { if t.categorySlug == slug → t.categorySlug = null }
3. if activeFilter == SpecificCategory(slug) → reset to AllCategories()
4. Persist both tables to DB
5. showToast('category đã xoá')
```

### toggleTask / deleteTask / filtering / grouping

Không thay đổi so với v2. Chỉ thay `tag` → `categorySlug` trong filter logic.

---

## 7. Animations `[UPDATED v3]`

| Widget | Trigger | Type | Duration | Curve |
|--------|---------|------|----------|-------|
| Progress bar fill | task count change | `AnimatedContainer` width | 500ms | `Curves.fastOutSlowIn` |
| Progress glow dot | ratio > 0 | `AnimatedOpacity` 0→1 | 300ms | default |
| Checkbox fill/border | toggleTask | `AnimatedContainer` color | 200ms | default |
| Checkmark | task done | `AnimatedOpacity` 0→1 | 200ms | default |
| Strikethrough line | task done | `CustomPainter` + `AnimationController` | 380ms | `Curves.fastOutSlowIn` |
| Add button press | pointer down | `AnimatedScale` 0.94 + `AnimatedOpacity` 0.8 | 150ms | default |
| Toast enter | showToast | `AnimatedOpacity` + `AnimatedSlide` Y -0.3→0 | 180ms | default |
| Toast exit | auto/dismiss | `AnimatedOpacity` | 180ms | default |
| TagPill bg/border/text | filter change | `AnimatedContainer` | 150ms | default |
| Inline category input | tap "+" | `AnimatedSize` expand width 0→88dp | 200ms | `Curves.easeOut` |

**Không thêm animation nào khác.**

---

## 8. Prohibited

```
❌ FloatingActionButton
❌ BottomNavigationBar
❌ AppBar / SliverAppBar
❌ Material Card (elevation > 0)
❌ LinearProgressIndicator từ Material
❌ Checkbox widget từ Material
❌ TextDecoration.lineThrough — custom painter only
❌ Gradient background hoặc gradient button
❌ Border radius > 20dp trên TaskItem
❌ Empty state illustration hoặc Lottie
❌ Swipe-to-delete (long press only)
❌ SnackBar (custom Toast only)
❌ Confirmation dialog trước khi xoá task hoặc category
❌ Light theme / dark mode toggle (dark only)
❌ SplashScreen
❌ Onboarding
❌ showModalBottomSheet
❌ Navigator.push / multi-screen
❌ Material ripple (InkWell.splashColor = transparent)
❌ Hardcoded TaskTag enum (đã bị xoá — dùng String categorySlug)
```

---

## 9. File structure `[UPDATED v3]`

```
lib/
├── main.dart
├── theme/
│   ├── colors.dart
│   └── text_styles.dart
├── data/
│   ├── category.dart          // Category model [NEW]
│   ├── task.dart              // Task model (categorySlug thay tag)
│   ├── task_database.dart     // Drift DB, 2 tables
│   └── task_dao.dart          // DAO: tasks + categories
├── ui/
│   ├── todo_state.dart        // TodoState + CategoryFilter sealed class
│   ├── todo_viewmodel.dart    // + addCategory, deleteCategory
│   ├── todo_screen.dart
│   └── components/
│       ├── status_bar.dart
│       ├── header.dart                  // eyebrow + title+count + progress
│       ├── tag_filter_row.dart          // dynamic pills + inline input
│       ├── add_category_button.dart     // dashed circle "+" [NEW]
│       ├── tab_bar.dart
│       ├── task_list.dart
│       ├── task_item.dart
│       ├── strikethrough_text.dart
│       ├── bottom_sheet.dart
│       └── toast.dart
└── utils/
    ├── task_auto_detect.dart   // tag + priority detection
    └── slug.dart               // toSlug() helper [NEW]
```

### pubspec.yaml dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.x
  sqlite3_flutter_libs: ^0.x
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  intl: ^0.x
  phosphor_flutter: ^2.x        # icon library [NEW — replaces hand-rolled SVGs]

dev_dependencies:
  flutter_launcher_icons: ^0.13.x
  drift_dev: ^2.x
  build_runner: ^2.x
  riverpod_generator: ^2.x

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

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/todo_icon_1024.png"
  adaptive_icon_background: "#111111"   // [UPDATED] was #141414
  adaptive_icon_foreground: "assets/icon/todo_icon_1024.png"
  min_sdk_android: 26
```

---

## 10. CheckmarkPainter

```dart
class CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.11, size.height * 0.50)
      ..lineTo(size.width * 0.38, size.height * 0.86)
      ..lineTo(size.width * 0.89, size.height * 0.14);

    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}
```

---

## 11. StrikethroughPainter

```dart
class StrikethroughPainter extends CustomPainter {
  final double progress;  // 0.0 → 1.0
  const StrikethroughPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()
      ..color = AppColors.doneText
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      paint,
    );
  }

  @override bool shouldRepaint(StrikethroughPainter old) => old.progress != progress;
}
```

---

## 12. App Icon

### Concept

**"The Strike"** — khoảnh khắc chính xác khi task được hoàn thành. Đường gạch vàng `#C9A96E` kẻ xuyên qua "review PR". Ba task rows trên nền tối, chỉ dòng đầu có strikethrough. Pen-touch blob trái, pen-lift taper phải.

### Files

```
assets/icon/todo_icon_1024.png   ← master, Play Store
assets/icon/todo_icon_512.png
assets/icon/todo_icon_192.png    ← xxxhdpi
assets/icon/todo_icon_96.png     ← xxhdpi
assets/icon/todo_icon_48.png     ← mdpi
```

### Icon colors (update adaptive bg)

```
Background:       #111111   [UPDATED từ #141414 — match app bg mới]
Strikethrough:    #C9A96E
Text done:        #4A4540
Text active:      #E4DDD4   [UPDATED từ #E8E2D9]
Rules:            #282828   [UPDATED từ #2E2E2E]
```

### Không làm

```
❌ Không thêm shadow/glow vào icon background
❌ Không đổi màu nền khác #111111
❌ Không thêm app name text
❌ Không scale up để fill canvas — negative space là ý đồ
```
