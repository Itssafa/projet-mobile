class Feeding {
  final int? id;
  final int animalId;
  final String foodType;
  final double dailyQuantity; // en grammes
  final List<String> mealTimes; // Format: ["08:00", "18:00"]
  final double currentStock; // en grammes
  final DateTime lastStockUpdate;

  Feeding({
    this.id,
    required this.animalId,
    required this.foodType,
    required this.dailyQuantity,
    required this.mealTimes,
    required this.currentStock,
    required this.lastStockUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'food_type': foodType,
      'daily_quantity': dailyQuantity,
      'meal_times': mealTimes.join(','),
      'current_stock': currentStock,
      'last_stock_update': lastStockUpdate.toIso8601String(),
    };
  }

  factory Feeding.fromMap(Map<String, dynamic> map) {
    return Feeding(
      id: map['id'] as int?,
      animalId: map['animal_id'] as int,
      foodType: map['food_type'] as String,
      dailyQuantity: map['daily_quantity'] as double,
      mealTimes: (map['meal_times'] as String).split(','),
      currentStock: map['current_stock'] as double,
      lastStockUpdate: DateTime.parse(map['last_stock_update'] as String),
    );
  }

  // Calculer les jours restants avant épuisement
  int get daysUntilStockout {
    if (dailyQuantity <= 0) return 0;
    return (currentStock / dailyQuantity).floor();
  }

  // Statut du stock
  StockStatus get stockStatus {
    final days = daysUntilStockout;
    if (days <= 2) return StockStatus.critical;
    if (days <= 5) return StockStatus.warning;
    return StockStatus.sufficient;
  }
}

enum StockStatus {
  sufficient,
  warning,
  critical,
}


