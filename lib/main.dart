import 'package:flutter/material.dart';
import 'package:my_app/app/theme/app_theme.dart';
import 'package:my_app/app/theme/colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawLink'),
        backgroundColor: AppColors.blue_700, // Main app color
      ),
      body: const Center(
        child: Text(
          'Welcome to PawLink!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
