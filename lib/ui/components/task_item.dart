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
