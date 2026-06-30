import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.11, size.height * 0.50)
        ..lineTo(size.width * 0.38, size.height * 0.86)
        ..lineTo(size.width * 0.89, size.height * 0.14),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
