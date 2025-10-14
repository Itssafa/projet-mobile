import 'package:hive/hive.dart';
import '../../../core/hive_boxes.dart';
import '../models/food.dart';

class FoodService {
  final box = HiveBoxes.getFoodBox();

  Future<void> addFood(Food food) async => await box.add(food);

  List<Food> getFoods() => box.values.toList();

  Future<void> updateFood(Food food) async => await food.save();

  Future<void> deleteFood(Food food) async => await food.delete();

  Future<void> clearAll() async => await box.clear();
}
