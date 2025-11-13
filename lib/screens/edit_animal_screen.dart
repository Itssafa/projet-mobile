import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../providers/animal_provider.dart';
import '../models/animal.dart';
import '../theme/app_theme.dart';

class EditAnimalScreen extends StatefulWidget {
  final Animal animal;

  const EditAnimalScreen({super.key, required this.animal});

  @override
  State<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.animal.name;
    _speciesController.text = widget.animal.species;
    _ageController.text = widget.animal.age.toString();
    _weightController.text = widget.animal.weight.toString();
    // Note: Sur web, on ne peut pas charger l'image existante depuis le chemin
    // car les chemins de fichiers ne sont pas disponibles sur web
  }

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
        setState(() {
          _selectedImage = image;
          if (kIsWeb) {
            // Sur web, on doit charger les bytes
            image.readAsBytes().then((bytes) {
              if (mounted) {
                setState(() {
                  _selectedImageBytes = bytes;
                });
              }
            });
          }
        });
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
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Supprimer l\'image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      final updatedAnimal = Animal(
        id: widget.animal.id,
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        imagePath: kIsWeb ? widget.animal.imagePath : _selectedImage?.path,
        imageBase64: kIsWeb && _selectedImageBytes != null
            ? base64Encode(_selectedImageBytes!)
            : (kIsWeb ? widget.animal.imageBase64 : null),
        dateAdded: widget.animal.dateAdded,
      );

      await context.read<AnimalProvider>().updateAnimal(updatedAnimal);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Animal modifié avec succès'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'animal'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo de l'animal
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  children: [
                    Container(
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
                              child: kIsWeb && _selectedImageBytes != null
                                  ? Image.memory(
                                      _selectedImageBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : !kIsWeb
                                      ? Image.file(
                                          File(_selectedImage!.path),
                                          fit: BoxFit.cover,
                                        )
                                      : const CircularProgressIndicator(),
                            )
                          : (widget.animal.imagePath != null && !kIsWeb) ||
                                (widget.animal.imageBase64 != null && kIsWeb)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: kIsWeb && widget.animal.imageBase64 != null
                                      ? Image.memory(
                                          base64Decode(widget.animal.imageBase64!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.pets,
                                                    size: 48, color: Colors.grey[600]),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Image introuvable',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      : Image.file(
                                          File(widget.animal.imagePath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.pets,
                                                    size: 48, color: Colors.grey[600]),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Image introuvable',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
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
                labelText: 'Espèce *',
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
                labelText: 'Âge (en mois) *',
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
                labelText: 'Poids (kg) *',
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
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}

