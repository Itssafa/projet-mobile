import 'package:flutter/material.dart';
import 'package:my_app/utils/theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/food/models/food.dart';
import 'features/food/views/food_screen.dart';
import 'package:my_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FoodAdapter());
  await Hive.openBox<Food>('foods');

  runApp(const App());
}

