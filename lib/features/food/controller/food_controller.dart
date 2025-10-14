import '../models/food.dart';
import 'food_service.dart';
import 'food_logic.dart';

class FoodController {
  final FoodService _service = FoodService();
  final FoodLogic _logic = FoodLogic();

  Future<void> addFood(Food food) => _service.addFood(food);

  Future<void> updateFood(Food food) => _service.updateFood(food);

  Future<void> deleteFood(Food food) => _service.deleteFood(food);

  List<Food> getFoods() => _service.getFoods();

  Map<String, dynamic> getFoodStats() => _logic.getFoodStats(getFoods());
}
