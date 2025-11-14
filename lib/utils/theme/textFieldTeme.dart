import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';

class CTextFormField {
  CTextFormField._();

  // 🌞 LIGHT THEME
 static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.grey_1000,
    suffixIconColor: AppColors.grey_1000,

    labelStyle: const TextStyle(
      fontSize: AppSizes.inputFieldRadius,
      color: AppColors.grey_1000,
    ),
    hintStyle: const TextStyle(
      fontSize: AppSizes.inputFieldRadius,
      color: AppColors.grey_1000,
    ),
    errorStyle: const TextStyle(fontStyle: FontStyle.normal),

    floatingLabelStyle: const TextStyle(
      color: AppColors.grey_1000,
    ).copyWith(color: AppColors.grey_1000.withOpacity(0.8)),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.grey_500,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.grey_500,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.grey_1000,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.error,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthMd,
        color: AppColors.blue_300,
      ),
    ),
  );

  // 🌙 DARK THEME
static InputDecorationTheme DarkInputDecorationTheme = InputDecorationTheme(   errorMaxLines: 3,
    prefixIconColor: AppColors.grey_100,
    suffixIconColor: AppColors.grey_100,

    labelStyle: const TextStyle(
      fontSize: AppSizes.inputFieldRadius,
      color: AppColors.grey_100,
    ),
    hintStyle: const TextStyle(
      fontSize: AppSizes.inputFieldRadius,
      color: AppColors.grey_100,
    ),
    errorStyle: const TextStyle(fontStyle: FontStyle.normal),

    floatingLabelStyle: const TextStyle(
      color: AppColors.grey_100,
    ).copyWith(color: AppColors.grey_100.withOpacity(0.8)),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.grey_500,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.grey_500,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.grey_100,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthThin,
        color: AppColors.error,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: AppSizes.borderWidthMd,
        color: AppColors.blue_300,
      ),
    ),
  );
}
