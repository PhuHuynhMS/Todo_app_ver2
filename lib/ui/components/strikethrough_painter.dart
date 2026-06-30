import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class StrikethroughPainter extends CustomPainter {
  final double progress;
  const StrikethroughPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      Paint()
        ..color = AppColors.doneText
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(StrikethroughPainter old) => old.progress != progress;
}
