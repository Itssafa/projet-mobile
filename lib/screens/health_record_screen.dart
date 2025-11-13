import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import '../models/animal.dart';
import '../models/vaccination.dart';
import '../providers/animal_provider.dart';
import 'add_vaccination_screen.dart';

class HealthRecordScreen extends StatefulWidget {
  final Animal animal;

  const HealthRecordScreen({super.key, required this.animal});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  List<Vaccination> _vaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    final vaccinations = provider.getVaccinationsByAnimal(widget.animal.id!);
    setState(() {
      _vaccinations = vaccinations;
      _isLoading = false;
    });
  }

  ImageProvider? _getAnimalImageProvider() {
    if (kIsWeb) {
      if (widget.animal.imageBase64 != null) {
        return MemoryImage(base64Decode(widget.animal.imageBase64!));
      }
    } else {
      if (widget.animal.imagePath != null) {
        return FileImage(File(widget.animal.imagePath!));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final nextVaccine = _vaccinations.firstWhere(
      (v) => !v.isCompleted && v.nextVaccineDate != null,
      orElse: () => _vaccinations.isNotEmpty ? _vaccinations.first : Vaccination(
        animalId: widget.animal.id!,
        lastVaccineDate: DateTime.now(),
        vaccineType: '',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Carnet de santé - ${widget.animal.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec photo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _getAnimalImageProvider(),
                          child: (widget.animal.imagePath == null && widget.animal.imageBase64 == null) ||
                                 (kIsWeb && widget.animal.imageBase64 == null) ||
                                 (!kIsWeb && widget.animal.imagePath == null)
                              ? const Icon(Icons.pets, size: 50, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.animal.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.animal.species} • ${widget.animal.age} mois • ${widget.animal.weight} kg',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  
                  // Notification prochain vaccin
                  if (nextVaccine.nextVaccineDate != null && !nextVaccine.isCompleted)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: nextVaccine.isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: nextVaccine.isOverdue ? Colors.red : Colors.blue,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: nextVaccine.isOverdue ? Colors.red : Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Prochain vaccin de ${widget.animal.name}: ${_formatDate(nextVaccine.nextVaccineDate!)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: nextVaccine.isOverdue ? Colors.red : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Informations générales
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations générales',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(icon: Icons.pets, label: 'Espèce', value: widget.animal.species),
                        _InfoRow(icon: Icons.calendar_today, label: 'Âge', value: '${widget.animal.age} mois'),
                        _InfoRow(icon: Icons.monitor_weight, label: 'Poids', value: '${widget.animal.weight} kg'),
                      ],
                    ),
                  ),

                  // Historique des vaccins
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Historique des vaccins',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddVaccinationScreen(
                                      animalId: widget.animal.id!,
                                    ),
                                  ),
                                );
                                _loadVaccinations();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_vaccinations.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Aucun vaccin enregistré'),
                            ),
                          )
                        else
                          ..._vaccinations.map((vaccination) => _VaccinationCard(
                                vaccination: vaccination,
                                animalName: widget.animal.name,
                                onTap: () => _showVaccinationDetails(vaccination),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVaccinationScreen(
                animalId: widget.animal.id!,
              ),
            ),
          );
          _loadVaccinations();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showVaccinationDetails(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              vaccination.isCompleted ? Icons.check_circle : Icons.vaccines,
              color: vaccination.isCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 8),
            const Text('Détails du vaccin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Type', vaccination.vaccineType),
            _DetailRow('Dernier vaccin', _formatDate(vaccination.lastVaccineDate)),
            if (vaccination.nextVaccineDate != null)
              _DetailRow(
                'Prochain vaccin',
                _formatDate(vaccination.nextVaccineDate!),
                color: vaccination.isOverdue ? Colors.red : Colors.blue,
              ),
            if (vaccination.notes != null)
              _DetailRow('Notes', vaccination.notes!),
            if (vaccination.isCompleted)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Vaccin administré',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
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
                    'Êtes-vous sûr de vouloir supprimer le vaccin "${vaccination.vaccineType}" pour ${widget.animal.name} ?\n\nCette action est irréversible.',
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
                await provider.deleteVaccination(vaccination.id!);
                _loadVaccinations();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vaccination supprimée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
          if (!vaccination.isCompleted)
            ElevatedButton.icon(
              onPressed: () {
                final provider = Provider.of<AnimalProvider>(context, listen: false);
                provider.completeVaccination(vaccination.id!);
                Navigator.pop(context);
                _loadVaccinations();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vaccin de ${widget.animal.name} marqué comme administré'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Marquer comme administré'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
        ],
      ),
    );
  }

  Widget _DetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class _VaccinationCard extends StatelessWidget {
  final Vaccination vaccination;
  final String animalName;
  final VoidCallback onTap;

  const _VaccinationCard({
    required this.vaccination,
    required this.animalName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          vaccination.isCompleted ? Icons.check_circle : Icons.warning,
          color: vaccination.isCompleted ? Colors.green : Colors.orange,
        ),
        title: Text(vaccination.vaccineType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dernier: ${_formatDate(vaccination.lastVaccineDate)}'),
            if (vaccination.nextVaccineDate != null && !vaccination.isCompleted)
              Text(
                'Prochain: ${_formatDate(vaccination.nextVaccineDate!)}',
                style: TextStyle(
                  color: vaccination.isOverdue ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


