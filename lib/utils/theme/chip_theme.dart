import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColors.grey_700.withValues(alpha: 0.5),
    labelStyle: const TextStyle(color: AppColors.grey_1000),
    selectedColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingMd),
    checkmarkColor: AppColors.grey_100,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: AppColors.grey_700,
    labelStyle: TextStyle(color: AppColors.grey_100),
    selectedColor:  AppColors.primary,
    padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingMd),
    checkmarkColor: AppColors.grey_100,
  );
}
