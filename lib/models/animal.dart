class Animal {
  final int? id;
  final String name;
  final String species;
  final int age; // en mois
  final double weight; // en kg
  final String? imagePath; // Chemin vers l'image (mobile)
  final String? imageBase64; // Image en base64 (web)
  final DateTime dateAdded;

  Animal({
    this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.weight,
    this.imagePath,
    this.imageBase64,
    required this.dateAdded,
  });

  // Getter pour compatibilité avec photoPath
  String? get photoPath => imagePath;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'age': age,
      'weight': weight,
      'photo_path': imagePath,
      'image_base64': imageBase64,
      'date_added': dateAdded.toIso8601String(),
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] as int?,
      name: map['name'] as String,
      species: map['species'] as String,
      age: map['age'] as int,
      weight: map['weight'] as double,
      imagePath: map['photo_path'] as String?,
      imageBase64: map['image_base64'] as String?,
      dateAdded: DateTime.parse(map['date_added'] as String),
    );
  }
}


