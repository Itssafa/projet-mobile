import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

class AppTheme {
  //light mOde
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.ligh_bg,
    colorScheme: ColorScheme.light(
        primary: AppColors.blue_700,
        onPrimary: Colors.white,
        secondary: AppColors.yellow_700,
        onSecondary: Colors.white,
        error: AppColors.error,
        surface:AppColors.grey_100 ,
        onSurface: AppColors.grey_1000
    ),
    //TODO : Add dark common colors
    //TODO : Add font condition
  );
}