import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_state.dart';

class Header extends StatelessWidget {
  final TodoState state;
  const Header({super.key, required this.state});

  String _dateString() {
    final now = DateTime.now();
    const days = ['thứ hai','thứ ba','thứ tư','thứ năm','thứ sáu','thứ bảy','chủ nhật'];
    final day = days[now.weekday - 1];
    final d = now.day;
    final m = now.month;
    return '$day · $d tháng $m';
  }

  @override
  Widget build(BuildContext context) {
    final done  = state.doneCount;
    final total = state.totalCount;
    final ratio = total == 0 ? 0.0 : done / total;
    final pct   = (ratio * 100).round();
    final countString = state.pendingCount > 0
        ? '${state.pendingCount} việc còn lại'
        : 'tất cả xong rồi';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Text(_dateString(), style: AppText.dateLabel),
          const SizedBox(height: 5),

          // Title + count
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Hôm nay', style: AppText.title),
              const SizedBox(width: 10),
              Text(countString, style: AppText.taskCount),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          LayoutBuilder(builder: (_, constraints) {
            final maxW = constraints.maxWidth;
            final fillW = (ratio * maxW).clamp(0.0, maxW);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5, // tall enough to contain glow dot
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Track
                      Positioned(
                        top: 1.75, left: 0, right: 0,
                        child: Container(
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      // Fill
                      Positioned(
                        top: 1.75, left: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                          width: fillW,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      // Glow dot
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        left: fillW - 2.5,
                        top: 0,
                        child: AnimatedOpacity(
                          opacity: ratio > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: AppDim.dotSize,
                            height: AppDim.dotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Meta row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$done / $total xong', style: AppText.progressLabel),
                    Text('$pct%', style: AppText.progressPct),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
