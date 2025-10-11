import 'package:flutter/material.dart';
import 'package:my_app/app/theme/app_theme.dart';
import 'package:my_app/app/theme/colors.dart';
import 'package:my_app/app/theme/text_styles.dart';


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
