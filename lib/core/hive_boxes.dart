import 'package:hive/hive.dart';
import '../features/food/models/food.dart';

class HiveBoxes {
  static Box<Food> getFoodBox() => Hive.box<Food>('foods');
}
