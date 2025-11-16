import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    fontFamily: 'NotoSansKR',
    scaffoldBackgroundColor: AppColors.bgColor,
    primaryColor: AppColors.primaryLaurel,
    colorScheme: ColorScheme.light(primary: AppColors.primaryLaurel),

    appBarTheme: AppBarTheme(backgroundColor: AppColors.white),
  );
}
