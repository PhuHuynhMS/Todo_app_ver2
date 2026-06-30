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
