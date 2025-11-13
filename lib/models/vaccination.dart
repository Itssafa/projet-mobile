class Vaccination {
  final int? id;
  final int animalId;
  final DateTime lastVaccineDate;
  final DateTime? nextVaccineDate;
  final String vaccineType;
  final bool isCompleted;
  final String? notes;

  Vaccination({
    this.id,
    required this.animalId,
    required this.lastVaccineDate,
    this.nextVaccineDate,
    required this.vaccineType,
    this.isCompleted = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'last_vaccine_date': lastVaccineDate.toIso8601String(),
      'next_vaccine_date': nextVaccineDate?.toIso8601String(),
      'vaccine_type': vaccineType,
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
    };
  }

  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      id: map['id'] as int?,
      animalId: map['animal_id'] as int,
      lastVaccineDate: DateTime.parse(map['last_vaccine_date'] as String),
      nextVaccineDate: map['next_vaccine_date'] != null
          ? DateTime.parse(map['next_vaccine_date'] as String)
          : null,
      vaccineType: map['vaccine_type'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      notes: map['notes'] as String?,
    );
  }

  bool get isOverdue {
    if (nextVaccineDate == null || isCompleted) return false;
    return DateTime.now().isAfter(nextVaccineDate!);
  }

  bool get isUpcoming {
    if (nextVaccineDate == null || isCompleted) return false;
    final daysUntil = nextVaccineDate!.difference(DateTime.now()).inDays;
    return daysUntil >= 0 && daysUntil <= 7;
  }
}


