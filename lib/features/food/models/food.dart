import 'package:hive/hive.dart';

part 'food.g.dart';

@HiveType(typeId: 0)
class Food extends HiveObject {
  @HiveField(0)
  String petName;

  @HiveField(1)
  String foodName;

  @HiveField(2)
  int quantity; // grams

  @HiveField(3)
  DateTime time;

  Food({
    required this.petName,
    required this.foodName,
    required this.quantity,
    required this.time,
  });
}
