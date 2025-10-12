import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
class Cbottomsheettheme {
  Cbottomsheettheme._();

  static BottomSheetThemeData LightButtonSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: AppColors.grey_100,
    modalBackgroundColor:  AppColors.grey_100,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  static BottomSheetThemeData DarkButtonSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: AppColors.grey_1000,
    modalBackgroundColor:  AppColors.grey_1000,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

}