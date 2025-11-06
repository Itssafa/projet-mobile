import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import 'pet_form_page.dart';
import '../components/pet_card.dart';

class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  final PetService _petService = PetService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  // ✅ Ajouter un nouvel animal
  void _addPet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetFormPage(
          onSave: (pet) async {
            await _petService.addPet(pet);
            setState(() {});
          },
        ),
      ),
    );
  }

  // ✅ Modifier un animal existant
  void _editPet(Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetFormPage(
          pet: pet,
          onSave: (updatedPet) async {
            await _petService.updatePet(updatedPet);
            setState(() {});
          },
        ),
      ),
    );
  }

  // ✅ Supprimer un animal
  void _deletePet(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l’animal ?'),
        content: Text('Voulez-vous vraiment supprimer ${pet.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _petService.deletePet(pet.id);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pets = _petService.getAllPets();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Animaux'),
        backgroundColor: Colors.teal,
      ),
      body: pets.isEmpty
          ? const Center(
        child: Text(
          'Aucun animal ajouté pour le moment 🐾',
          style: TextStyle(fontSize: 16),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return Stack(
            children: [
              PetCard(
                pet: pet,
                onTap: () => _editPet(pet),
              ),
              // 🗑️ Bouton de suppression
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon:
                  const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deletePet(pet),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPet,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
