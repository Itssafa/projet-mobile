import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../providers/animal_provider.dart';
import '../models/animal.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Sur web, on doit charger les bytes immédiatement
          final bytes = await image.readAsBytes();
          if (mounted) {
            setState(() {
              _selectedImage = image;
              _selectedImageBytes = bytes;
            });
          }
        } else {
          // Sur mobile, on utilise directement le chemin
          setState(() {
            _selectedImage = image;
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (kIsWeb) {
      // Sur web, seule la galerie est disponible
      _pickImage(ImageSource.gallery);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      String? imageBase64;
      
      // Sur web, convertir l'image en base64
      if (kIsWeb && _selectedImageBytes != null) {
        imageBase64 = base64Encode(_selectedImageBytes!);
      }
      
      final animal = Animal(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        dateAdded: DateTime.now(),
        imagePath: kIsWeb ? null : _selectedImage?.path,
        imageBase64: imageBase64,
      );

      await context.read<AnimalProvider>().addAnimal(animal);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal ajouté avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un animal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sélection d'image
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb
                              ? _selectedImageBytes != null
                                  ? Image.memory(
                                      _selectedImageBytes!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 48,
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 48,
                                    );
                                  },
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 48, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                if (value.trim().length > 50) {
                  return 'Le nom ne peut pas dépasser 50 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: 'Espèce',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'espèce';
                }
                if (value.trim().length < 2) {
                  return 'L\'espèce doit contenir au moins 2 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Âge (en mois)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'âge';
                }
                final age = int.tryParse(value);
                if (age == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                if (age < 0) {
                  return 'L\'âge ne peut pas être négatif';
                }
                if (age > 300) {
                  return 'L\'âge ne peut pas dépasser 300 mois (25 ans)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le poids';
                }
                final weight = double.tryParse(value);
                if (weight == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                if (weight <= 0) {
                  return 'Le poids doit être supérieur à 0';
                }
                if (weight > 200) {
                  return 'Le poids ne peut pas dépasser 200 kg';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAnimal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}


