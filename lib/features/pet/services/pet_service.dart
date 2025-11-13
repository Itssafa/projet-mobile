import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class PetService {
  static const String _key = 'pets';
  List<Pet> _pets = [];

  PetService() {
    _loadPets();
  }

  Future<void> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    _pets = data.map((json) => Pet.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _pets.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  List<Pet> getAllPets() => _pets;

  Future<void> addPet(Pet pet) async {
    _pets.add(pet);
    await _savePets();
  }

  Future<void> updatePet(Pet updatedPet) async {
    final index = _pets.indexWhere((p) => p.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      await _savePets();
    }
  }

  Future<void> deletePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
    await _savePets();
  }
}
