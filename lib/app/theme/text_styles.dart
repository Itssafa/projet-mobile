import 'package:flutter/material.dart';

class AppTextStyles{
  static const String headFontFamily = 'Catamaran';
  static const String bodyFontFamily = 'Noto Sans';

  static const TextStyle body = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );

  static const TextStyle header1= TextStyle(
    fontFamily: headFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}