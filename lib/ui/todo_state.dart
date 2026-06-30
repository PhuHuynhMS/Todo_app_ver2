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
  final Set<int> animatingIds;

  const TodoState({
    required this.tasks,
    required this.categories,
    required this.activeTab,
    required this.categoryFilter,
    required this.inputText,
    required this.toastMessage,
    this.animatingIds = const {},
  });

  List<Task> get filtered => tasks.where((t) {
    if (animatingIds.contains(t.id)) return true; // keep during animation
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
    Set<int>? animatingIds,
  }) => TodoState(
    tasks: tasks ?? this.tasks,
    categories: categories ?? this.categories,
    activeTab: activeTab ?? this.activeTab,
    categoryFilter: categoryFilter ?? this.categoryFilter,
    inputText: inputText ?? this.inputText,
    toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    animatingIds: animatingIds ?? this.animatingIds,
  );
}
