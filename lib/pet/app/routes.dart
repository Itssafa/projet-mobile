import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/pet_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomePage(),
  '/pets': (context) => const PetPage(),
};
