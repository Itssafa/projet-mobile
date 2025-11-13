import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';

class PetFormPage extends StatefulWidget {
  final Pet? pet;
  final Function(Pet) onSave;

  const PetFormPage({super.key, this.pet, required this.onSave});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageYearsController = TextEditingController();
  final _ageMonthsController = TextEditingController();
  bool _isVaccinated = false;
  String? _imagePath;
  String _selectedType = 'Chat';

  final List<String> _animalTypes = [
    'Chat',
    'Chien',
    'Lapin',
    'Oiseau',
    'Hamster',
    'Poisson',
    'Tortue'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      final pet = widget.pet!;
      _nameController.text = pet.name;
      _breedController.text = pet.breed ?? '';
      _ageYearsController.text = pet.ageYears.toString();
      _ageMonthsController.text = pet.ageMonths.toString();
      _isVaccinated = pet.isVaccinated;
      _imagePath = pet.imageUrl;
      _selectedType = pet.type;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        ageYears: int.tryParse(_ageYearsController.text) ?? 0, // ✅ conversion
        ageMonths: int.tryParse(_ageMonthsController.text) ?? 0, // ✅ conversion
        isVaccinated: _isVaccinated,
        imageUrl: _imagePath,
      );

      widget.onSave(pet);
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.pet == null ? 'Ajouter un animal' : 'Modifier l’animal'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 📸 Sélection image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imagePath != null
                      ? FileImage(File(_imagePath!))
                      : const AssetImage('assets/images/default_pet.png')
                  as ImageProvider,
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.teal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🐾 Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Entrez un nom' : null,
              ),
              const SizedBox(height: 16),

              // 🐶 Type d’animal
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type d’animal',
                  border: OutlineInputBorder(),
                ),
                items: _animalTypes
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 🧬 Race (facultatif)
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Race (facultatif)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 📅 Âge (années et mois)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageYearsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Âge (années)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _ageMonthsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Âge (mois)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 💉 Vaccination
              SwitchListTile(
                title: const Text('Vacciné'),
                value: _isVaccinated,
                onChanged: (value) => setState(() => _isVaccinated = value),
              ),
              const SizedBox(height: 20),

              // 💾 Bouton sauvegarder
              ElevatedButton.icon(
                onPressed: _savePet,
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
