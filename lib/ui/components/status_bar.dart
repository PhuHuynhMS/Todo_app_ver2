import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.only(left: 26, right: 26, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Time — updates every minute
            StreamBuilder<DateTime>(
              initialData: DateTime.now(),
              stream: Stream.periodic(
                const Duration(minutes: 1),
                (_) => DateTime.now(),
              ),
              builder: (_, snap) {
                final time = DateFormat('HH:mm').format(snap.data!);
                return Text(time, style: AppText.statusTime);
              },
            ),
            // Status icons
            const Row(
              spacing: 6,
              children: [
                Icon(PhosphorIconsRegular.cellSignalFull, size: 16, color: AppColors.text),
                Icon(PhosphorIconsRegular.wifiHigh,       size: 16, color: AppColors.text),
                Icon(PhosphorIconsRegular.batteryFull,    size: 16, color: AppColors.text),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
