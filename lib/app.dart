import'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/features/authentication/views/onboarding.dart';
import 'package:my_app/utils/theme/theme.dart';

class  App extends StatelessWidget {
  const App ({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: CAppTheme.lightTheme,
      darkTheme: CAppTheme.darkTheme,
      home: const OnboardingPage1(),
    );
  }
}
