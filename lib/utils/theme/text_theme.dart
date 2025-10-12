import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';
class CTextTheme{
  CTextTheme._();
  static TextTheme LightTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith( fontSize: AppSizes.fontXxl, fontWeight: FontWeight.bold, color: AppColors.grey_800),
    headlineMedium: TextStyle().copyWith( fontSize: AppSizes.fontXl2, fontWeight: FontWeight.w600, color: AppColors.grey_800),
    headlineSmall: TextStyle().copyWith(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w500, color: AppColors.grey_800,),

    // 3. Title text styles (AppBar, Dialogs, Cards)
    titleLarge: TextStyle().copyWith(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),
    titleMedium: TextStyle().copyWith(
      fontSize: AppSizes.fontLg,
      fontWeight: FontWeight.w500, // Medium weight for subtitles
      color: AppColors.grey_800,
    ),
    titleSmall: TextStyle().copyWith(
      fontSize: AppSizes.fontMd,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),

    // 4. Body text styles (Main Content)
    bodyLarge: TextStyle().copyWith(
      fontSize: AppSizes.fontLg,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_800,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: AppSizes.fontMd,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_800,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: AppSizes.fontSm,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_800,
    ),

    // 5. Label text styles (Buttons, Input Labels, Captions)
    labelLarge: TextStyle().copyWith(
      fontSize: AppSizes.fontMd,
      fontWeight: FontWeight.w500, // Typically medium/semi-bold for buttons
      color: AppColors.grey_800,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: AppSizes.fontSm,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),
    labelSmall: TextStyle().copyWith(
      fontSize: AppSizes.fontXs,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),
  );
  static TextTheme DarkTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith( fontSize: AppSizes.fontXxl, fontWeight: FontWeight.bold, color: AppColors.grey_100),
    headlineMedium: TextStyle().copyWith( fontSize: AppSizes.fontXl2, fontWeight: FontWeight.w600, color: AppColors.grey_800),
    headlineSmall: TextStyle().copyWith( fontSize: AppSizes.fontXl, fontWeight: FontWeight.w600, color: AppColors.grey_100),
    // 3. Title text styles (AppBar, Dialogs, Cards)
    titleLarge: TextStyle().copyWith(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),
    titleMedium: TextStyle().copyWith(
      fontSize: AppSizes.fontLg,
      fontWeight: FontWeight.w500, // Medium weight for subtitles
      color: AppColors.grey_100,
    ),
    titleSmall: TextStyle().copyWith(
      fontSize: AppSizes.fontMd,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),

    // 4. Body text styles (Main Content)
    bodyLarge: TextStyle().copyWith(
      fontSize: AppSizes.fontLg,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_100,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: AppSizes.fontMd,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_100,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: AppSizes.fontSm,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_100,
    ),

    // 5. Label text styles (Buttons, Input Labels, Captions)
    labelLarge: TextStyle().copyWith(
      fontSize: AppSizes.fontMd,
      fontWeight: FontWeight.w500, // Typically medium/semi-bold for buttons
      color: AppColors.grey_100,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: AppSizes.fontSm,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),
    labelSmall: TextStyle().copyWith(
      fontSize: AppSizes.fontXs,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),
  );
}