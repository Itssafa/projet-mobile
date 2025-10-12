import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
class CTextTheme{
  CTextTheme._();
  static TextTheme LightTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith( fontSize: 32.0, fontWeight: FontWeight.bold, color: AppColors.grey_800),
    headlineMedium: TextStyle().copyWith( fontSize: 28.0, fontWeight: FontWeight.w600, color: AppColors.grey_800),
    headlineSmall: TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w500, color: AppColors.grey_800,),

    // 3. Title text styles (AppBar, Dialogs, Cards)
    titleLarge: TextStyle().copyWith(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),
    titleMedium: TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500, // Medium weight for subtitles
      color: AppColors.grey_800,
    ),
    titleSmall: TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),

    // 4. Body text styles (Main Content)
    bodyLarge: TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_800,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_800,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_800,
    ),

    // 5. Label text styles (Buttons, Input Labels, Captions)
    labelLarge: TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500, // Typically medium/semi-bold for buttons
      color: AppColors.grey_800,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),
    labelSmall: TextStyle().copyWith(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_800,
    ),
  );
  static TextTheme DarkTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith( fontSize: 32.0, fontWeight: FontWeight.bold, color: AppColors.grey_100),
    headlineMedium: TextStyle().copyWith( fontSize: 24.0, fontWeight: FontWeight.w600, color: AppColors.grey_100),
    // 3. Title text styles (AppBar, Dialogs, Cards)
    titleLarge: TextStyle().copyWith(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),
    titleMedium: TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500, // Medium weight for subtitles
      color: AppColors.grey_100,
    ),
    titleSmall: TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),

    // 4. Body text styles (Main Content)
    bodyLarge: TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_100,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_100,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.grey_100,
    ),

    // 5. Label text styles (Buttons, Input Labels, Captions)
    labelLarge: TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500, // Typically medium/semi-bold for buttons
      color: AppColors.grey_100,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),
    labelSmall: TextStyle().copyWith(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      color: AppColors.grey_100,
    ),
  );
}