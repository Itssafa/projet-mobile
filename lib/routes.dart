import 'package:flutter/material.dart';
import 'package:my_app/features/pet/pages/home_page.dart';
import 'package:my_app/features/pet/pages/pet_page.dart';
import 'package:my_app/features/authentication/views/onboarding.dart';
import 'package:my_app/features/authentication/views/login.dart';
import 'package:my_app/features/authentication/views/sign_up.dart';
import 'package:my_app/features/food/views/food_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
//ONboarding screen
  '/onboarding': (context) => const OnboardingPage1(),  
//login screen
  '/login': (context) => const SignInPage1(),  
  '/signup': (context) => const SignUpPage1(),  
//HOme 
  '/home': (context) => const HomePage(),
//Pet Page
  '/pets': (context) => const PetPage(),
//food
  '/food': (context) => const FoodScreen(),
};
