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
        padding: const EdgeInsets.only(top: 9, bottom: 9, right: 22),
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
