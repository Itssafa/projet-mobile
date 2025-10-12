import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/theme/app_bar_theme.dart';
import 'package:my_app/utils/theme/text_theme.dart';
import 'package:my_app/utils/theme/elevatedButtonTheme.dart';
import 'package:my_app/utils/theme/checkBox_theme.dart';

import 'outlinedButtonTheme.dart';
import 'textFieldTeme.dart';
import 'bottonSheetTheme.dart';

class CAppTheme {
  // Hedha constructor bich yesstaaml marra barka / _ => private
  CAppTheme._();
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.ligh_bg,
    textTheme: CTextTheme.LightTextTheme,
    elevatedButtonTheme: CElevatedButtonTheme.LightButtonTheme,
    outlinedButtonTheme: COutlinedButtonTheme.LightButtonTheme,
    appBarTheme: CAppBarTheme.LightAppBarTheme,
    checkboxTheme: CcheckBoxTheme.lightCheckboxTheme,
    inputDecorationTheme: CTextFormField.lightInputDecorationTheme,
    bottomSheetTheme: Cbottomsheettheme.DarkButtonSheetTheme,

  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.dark_bg,
    textTheme: CTextTheme.DarkTextTheme,
    elevatedButtonTheme: CElevatedButtonTheme.DarkButtonTheme,
    outlinedButtonTheme: COutlinedButtonTheme.DarkButtonTheme,
    appBarTheme: CAppBarTheme.DarkAppBarTheme,
    checkboxTheme: CcheckBoxTheme.darkCheckboxTheme,
    inputDecorationTheme: CTextFormField.DarkInputDecorationTheme,
    bottomSheetTheme: Cbottomsheettheme.DarkButtonSheetTheme,

  );



}