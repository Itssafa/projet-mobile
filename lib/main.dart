import 'package:flutter/material.dart';
import 'package:my_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/food/models/food.dart';
import 'features/food/views/food_screen.dart';
import 'package:my_app/app.dart';
import 'package:my_app/core/hive_boxes.dart';
import 'package:my_app/features/authentication/models/user.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(UserAdapter());


  // Open boxes BEFORE running the app
  await Hive.openBox<User>(HiveBoxes.authBox);   // 'auth' box for users
  await Hive.openBox<Food>('foods');
  runApp(const App());
}

