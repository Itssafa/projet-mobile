import 'package:flutter/material.dart';
import 'package:my_app/utils/constants/colors.dart';

import 'package:my_app/utils/constants/sizes.dart';

class CAppBarTheme{
CAppBarTheme._();
static const LightAppBarTheme = AppBarTheme(
  elevation: 0,
  centerTitle: false,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: AppColors.grey_1000 , size: AppSizes.iconMd),
  actionsIconTheme: IconThemeData(color: AppColors.grey_1000 , size: AppSizes.iconMd),
  titleTextStyle: TextStyle(fontSize: AppSizes.fontLg , color: AppColors.grey_800, fontWeight: FontWeight.w600),

);
static const DarkAppBarTheme = AppBarTheme(
  elevation: 0,
  centerTitle: false,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: AppColors.grey_100 , size: AppSizes.iconMd),
  actionsIconTheme: IconThemeData(color: AppColors.grey_100 , size: AppSizes.iconMd),
  titleTextStyle: TextStyle(fontSize: AppSizes.fontLg , color: AppColors.grey_100, fontWeight: FontWeight.w600),

);

}