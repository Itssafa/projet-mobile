import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/animal_provider.dart';
import '../models/vaccination.dart';

class AddVaccinationScreen extends StatefulWidget {
  final int animalId;

  const AddVaccinationScreen({super.key, required this.animalId});

  @override
  State<AddVaccinationScreen> createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineTypeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _lastVaccineDate;
  DateTime? _nextVaccineDate;

  @override
  void dispose() {
    _vaccineTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNext) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isNext) {
          _nextVaccineDate = picked;
        } else {
          _lastVaccineDate = picked;
        }
      });
    }
  }

  Future<void> _saveVaccination() async {
    if (_formKey.currentState!.validate()) {
      if (_lastVaccineDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner la date du dernier vaccin')),
        );
        return;
      }
      // Vérifier que la date du dernier vaccin n'est pas dans le futur
      if (_lastVaccineDate!.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La date du dernier vaccin ne peut pas être dans le futur')),
        );
        return;
      }
      // Vérifier que le prochain vaccin est après le dernier
      if (_nextVaccineDate != null && _nextVaccineDate!.isBefore(_lastVaccineDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le prochain vaccin doit être après le dernier vaccin')),
        );
        return;
      }
      final vaccination = Vaccination(
        animalId: widget.animalId,
        lastVaccineDate: _lastVaccineDate!,
        nextVaccineDate: _nextVaccineDate,
        vaccineType: _vaccineTypeController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await context.read<AnimalProvider>().addVaccination(vaccination);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vaccination enregistrée avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une vaccination'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _vaccineTypeController,
              decoration: const InputDecoration(
                labelText: 'Type de vaccin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vaccines),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le type de vaccin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Dernier vaccin'),
              subtitle: Text(
                _lastVaccineDate != null
                    ? DateFormat('dd/MM/yyyy').format(_lastVaccineDate!)
                    : 'Sélectionner une date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Prochain rappel (optionnel)'),
              subtitle: Text(
                _nextVaccineDate != null
                    ? DateFormat('dd/MM/yyyy').format(_nextVaccineDate!)
                    : 'Sélectionner une date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveVaccination,
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


