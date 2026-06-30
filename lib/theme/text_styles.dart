import 'package:flutter/material.dart';
import 'colors.dart';

class AppText {
  static const taskText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 14.5, fontWeight: FontWeight.w400,
    color: AppColors.text, height: 1.5,
  );
  static const metaText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim2,
  );
  static const tagText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 10.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.25,
  );
  static const labelText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9, fontWeight: FontWeight.w400,
    color: AppColors.textDim2, letterSpacing: 1.8,
  );
  static const tabText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );
  static const inputText = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 13.5, fontWeight: FontWeight.w400,
    color: AppColors.text,
  );
  static const title = TextStyle(
    fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w600,
    color: AppColors.text, letterSpacing: -1.0,
  );
  static const dateLabel = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 10, fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic, color: AppColors.textDim, letterSpacing: 0.8,
  );
  static const taskCount = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.3,
  );
  static const statusTime = TextStyle(
    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.text, letterSpacing: -0.4,
  );
  static const progressLabel = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.textDim, letterSpacing: 0.3,
  );
  static const progressPct = TextStyle(
    fontFamily: 'IBMPlexMono', fontSize: 9.5, fontWeight: FontWeight.w400,
    color: AppColors.accentDim, letterSpacing: 0.3,
  );
}

class AppDim {
  static const screenPadH = 24.0;
  static const taskPadV   = 13.0;
  static const radiusSm   = 3.0;
  static const radiusMd   = 12.0;
  static const radiusLg   = 100.0;
  static const borderW    = 1.0;
  static const progressH  = 1.5;
  static const dotSize    = 5.0;
  static const checkboxSz = 19.0;
  static const addBtnSz   = 41.0;
}
