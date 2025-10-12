import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';

class COutlinedButtonTheme{
  COutlinedButtonTheme._();

  static final LightButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.grey_100,
      backgroundColor: AppColors.primary,
      disabledBackgroundColor: AppColors.grey_700,
      disabledForegroundColor: AppColors.grey_900,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
      textStyle: const TextStyle(fontSize: AppSizes.fontMd , color: AppColors.grey_100 , fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.fontMd))
    )
    );

  static final DarkButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.grey_100,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.grey_700,
          disabledForegroundColor: AppColors.grey_900,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
          textStyle: const TextStyle(fontSize: AppSizes.fontMd , color: AppColors.grey_100 , fontWeight: FontWeight.normal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.fontMd))
      )
  );



}