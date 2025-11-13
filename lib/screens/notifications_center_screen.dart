import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/animal_provider.dart';
import '../models/notification_model.dart';
import '../models/animal.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  String _filterType = 'all';
  Map<int, Animal> _animals = {};

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    await provider.loadAnimals();
    final Map<int, Animal> animalsMap = {};
    for (final animal in provider.animals) {
      if (animal.id != null) {
        animalsMap[animal.id!] = animal;
      }
    }
    setState(() => _animals = animalsMap);
  }

  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> notifications) {
    if (_filterType == 'all') return notifications;
    return notifications.where((n) => n.type.name == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimalProvider>(
      builder: (context, provider, child) {
        final notifications = _getFilteredNotifications(provider.notifications);

        return Column(
          children: [
            // Filtres
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tous',
                      isSelected: _filterType == 'all',
                      onTap: () => setState(() => _filterType = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Vaccination',
                      isSelected: _filterType == 'vaccination',
                      onTap: () => setState(() => _filterType = 'vaccination'),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Rendez-vous',
                      isSelected: _filterType == 'appointment',
                      onTap: () => setState(() => _filterType = 'appointment'),
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Alimentation',
                      isSelected: _filterType == 'feeding',
                      onTap: () => setState(() => _filterType = 'feeding'),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Stock',
                      isSelected: _filterType == 'stockAlert',
                      onTap: () => setState(() => _filterType = 'stockAlert'),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            // Liste des notifications
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune notification',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.loadNotifications(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final animal = notification.animalId != null
                              ? _animals[notification.animalId]
                              : null;
                          return _NotificationCard(
                            notification: notification,
                            animal: animal,
                            onTap: () => _handleNotificationTap(notification),
                            onMarkAsRead: () => provider.markNotificationAsRead(notification.id!),
                            onMarkAsCompleted: () => provider.markNotificationAsCompleted(notification.id!),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Navigation vers l'écran approprié selon le type
    // À implémenter selon les besoins
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color?.withOpacity(0.3),
      checkmarkColor: color,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final Animal? animal;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsCompleted;

  const _NotificationCard({
    required this.notification,
    this.animal,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onMarkAsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.status == NotificationStatus.pending ||
        notification.status == NotificationStatus.sent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onMarkAsCompleted(),
              backgroundColor: Colors.green,
              icon: Icons.check,
              label: 'Effectué',
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onMarkAsRead(),
              backgroundColor: Colors.blue,
              icon: Icons.mark_email_read,
              label: 'Lu',
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: notification.color,
                  width: 4,
                ),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notification.color.withOpacity(0.2),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification.message),
                  if (animal != null)
                    Text(
                      'Animal: ${animal!.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(notification.scheduledDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: _getStatusIcon(notification.status),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _getStatusIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange);
      case NotificationStatus.sent:
        return const Icon(Icons.send, color: Colors.blue);
      case NotificationStatus.read:
        return const Icon(Icons.mark_email_read, color: Colors.grey);
      case NotificationStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Demain';
    } else if (difference.inDays == -1) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


