import 'package:flutter/material.dart';

enum NotificationType {
  vaccination,
  appointment,
  feeding,
  stockAlert,
}

enum NotificationStatus {
  pending,
  sent,
  read,
  completed,
}

class NotificationModel {
  final int? id;
  final NotificationType type;
  final int? animalId;
  final int? relatedId; // ID du vaccin, rendez-vous, etc.
  final String title;
  final String message;
  final DateTime scheduledDate;
  final NotificationStatus status;
  final DateTime? sentDate;
  final DateTime? readDate;

  NotificationModel({
    this.id,
    required this.type,
    this.animalId,
    this.relatedId,
    required this.title,
    required this.message,
    required this.scheduledDate,
    this.status = NotificationStatus.pending,
    this.sentDate,
    this.readDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'animal_id': animalId,
      'related_id': relatedId,
      'title': title,
      'message': message,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status.name,
      'sent_date': sentDate?.toIso8601String(),
      'read_date': readDate?.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.feeding,
      ),
      animalId: map['animal_id'] as int?,
      relatedId: map['related_id'] as int?,
      title: map['title'] as String,
      message: map['message'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => NotificationStatus.pending,
      ),
      sentDate: map['sent_date'] != null
          ? DateTime.parse(map['sent_date'] as String)
          : null,
      readDate: map['read_date'] != null
          ? DateTime.parse(map['read_date'] as String)
          : null,
    );
  }

  Color get color {
    switch (type) {
      case NotificationType.vaccination:
        return Colors.blue;
      case NotificationType.appointment:
        return Colors.green;
      case NotificationType.feeding:
        return Colors.orange;
      case NotificationType.stockAlert:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.vaccination:
        return Icons.vaccines;
      case NotificationType.appointment:
        return Icons.medical_services;
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.stockAlert:
        return Icons.warning;
    }
  }
}

