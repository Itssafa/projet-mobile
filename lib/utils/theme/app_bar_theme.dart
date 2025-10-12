import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';

class CAppBarTheme{
CAppBarTheme._();
static const LightAppBarTheme = AppBarTheme(
  elevation: 0,
  centerTitle: false,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: AppColors.grey_1000 , size: 24),
  actionsIconTheme: IconThemeData(color: AppColors.grey_1000 , size: 24),
  titleTextStyle: TextStyle(fontSize: 20 , color: AppColors.grey_800, fontWeight: FontWeight.w600),

);
static const DarkAppBarTheme = AppBarTheme(
  elevation: 0,
  centerTitle: false,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: AppColors.grey_100 , size: 24),
  actionsIconTheme: IconThemeData(color: AppColors.grey_100 , size: 24),
  titleTextStyle: TextStyle(fontSize: 20 , color: AppColors.grey_100, fontWeight: FontWeight.w600),

);

}