import 'package:flutter/material.dart';
import 'package:my_app/utils/theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/food/models/food.dart';
import 'features/food/views/food_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FoodAdapter());
  await Hive.openBox<Food>('foods');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCare Food CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const FoodScreen(),
    );
  }
}
