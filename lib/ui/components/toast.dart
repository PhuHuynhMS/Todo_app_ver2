import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class TaskToast extends StatelessWidget {
  final String? message;
  const TaskToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final visible = message != null;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, -0.3),
        duration: const Duration(milliseconds: 180),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surface3, width: 1),
            ),
            child: Text(message ?? '', style: AppText.progressLabel),
          ),
        ),
      ),
    );
  }
}
