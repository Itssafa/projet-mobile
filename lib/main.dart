import 'package:flutter/material.dart';
import 'package:my_app/common/styles/app_theme.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/text_styles.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawLink',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final bool enabled=true;
    final VoidCallback? onPressed = enabled ? () {} : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawLink'),
        backgroundColor: AppColors.primary, // Main app color
      ),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
         const  Text(
          'Welcome to PawLink!',
          style: AppTextStyles.header1,
          ),
            FilledButton(onPressed: onPressed, child: const Text("hello") )
      ],
      )
        ),
      );
  }
}
