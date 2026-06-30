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
