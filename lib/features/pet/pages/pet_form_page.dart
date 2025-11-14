import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
  Uint8List? _imageBytes; // Pour stocker les bytes de l'image (web + desktop)
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

      // Si vous stockez les images en base64 dans votre modèle Pet
      // if (pet.imageBytes != null) {
      //   _imageBytes = base64Decode(pet.imageBytes!);
      // }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();

        setState(() {
          _imageBytes = bytes;
          // Sur desktop, on garde aussi le chemin pour la compatibilité
          if (!kIsWeb) {
            _imagePath = pickedFile.path;
          }
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection d\'image: $e');
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour obtenir l'image à afficher
  ImageProvider? get _imageProvider {
    if (_imageBytes != null) {
      return MemoryImage(_imageBytes!);
    } else if (_imagePath != null && !kIsWeb) {
      return FileImage(File(_imagePath!));
    }
    return null;
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      // Préparer l'URL de l'image pour la sauvegarde
      String? imageUrlToSave;

      // Sur le web, on peut sauvegarder l'image en base64 ou l'URL
      if (kIsWeb && _imageBytes != null) {
        // Option 1: Sauvegarder en base64
        // imageUrlToSave = base64Encode(_imageBytes!);

        // Option 2: Garder une référence (adaptez selon votre backend)
        imageUrlToSave = 'web_image_${DateTime.now().millisecondsSinceEpoch}';
      } else if (_imagePath != null) {
        // Sur desktop, on garde le chemin
        imageUrlToSave = _imagePath;
      }

      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        ageYears: int.tryParse(_ageYearsController.text) ?? 0,
        ageMonths: int.tryParse(_ageMonthsController.text) ?? 0,
        isVaccinated: _isVaccinated,
        imageUrl: imageUrlToSave,
        // Si vous voulez stocker les bytes directement
        // imageBytes: _imageBytes != null ? base64Encode(_imageBytes!) : null,
      );

      widget.onSave(pet);
      Navigator.pop(context);
    }
  }

  Widget _buildImageWidget() {
    final imageProvider = _imageProvider;

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Icon(Icons.pets, size: 50, color: Colors.grey[600])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.teal,
              child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Ajouter un animal' : 'Modifier l\'animal'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 📸 Sélection image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _buildImageWidget(),
                ),
              ),
              const SizedBox(height: 20),

              // 🐾 Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Entrez un nom' : null,
              ),
              const SizedBox(height: 16),

              // 🐶 Type d'animal
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'animal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
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
                  prefixIcon: Icon(Icons.emoji_nature),
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
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final years = int.tryParse(value);
                          if (years == null || years < 0) {
                            return 'Âge invalide';
                          }
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final months = int.tryParse(value);
                          if (months == null || months < 0 || months > 11) {
                            return '0-11 mois';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 💉 Vaccination
              Card(
                child: SwitchListTile(
                  title: const Text('Vacciné'),
                  subtitle: const Text('L\'animal est à jour de ses vaccins'),
                  value: _isVaccinated,
                  onChanged: (value) => setState(() => _isVaccinated = value),
                  secondary: Icon(
                    _isVaccinated ? Icons.verified : Icons.warning,
                    color: _isVaccinated ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 💾 Bouton sauvegarder
              ElevatedButton.icon(
                onPressed: _savePet,
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              // Bouton annuler
              if (widget.pet != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}