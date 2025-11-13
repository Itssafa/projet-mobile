enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  urgent,
}

class Appointment {
  final int? id;
  final int animalId;
  final DateTime dateTime;
  final String appointmentType;
  final AppointmentStatus status;
  final String? veterinarianName;
  final String? notes;
  final bool reminderSent;

  Appointment({
    this.id,
    required this.animalId,
    required this.dateTime,
    required this.appointmentType,
    this.status = AppointmentStatus.scheduled,
    this.veterinarianName,
    this.notes,
    this.reminderSent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'date_time': dateTime.toIso8601String(),
      'appointment_type': appointmentType,
      'status': status.name,
      'veterinarian_name': veterinarianName,
      'notes': notes,
      'reminder_sent': reminderSent ? 1 : 0,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      animalId: map['animal_id'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
      appointmentType: map['appointment_type'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      veterinarianName: map['veterinarian_name'] as String?,
      notes: map['notes'] as String?,
      reminderSent: (map['reminder_sent'] as int) == 1,
    );
  }

  bool get isUrgent {
    if (status == AppointmentStatus.completed) return false;
    final daysUntil = dateTime.difference(DateTime.now()).inDays;
    return daysUntil <= 1;
  }

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}


