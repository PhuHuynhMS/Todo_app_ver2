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
