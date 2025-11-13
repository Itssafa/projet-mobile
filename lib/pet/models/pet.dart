class Pet {
  final String id;
  final String name;
  final String type;
  final String? breed; // facultatif
  final int ageYears;
  final int ageMonths;
  final bool isVaccinated;
  final String? imageUrl; // chemin image locale ou réseau

  Pet({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    required this.ageYears,
    required this.ageMonths,
    required this.isVaccinated,
    this.imageUrl,
  });

  // 🔁 Convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'ageYears': ageYears,
      'ageMonths': ageMonths,
      'isVaccinated': isVaccinated,
      'imageUrl': imageUrl,
    };
  }

  // 🔁 Créer un Pet à partir d’un JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'],
      ageYears: json['ageYears'] is int
          ? json['ageYears']
          : int.tryParse(json['ageYears']?.toString() ?? '0') ?? 0,
      ageMonths: json['ageMonths'] is int
          ? json['ageMonths']
          : int.tryParse(json['ageMonths']?.toString() ?? '0') ?? 0,
      isVaccinated: json['isVaccinated'] == true ||
          json['isVaccinated']?.toString() == 'true',
      imageUrl: json['imageUrl'],
    );
  }
}
