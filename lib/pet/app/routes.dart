import 'package:flutter/material.dart';
import 'package:my_app/pet/pages/home_page.dart';
import 'package:my_app/pet/pages/pet_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/pets': (context) => const PetPage(),
};
