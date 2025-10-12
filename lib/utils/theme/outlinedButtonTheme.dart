import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';

class COutlinedButtonTheme{
  COutlinedButtonTheme._();

  static final LightButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.grey_100,
      backgroundColor: AppColors.primary,
      disabledBackgroundColor: AppColors.grey_700,
      disabledForegroundColor: AppColors.grey_900,
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(fontSize: 14 , color: AppColors.grey_100 , fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
    )
    );

  static final DarkButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.grey_100,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.grey_700,
          disabledForegroundColor: AppColors.grey_900,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 14 , color: AppColors.grey_100 , fontWeight: FontWeight.normal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
      )
  );



}