import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/features/authentication/views/onboarding.dart';
import 'package:my_app/features/Budget/views/budget_page.dart';
import 'package:my_app/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: CAppTheme.lightTheme,
      darkTheme: CAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingPage1(),
      getPages: [
        GetPage(name: '/', page: () => const OnboardingPage1()),
        GetPage(name: '/budget', page: () => BudgetPage()),
      ],
    );
  }
}
