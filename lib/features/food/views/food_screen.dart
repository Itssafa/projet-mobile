import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

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

  String selectedAnimal = "dog";
  Map<String, dynamic>? _suggestedMeal;
  bool _loadingSuggestion = false;

  // 🐾 Add food locally
  void _addFood() async {
    if (petCtrl.text.isEmpty ||
        foodCtrl.text.isEmpty ||
        qtyCtrl.text.isEmpty ||
        timeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final mealTime = DateTime.tryParse(timeCtrl.text);
    if (mealTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid date format. Use YYYY-MM-DD HH:MM")),
      );
      return;
    }

    await controller.addFood(Food(
      petName: petCtrl.text,
      foodName: foodCtrl.text,
      quantity: int.parse(qtyCtrl.text),
      time: mealTime,
    ));

    setState(() {});
    petCtrl.clear();
    foodCtrl.clear();
    qtyCtrl.clear();
    timeCtrl.clear();
  }

  // ✏️ Update food
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
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 🗑 Delete
  void _deleteFood(Food food) async {
    await controller.deleteFood(food);
    setState(() {});
  }

  // 📊 Stats
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

  // 🐕‍🦺 Fetch random meal suggestion from OpenPetFoodFacts API
  Future<void> _fetchSuggestedMeal() async {
    setState(() {
      _loadingSuggestion = true;
      _suggestedMeal = null;
    });

    final url = Uri.parse(
        'https://world.openpetfoodfacts.org/api/v2/search?categories_tags_en=${selectedAnimal}-food&fields=product_name,brands,ingredients_text,image_url&page_size=50');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List?;

        if (products == null || products.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No meals found, try again.")),
          );
        } else {
          final randomProduct = products[Random().nextInt(products.length)];
          setState(() {
            _suggestedMeal = {
              "name": randomProduct['product_name'] ?? "Unknown meal",
              "brand": randomProduct['brands'] ?? "Unknown brand",
              "ingredients":
              randomProduct['ingredients_text'] ?? "No ingredients listed",
              "image": randomProduct['image_url'],
            };
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching from API.")),
        );
      }
    } catch (e) {
      debugPrint("Error fetching API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      _loadingSuggestion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final foods = controller.getFoods();

    return Scaffold(
      appBar: AppBar(
        title: const Text("🐾 Food Service"),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: _showStats),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Input Section ---
            TextField(controller: petCtrl, decoration: const InputDecoration(labelText: "Pet Name")),
            TextField(controller: foodCtrl, decoration: const InputDecoration(labelText: "Food Name")),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Quantity (g)")),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time (YYYY-MM-DD HH:MM)")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addFood, child: const Text("Add Food")),
            const SizedBox(height: 20),

            // --- Pet Type + API Suggestion Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedAnimal,
                  items: const [
                    DropdownMenuItem(value: "dog", child: Text("🐶 Dog")),
                    DropdownMenuItem(value: "cat", child: Text("🐱 Cat")),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedAnimal = val!;
                      _suggestedMeal = null;
                    });
                  },
                ),
                ElevatedButton.icon(
                  onPressed: _fetchSuggestedMeal,
                  icon: const Icon(Icons.restaurant),
                  label: const Text("Suggest Food"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_loadingSuggestion)
              const CircularProgressIndicator()
            else if (_suggestedMeal != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_suggestedMeal!['image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _suggestedMeal!['image'],
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _suggestedMeal!['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Brand: ${_suggestedMeal!['brand']}"),
                      const SizedBox(height: 6),
                      Text(
                        "Ingredients: ${_suggestedMeal!['ingredients']}",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --- Local food list ---
            const Divider(),
            const Text("My Added Foods",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            if (foods.isEmpty)
              const Text("No foods added yet.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foods.length,
                itemBuilder: (context, i) {
                  final f = foods[i];
                  return Card(
                    child: ListTile(
                      title: Text("${f.petName} - ${f.foodName}"),
                      subtitle: Text(
                          "Quantity: ${f.quantity}g | Time: ${f.time.toString().split('.').first}"),
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
          ],
        ),
      ),
    );
  }
}
