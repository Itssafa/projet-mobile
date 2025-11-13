import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/animal_provider.dart';
import '../models/appointment.dart';
import '../models/animal.dart';
import '../theme/app_theme.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentTypeController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _appointmentTypeController.text = widget.appointment.appointmentType;
    _veterinarianController.text = widget.appointment.veterinarianName ?? '';
    _notesController.text = widget.appointment.notes ?? '';
    _selectedDateTime = widget.appointment.dateTime;
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
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
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
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date et heure')),
        );
        return;
      }
      // Vérifier que la date/heure est dans le futur (sauf si c'est un rendez-vous passé)
      if (_selectedDateTime!.isBefore(DateTime.now()) && 
          widget.appointment.status != AppointmentStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La date et l\'heure doivent être dans le futur')),
        );
        return;
      }
      
      final updatedAppointment = Appointment(
        id: widget.appointment.id,
        animalId: widget.appointment.animalId,
        dateTime: _selectedDateTime!,
        appointmentType: _appointmentTypeController.text.trim(),
        veterinarianName: _veterinarianController.text.trim().isEmpty
            ? null
            : _veterinarianController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        status: widget.appointment.status,
      );

      await context.read<AnimalProvider>().updateAppointment(updatedAppointment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous modifié avec succès'),
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
        title: const Text('Modifier le rendez-vous'),
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
              controller: _appointmentTypeController,
              decoration: const InputDecoration(
                labelText: 'Type de rendez-vous *',
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
            if (_selectedDateTime != null && 
                _selectedDateTime!.isBefore(DateTime.now()) &&
                widget.appointment.status != AppointmentStatus.completed)
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

