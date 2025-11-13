import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import '../providers/animal_provider.dart';
import '../models/animal.dart';
import '../models/feeding.dart';
import '../models/vaccination.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import 'health_record_screen.dart';
import 'add_animal_screen.dart';

class AnimalsListScreen extends StatelessWidget {
  const AnimalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundColor,
            Colors.white,
          ],
        ),
      ),
      child: Consumer<AnimalProvider>(
        builder: (context, provider, child) {
        if (provider.animals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Aucun animal enregistré',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Commencez par ajouter votre premier animal',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAnimalScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 24),
                    label: const Text(
                      'Ajouter un animal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadAnimals(),
          color: AppTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.animals.length,
            itemBuilder: (context, index) {
              final animal = provider.animals[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: _AnimalCard(animal: animal),
                    ),
                  );
                },
              );
            },
          ),
        );
        },
      ),
    );
  }
}

class _AnimalCard extends StatefulWidget {
  final Animal animal;

  const _AnimalCard({required this.animal});

  @override
  State<_AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<_AnimalCard> {
  VaccinationStatus? _vaccinationStatus;
  AppointmentInfo? _nextAppointment;
  FeedingInfo? _feedingInfo;

  @override
  void initState() {
    super.initState();
    _loadAnimalInfo();
  }

  Future<void> _loadAnimalInfo() async {
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    final vaccinations = provider.getVaccinationsByAnimal(widget.animal.id!);
    final appointments = provider.getAppointmentsByAnimal(widget.animal.id!);
    final feeding = provider.getFeedingByAnimal(widget.animal.id!);

    setState(() {
      if (vaccinations.isNotEmpty) {
        final nextVaccine = vaccinations.firstWhere(
          (v) => !v.isCompleted && v.nextVaccineDate != null,
          orElse: () => vaccinations.first,
        );
        if (nextVaccine.nextVaccineDate != null) {
          _vaccinationStatus = nextVaccine.isOverdue
              ? VaccinationStatus.overdue
              : VaccinationStatus.upToDate;
        }
      }

      if (appointments.isNotEmpty) {
        final upcoming = appointments.firstWhere(
          (a) => a.dateTime.isAfter(DateTime.now()),
          orElse: () => appointments.first,
        );
        _nextAppointment = AppointmentInfo(
          date: upcoming.dateTime,
          type: upcoming.appointmentType,
        );
      }

      if (feeding != null) {
        _feedingInfo = FeedingInfo(
          stockPercentage: (feeding.currentStock / (feeding.dailyQuantity * 30)) * 100,
          status: feeding.stockStatus,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50.withOpacity(0.3),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _quickAction(context, 'feed'),
                backgroundColor: Colors.orange,
                icon: Icons.restaurant,
                label: 'Nourrir',
              ),
              SlidableAction(
                onPressed: (_) => _quickAction(context, 'vaccine'),
                backgroundColor: Colors.blue,
                icon: Icons.vaccines,
                label: 'Vaccin',
              ),
              SlidableAction(
                onPressed: (_) => _quickAction(context, 'appointment'),
                backgroundColor: Colors.green,
                icon: Icons.calendar_today,
                label: 'Rendez-vous',
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthRecordScreen(animal: widget.animal),
                ),
              );
            },
            onLongPress: () => _showQuickHistory(context),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Photo de l'animal avec design moderne
                Hero(
                  tag: 'animal_${widget.animal.id}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: (widget.animal.imagePath != null && !kIsWeb)
                            ? DecorationImage(
                                image: FileImage(File(widget.animal.imagePath!)),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  // En cas d'erreur, l'icône sera affichée
                                },
                              )
                            : (widget.animal.imageBase64 != null && kIsWeb)
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(widget.animal.imageBase64!),
                                    ),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // En cas d'erreur, l'icône sera affichée
                                    },
                                  )
                                : null,
                      ),
                      child: (widget.animal.imagePath == null && widget.animal.imageBase64 == null) || 
                             (kIsWeb && widget.animal.imageBase64 == null) ||
                             (!kIsWeb && widget.animal.imagePath == null)
                          ? const Icon(
                              Icons.pets,
                              size: 35,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.animal.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.category,
                            label: widget.animal.species,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.cake,
                            label: '${widget.animal.age} mois',
                            color: AppTheme.warningColor,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.monitor_weight,
                            label: '${widget.animal.weight} kg',
                            color: AppTheme.successColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Icônes de statut
                      Row(
                        children: [
                          // Statut vaccination avec badge
                          if (_vaccinationStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _vaccinationStatus == VaccinationStatus.overdue
                                    ? AppTheme.errorColor.withOpacity(0.1)
                                    : AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _vaccinationStatus == VaccinationStatus.overdue
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.vaccines,
                                    size: 14,
                                    color: _vaccinationStatus == VaccinationStatus.overdue
                                        ? AppTheme.errorColor
                                        : AppTheme.successColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _vaccinationStatus == VaccinationStatus.overdue
                                        ? 'En retard'
                                        : 'À jour',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _vaccinationStatus == VaccinationStatus.overdue
                                          ? AppTheme.errorColor
                                          : AppTheme.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Statut alimentation avec badge
                          if (_feedingInfo != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _feedingInfo!.status == StockStatus.critical
                                    ? AppTheme.errorColor.withOpacity(0.1)
                                    : _feedingInfo!.status == StockStatus.warning
                                        ? AppTheme.warningColor.withOpacity(0.1)
                                        : AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _feedingInfo!.status == StockStatus.critical
                                      ? AppTheme.errorColor
                                      : _feedingInfo!.status == StockStatus.warning
                                          ? AppTheme.warningColor
                                          : AppTheme.successColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 14,
                                    color: _feedingInfo!.status == StockStatus.critical
                                        ? AppTheme.errorColor
                                        : _feedingInfo!.status == StockStatus.warning
                                            ? AppTheme.warningColor
                                            : AppTheme.successColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_feedingInfo!.stockPercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _feedingInfo!.status == StockStatus.critical
                                          ? AppTheme.errorColor
                                          : _feedingInfo!.status == StockStatus.warning
                                              ? AppTheme.warningColor
                                              : AppTheme.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Prochain rendez-vous avec badge
                          if (_nextAppointment != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.infoColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.infoColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: AppTheme.infoColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_nextAppointment!.date.day}/${_nextAppointment!.date.month}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.infoColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  void _quickAction(BuildContext context, String action) {
    // Navigation vers les écrans appropriés
    // À implémenter selon les besoins
  }

  void _showQuickHistory(BuildContext context) {
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    final history = provider.getQuickHistory(widget.animal.id!);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Historique rapide - ${widget.animal.name}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (history['lastVaccination'] != null)
                _HistoryItem(
                  icon: Icons.vaccines,
                  iconColor: Colors.blue,
                  title: 'Dernier vaccin',
                  value: '${(history['lastVaccination'] as Vaccination).vaccineType}\n'
                      'Le ${_formatDate((history['lastVaccination'] as Vaccination).lastVaccineDate)}',
                ),
              if (history['lastAppointment'] != null)
                _HistoryItem(
                  icon: Icons.medical_services,
                  iconColor: Colors.green,
                  title: 'Dernier rendez-vous',
                  value: '${(history['lastAppointment'] as Appointment).appointmentType}\n'
                      'Le ${_formatDate((history['lastAppointment'] as Appointment).dateTime)}',
                ),
              if (history['nextAppointment'] != null)
                _HistoryItem(
                  icon: Icons.calendar_today,
                  iconColor: Colors.orange,
                  title: 'Prochain rendez-vous',
                  value: '${(history['nextAppointment'] as Appointment).appointmentType}\n'
                      'Le ${_formatDate((history['nextAppointment'] as Appointment).dateTime)}',
                ),
              if (history['feeding'] != null)
                _HistoryItem(
                  icon: Icons.restaurant,
                  iconColor: Colors.orange,
                  title: 'Dernier repas',
                  value: '${(history['feeding'] as Feeding).foodType}\n'
                      'Stock: ${(history['feeding'] as Feeding).currentStock.toStringAsFixed(0)} g',
                ),
              if (history['stockDays'] != null)
                _HistoryItem(
                  icon: Icons.inventory,
                  iconColor: (history['stockDays'] as int) <= 3 ? Colors.red : Colors.green,
                  title: 'Stock restant',
                  value: '${history['stockDays']} jours',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum VaccinationStatus { upToDate, overdue }

class AppointmentInfo {
  final DateTime date;
  final String type;

  AppointmentInfo({required this.date, required this.type});
}

class FeedingInfo {
  final double stockPercentage;
  final StockStatus status;

  FeedingInfo({required this.stockPercentage, required this.status});
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _HistoryItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

