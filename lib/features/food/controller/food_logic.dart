import '../models/food.dart';

class FoodLogic {
  String mostEatenFood(List<Food> foods) {
    if (foods.isEmpty) return "No data";
    final Map<String, int> counter = {};
    for (var f in foods) {
      counter[f.foodName] = (counter[f.foodName] ?? 0) + 1;
    }
    final sorted = counter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  bool isMealMissed(List<Food> foods) {
    final now = DateTime.now();
    final todayMeals = foods.where((f) =>
    f.time.day == now.day &&
        f.time.month == now.month &&
        f.time.year == now.year).length;
    return todayMeals < 2; // Less than 2 meals = missed
  }

  double calculateMonthlyCost({
    required double pricePerKg,
    required int gramsPerMeal,
    required int mealsPerDay,
  }) {
    final dailyCost = (gramsPerMeal / 1000) * pricePerKg * mealsPerDay;
    return double.parse((dailyCost * 30).toStringAsFixed(2));
  }

  Map<String, dynamic> getFoodStats(List<Food> foods) {
    return {
      "totalMeals": foods.length,
      "mostEaten": mostEatenFood(foods),
      "mealMissed": isMealMissed(foods),
    };
  }
}
