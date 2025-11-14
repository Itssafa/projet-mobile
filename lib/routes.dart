import 'package:flutter/material.dart';
import 'package:my_app/features/pet/pages/home_page.dart';
import 'package:my_app/features/pet/pages/pet_page.dart';
import 'package:my_app/features/authentication/views/onboarding.dart';
import 'package:my_app/features/authentication/views/login.dart';
import 'package:my_app/features/authentication/views/sign_up.dart';
import 'package:my_app/features/food/views/food_screen.dart';
import 'package:my_app/features/authentication/views/profile.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Onboarding screen
  '/onboarding': (context) => const OnboardingPage1(),  
  // Login screen
  '/login': (context) => const SignInPage1(),  
  // Sign Up screen
  '/signup': (context) => const SignUpPage1(),  
  // Home 
  '/home': (context) => const HomePage(),
  // Pet Page
  '/pets': (context) => const PetPage(),
  // Food
  '/food': (context) => const FoodScreen(),
  // Profile
  '/profile': (context) => const ProfilePage(),
};
