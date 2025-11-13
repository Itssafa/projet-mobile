import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/animal_provider.dart';
import '../models/feeding.dart';
import '../models/animal.dart';
import '../theme/app_theme.dart';

class EditFeedingScreen extends StatefulWidget {
  final Feeding feeding;
  final Animal animal;

  const EditFeedingScreen({
    super.key,
    required this.feeding,
    required this.animal,
  });

  @override
  State<EditFeedingScreen> createState() => _EditFeedingScreenState();
}

class _EditFeedingScreenState extends State<EditFeedingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _dailyQuantityController = TextEditingController();
  final _stockController = TextEditingController();
  final _mealTimeController = TextEditingController();
  
  List<String> _mealTimes = [];

  @override
  void initState() {
    super.initState();
    _foodTypeController.text = widget.feeding.foodType;
    _dailyQuantityController.text = widget.feeding.dailyQuantity.toString();
    _stockController.text = widget.feeding.currentStock.toString();
    _mealTimes = List.from(widget.feeding.mealTimes);
  }

  @override
  void dispose() {
    _foodTypeController.dispose();
    _dailyQuantityController.dispose();
    _stockController.dispose();
    _mealTimeController.dispose();
    super.dispose();
  }

  void _addMealTime() {
    final time = _mealTimeController.text.trim();
    if (time.isNotEmpty && _isValidTime(time)) {
      setState(() {
        _mealTimes.add(time);
        _mealTimeController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format d\'heure invalide (HH:mm)')),
      );
    }
  }

  bool _isValidTime(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  void _removeMealTime(String time) {
    setState(() {
      _mealTimes.remove(time);
    });
  }

  Future<void> _saveFeeding() async {
    if (_formKey.currentState!.validate()) {
      if (_mealTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez ajouter au moins une heure de repas')),
        );
        return;
      }
      
      final updatedFeeding = Feeding(
        id: widget.feeding.id,
        animalId: widget.feeding.animalId,
        foodType: _foodTypeController.text.trim(),
        dailyQuantity: double.parse(_dailyQuantityController.text),
        mealTimes: _mealTimes,
        currentStock: double.parse(_stockController.text),
        lastStockUpdate: widget.feeding.lastStockUpdate,
      );

      await context.read<AnimalProvider>().updateFeeding(updatedFeeding);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan d\'alimentation modifié avec succès'),
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
        title: Text('Modifier alimentation - ${widget.animal.name}'),
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
            TextFormField(
              controller: _foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Type de nourriture *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
                hintText: 'Ex: Croquettes DigestDog',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le type de nourriture';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dailyQuantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité quotidienne (g) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la quantité';
                }
                final quantity = double.tryParse(value);
                if (quantity == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                if (quantity <= 0) {
                  return 'La quantité doit être supérieure à 0';
                }
                if (quantity > 10000) {
                  return 'La quantité ne peut pas dépasser 10000 g';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock actuel (g) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le stock';
                }
                final stock = double.tryParse(value);
                if (stock == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                if (stock < 0) {
                  return 'Le stock ne peut pas être négatif';
                }
                if (stock > 100000) {
                  return 'Le stock ne peut pas dépasser 100000 g';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Heures de repas *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mealTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Heure (HH:mm)',
                      border: OutlineInputBorder(),
                      hintText: '08:00',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMealTime,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_mealTimes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '⚠️ Au moins une heure de repas est requise',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_mealTimes.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _mealTimes.map((time) {
                  return Chip(
                    label: Text(time),
                    onDeleted: () => _removeMealTime(time),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveFeeding,
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

