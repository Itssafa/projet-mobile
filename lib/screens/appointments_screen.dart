import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../providers/animal_provider.dart';
import '../models/animal.dart';
import 'add_appointment_screen.dart';
import 'edit_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  List<Animal> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    await provider.loadAnimals();
    final appointments = provider.getAllAppointments();
    final animals = provider.animals;
    
    setState(() {
      _appointments = appointments;
      _animals = animals;
      _isLoading = false;
    });
  }

  String _getAnimalName(int animalId) {
    final animal = _animals.firstWhere(
      (a) => a.id == animalId,
      orElse: () => Animal(
        name: 'Inconnu',
        species: '',
        age: 0,
        weight: 0,
        dateAdded: DateTime.now(),
      ),
    );
    return animal.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun rendez-vous',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        final animalName = _getAnimalName(appointment.animalId);
                        return _AppointmentCard(
                          appointment: appointment,
                          animalName: animalName,
                          onConfirm: () => _confirmAppointment(appointment),
                          onReschedule: () => _rescheduleAppointment(appointment),
                          onDelete: () => _deleteAppointment(appointment),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmAppointment(Appointment appointment) async {
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    if (appointment.status == AppointmentStatus.completed) {
      // Si déjà complété, ne rien faire
      return;
    }
    
    // Marquer comme complété
    await provider.completeAppointment(appointment.id!);
    _loadData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rendez-vous de $_getAnimalName(appointment.animalId) marqué comme complété'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _rescheduleAppointment(Appointment appointment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAppointmentScreen(appointment: appointment),
      ),
    );
    _loadData();
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le rendez-vous "${appointment.appointmentType}" pour $_getAnimalName(appointment.animalId) ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<AnimalProvider>(context, listen: false);
      await provider.deleteAppointment(appointment.id!);
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String animalName;
  final VoidCallback onConfirm;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const _AppointmentCard({
    required this.appointment,
    required this.animalName,
    required this.onConfirm,
    required this.onReschedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);
    final isUrgent = appointment.isUrgent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onConfirm(),
              backgroundColor: appointment.status == AppointmentStatus.completed 
                  ? Colors.grey 
                  : Colors.green,
              icon: appointment.status == AppointmentStatus.completed 
                  ? Icons.check_circle 
                  : Icons.check,
              label: appointment.status == AppointmentStatus.completed 
                  ? 'Complété' 
                  : 'Marquer complété',
            ),
            SlidableAction(
              onPressed: (_) => onReschedule(),
              backgroundColor: Colors.orange,
              icon: Icons.edit,
              label: 'Reporter',
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Supprimer',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isUrgent ? Colors.red : statusColor,
                width: 4,
              ),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(
                Icons.medical_services,
                color: statusColor,
              ),
            ),
            title: Text(
              appointment.appointmentType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animal: $animalName'),
                Text(
                  '${_formatDate(appointment.dateTime)} à ${_formatTime(appointment.dateTime)}',
                ),
                if (appointment.veterinarianName != null)
                  Text('Vétérinaire: ${appointment.veterinarianName}'),
                if (isUrgent)
                  const Chip(
                    label: Text('URGENT'),
                    backgroundColor: Colors.red,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                  ),
              ],
            ),
            trailing: appointment.status == AppointmentStatus.completed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Icon(
                    isUrgent ? Icons.warning : Icons.calendar_today,
                    color: isUrgent ? Colors.red : statusColor,
                  ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.urgent:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}


