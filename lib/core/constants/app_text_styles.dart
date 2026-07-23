import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textMain,
  );
  static const subheading = TextStyle(
    fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain,
  );
  static const body = TextStyle(
    fontSize: 13, color: AppColors.textMain,
  );
  static const caption = TextStyle(
    fontSize: 12, color: AppColors.textSub,
  );
  static const small = TextStyle(
    fontSize: 11, color: AppColors.textSub,
  );
  static const label = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain,
  );
}
