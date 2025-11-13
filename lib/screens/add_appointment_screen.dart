import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/animal_provider.dart';
import '../models/appointment.dart';
import '../models/animal.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentTypeController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  
  Animal? _selectedAnimal;
  DateTime? _selectedDateTime;
  List<Animal> _animals = [];

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    await provider.loadAnimals();
    setState(() => _animals = provider.animals);
  }

  @override
  void dispose() {
    _appointmentTypeController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAnimal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un animal')),
        );
        return;
      }
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date et heure')),
        );
        return;
      }
      // Vérifier que la date/heure est dans le futur
      if (_selectedDateTime!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La date et l\'heure doivent être dans le futur')),
        );
        return;
      }
      final appointment = Appointment(
        animalId: _selectedAnimal!.id!,
        dateTime: _selectedDateTime!,
        appointmentType: _appointmentTypeController.text,
        veterinarianName: _veterinarianController.text.isEmpty
            ? null
            : _veterinarianController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await context.read<AnimalProvider>().addAppointment(appointment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous enregistré avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un rendez-vous'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Animal>(
              value: _selectedAnimal,
              decoration: const InputDecoration(
                labelText: 'Animal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              items: _animals.map((animal) {
                return DropdownMenuItem(
                  value: animal,
                  child: Text(animal.name),
                );
              }).toList(),
              onChanged: (animal) {
                setState(() => _selectedAnimal = animal);
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un animal';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _appointmentTypeController,
              decoration: const InputDecoration(
                labelText: 'Type de rendez-vous',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le type de rendez-vous';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedDateTime == null 
                      ? Colors.red.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                title: const Text('Date et heure *'),
                subtitle: Text(
                  _selectedDateTime != null
                      ? DateFormat('dd/MM/yyyy à HH:mm').format(_selectedDateTime!)
                      : 'Sélectionner une date et heure',
                  style: TextStyle(
                    color: _selectedDateTime == null 
                        ? Colors.red.withOpacity(0.7)
                        : null,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
              ),
            ),
            if (_selectedDateTime != null && _selectedDateTime!.isBefore(DateTime.now()))
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Text(
                  '⚠️ La date doit être dans le futur',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _veterinarianController,
              decoration: const InputDecoration(
                labelText: 'Vétérinaire (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
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
              onPressed: _saveAppointment,
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


