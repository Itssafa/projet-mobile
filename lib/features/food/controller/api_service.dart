import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>?> fetchPetMeal(String animalType) async {
    final url = Uri.parse(
        'https://world.openpetfoodfacts.org/api/v2/search?categories_tags_en=${animalType}-food&fields=product_name,brands,ingredients_text,image_url&page_size=100');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List?;
        if (products != null && products.isNotEmpty) {
          final randomProduct = products[Random().nextInt(products.length)];
          return {
            "name": randomProduct['product_name'] ?? "Unknown meal",
            "brand": randomProduct['brands'] ?? "Unknown brand",
            "ingredients": randomProduct['ingredients_text'] ?? "No ingredients listed",
            "image": randomProduct['image_url'],
          };
        }
      }
    } catch (e) {
      print("Error fetching pet meal: $e");
    }
    return null;
  }
}
