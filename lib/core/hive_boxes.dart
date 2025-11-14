import 'package:hive/hive.dart';
import '../features/food/models/food.dart';
import 'package:my_app/features/authentication/models/user.dart';
class HiveBoxes {
  static const String authBox = 'auth';

  // Typed box getters
  static Box<Food> getFoodBox() => Hive.box<Food>('foods');
  static Box<User> getUserBox() => Hive.box<User>(authBox);
}
