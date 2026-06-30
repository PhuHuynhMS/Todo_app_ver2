import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_viewmodel.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  final _ctrl      = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused  = false;
  bool _isPressed  = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(todoViewmodelProvider.notifier).addTask(_ctrl.text);
    _ctrl.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(children: [
        Expanded(child: _InputWrap(
          controller: _ctrl,
          focusNode: _focusNode,
          isFocused: _isFocused,
          onSubmitted: (_) => _submit(),
        )),
        const SizedBox(width: 9),
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp:   (_) { setState(() => _isPressed = false); _submit(); },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 41, height: 41,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(painter: _PlusPainter()),
            ),
          ),
        ),
      ]),
    );
  }
}

class _InputWrap extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onSubmitted;

  const _InputWrap({
    required this.controller, required this.focusNode,
    required this.isFocused,  required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.accentDim : AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(children: [
        const Text('+', style: TextStyle(
          fontFamily: 'IBMPlexMono', fontSize: 14, color: AppColors.textDim2,
        )),
        const SizedBox(width: 9),
        Expanded(child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: AppText.inputText,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'thêm việc cần làm...',
            hintStyle: AppText.inputText.copyWith(color: AppColors.textDim2),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
        )),
      ]),
    );
  }
}

class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const h = 7.0;
    canvas.drawLine(Offset(cx - h, cy), Offset(cx + h, cy), paint);
    canvas.drawLine(Offset(cx, cy - h), Offset(cx, cy + h), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
