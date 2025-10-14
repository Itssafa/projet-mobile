import 'package:flutter/material.dart';
import '../controller/food_controller.dart';
import '../models/food.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final FoodController controller = FoodController();
  final petCtrl = TextEditingController();
  final foodCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final timeCtrl = TextEditingController();

  void _addFood() async {
    if (petCtrl.text.isEmpty ||
        foodCtrl.text.isEmpty ||
        qtyCtrl.text.isEmpty ||
        timeCtrl.text.isEmpty) return;

    final mealTime = DateTime.tryParse(timeCtrl.text);
    if (mealTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid date format. Use YYYY-MM-DD HH:MM")),
      );
      return;
    }

    await controller.addFood(Food(
      petName: petCtrl.text,
      foodName: foodCtrl.text,
      quantity: int.parse(qtyCtrl.text),
      time: mealTime,
    ));

    setState(() {
      petCtrl.clear();
      foodCtrl.clear();
      qtyCtrl.clear();
      timeCtrl.clear();
    });
  }

  void _updateFood(Food food) {
    final petCtrl = TextEditingController(text: food.petName);
    final foodCtrl = TextEditingController(text: food.foodName);
    final qtyCtrl = TextEditingController(text: food.quantity.toString());
    final timeCtrl = TextEditingController(text: food.time.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Food"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: petCtrl, decoration: const InputDecoration(labelText: 'Pet Name')),
            TextField(controller: foodCtrl, decoration: const InputDecoration(labelText: 'Food Name')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (YYYY-MM-DD HH:MM)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final parsedTime = DateTime.tryParse(timeCtrl.text) ?? food.time;
              food.petName = petCtrl.text;
              food.foodName = foodCtrl.text;
              food.quantity = int.tryParse(qtyCtrl.text) ?? food.quantity;
              food.time = parsedTime;
              await controller.updateFood(food);
              setState(() {}); // refresh UI
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteFood(Food food) async {
    await controller.deleteFood(food);
    setState(() {});
  }

  void _showStats() {
    final stats = controller.getFoodStats();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Food Statistics"),
        content: Text(
          "Total meals: ${stats['totalMeals']}\n"
              "Most eaten: ${stats['mostEaten']}\n"
              "Missed meal today: ${stats['mealMissed'] ? 'Yes' : 'No'}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foods = controller.getFoods();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Service "),
        actions: [
          IconButton(
              icon: const Icon(Icons.bar_chart), onPressed: _showStats),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: petCtrl, decoration: const InputDecoration(labelText: "Pet Name")),
            TextField(controller: foodCtrl, decoration: const InputDecoration(labelText: "Food Name")),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Quantity (g)")),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time (YYYY-MM-DD HH:MM)")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addFood, child: const Text("Add Food")),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, i) {
                  final f = foods[i];
                  return Card(
                    child: ListTile(
                      title: Text("${f.petName} - ${f.foodName}"),
                      subtitle: Text("Quantity: ${f.quantity}g | Time: ${f.time}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _updateFood(f)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFood(f)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
