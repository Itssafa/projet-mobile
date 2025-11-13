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

  // Add Food
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

  // ---------- NEW: helper to extract an image URL from API product ----------
  String? _extractImageUrl(dynamic product) {
    if (product == null) return null;

    // Common direct keys
    final candidates = [
      'image_url',
      'image_small_url',
      'image_front_url',
      'image_front_small_url',
      'image_thumb_url',
      'image_front_thumb_url'
    ];

    try {
      if (product is Map) {
        for (final key in candidates) {
          if (product.containsKey(key) && product[key] is String && (product[key] as String).isNotEmpty) {
            return product[key] as String;
          }
        }

        // Some responses include an 'images' map with nested structures.
        // We'll do a shallow recursive search for any string that looks like an http URL.
        String? found;
        void search(dynamic node) {
          if (found != null) return;
          if (node is String) {
            if (node.startsWith('http')) {
              found = node;
            }
            return;
          }
          if (node is Map) {
            for (final v in node.values) {
              search(v);
              if (found != null) return;
            }
          }
          if (node is List) {
            for (final v in node) {
              search(v);
              if (found != null) return;
            }
          }
        }

        if (product.containsKey('images')) {
          search(product['images']);
          if (found != null) return found;
        }

        // As a last resort check all values
        search(product);
        return found;
      } else if (product is String) {
        if (product.startsWith('http')) return product;
      }
    } catch (_) {
      // ignore parsing errors
    }
    return null;
  }

  // Fetch Suggested Meal (uses image extraction helper)
  Future<void> _fetchSuggestedMeal() async {
    setState(() {
      _loadingSuggestion = true;
      _suggestedMeal = null;
    });

    final url = Uri.parse(
        'https://world.openpetfoodfacts.org/api/v2/search?categories_tags_en=${selectedAnimal}-food&fields=product_name,brands,ingredients_text,image_url,images&page_size=50');

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
          final imageUrl = _extractImageUrl(randomProduct) ??
              "https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg";

          setState(() {
            _suggestedMeal = {
              "name": randomProduct['product_name'] ?? "Unknown meal",
              "brand": randomProduct['brands'] ?? "Unknown brand",
              "ingredients": randomProduct['ingredients_text'] ?? "No ingredients listed",
              "image": imageUrl,
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
    } finally {
      setState(() {
        _loadingSuggestion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foods = controller.getFoods();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Meal"),
        onPressed: _addFood,
      ),
      body: CustomScrollView(
        slivers: [
          // 🌈 HEADER
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.teal,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: const Text(
                "🐾 Pet Food Tracker",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                onPressed: _showStats,
              ),
            ],
          ),

          // 🐕 Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🧾 Input Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: petCtrl,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.pets_rounded),
                              labelText: "Pet Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: foodCtrl,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.fastfood_rounded),
                              labelText: "Food Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.scale_rounded),
                              labelText: "Quantity (g)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: timeCtrl,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.access_time_rounded),
                              labelText: "Time (YYYY-MM-DD HH:MM)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🦴 Suggestion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: selectedAnimal,
                        borderRadius: BorderRadius.circular(12),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: _fetchSuggestedMeal,
                        icon: const Icon(Icons.restaurant_menu_rounded),
                        label: const Text("Suggest"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_loadingSuggestion)
                    const Center(child: CircularProgressIndicator())
                  else if (_suggestedMeal != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🖼️ Display image from API (if available)
                          if (_suggestedMeal!['image'] != null && (_suggestedMeal!['image'] as String).isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                _suggestedMeal!['image'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _suggestedMeal!['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text("Brand: ${_suggestedMeal!['brand']}"),
                                const SizedBox(height: 6),
                                Text(
                                  "Ingredients: ${_suggestedMeal!['ingredients']}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    "My Added Foods",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (foods.isEmpty)
                    const Text("No foods added yet.",
                        style: TextStyle(color: Colors.black54))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: foods.length,
                      itemBuilder: (context, i) {
                        final f = foods[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: const Icon(Icons.pets_rounded, color: Colors.teal),
                            ),
                            title: Text("${f.petName} - ${f.foodName}",
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              "Quantity: ${f.quantity}g\nTime: ${f.time.toString().split('.').first}",
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _updateFood(f),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteFood(f),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
