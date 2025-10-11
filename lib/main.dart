import 'package:flutter/material.dart';
import 'package:my_app/common/theme/app_theme.dart';
import 'package:my_app/common/theme/colors.dart';
import 'package:my_app/common/theme/text_styles.dart';


void main() {
  runApp(const MyApp());
}

String name = "hello world";
int number = 1;
List myList = ["hello" , "hello" ];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawLink',
      theme: AppTheme.lightTheme,
    );
  }
}