import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/sizes.dart';


class CTextFormField{
  CTextFormField._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.grey_1000,
    suffixIconColor: AppColors.grey_1000,
    // constraints: const BoxConstraints.expand(height: AppSizes.inputFieldRadius.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: AppSizes.inputFieldRadius, color: AppColors.grey_1000),
    hintStyle: const TextStyle().copyWith(fontSize: AppSizes.inputFieldRadius, color: AppColors.grey_1000),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: AppColors.grey_1000.withValues(alpha: 0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color: AppColors.grey_500),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color: AppColors.grey_500),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color:AppColors.grey_1000),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color: AppColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthMd, color: AppColors.blue_300),
    ),
  );

  static InputDecorationTheme DarkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.grey_1000,
    suffixIconColor: AppColors.grey_1000,
    // constraints: const BoxConstraints.expand(height: AppSizes.inputFieldRadius.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: AppSizes.inputFieldRadius, color: AppColors.grey_100),
    hintStyle: const TextStyle().copyWith(fontSize: AppSizes.inputFieldRadius, color: AppColors.grey_100),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: AppColors.grey_1000.withValues(alpha: 0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color: AppColors.grey_500),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color: AppColors.grey_500),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color:AppColors.grey_100),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthThin, color: AppColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: AppSizes.borderWidthMd, color: AppColors.blue_300),
    ),
  );

}