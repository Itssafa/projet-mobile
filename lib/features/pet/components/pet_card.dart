import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;

  const PetCard({super.key, required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🖼️ Image de l'animal
            Expanded(
              child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                  ? Image.file(
                File(pet.imageUrl!),
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/images/default_pet.png',
                fit: BoxFit.cover,
              ),
            ),

            // 🐾 Infos de l'animal
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.type}${pet.breed != null && pet.breed!.isNotEmpty ? " • ${pet.breed}" : ""}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Âge : ${pet.ageYears} an(s) ${pet.ageMonths} mois',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.isVaccinated ? '✅ Vacciné' : '❌ Non vacciné',
                    style: TextStyle(
                      color: pet.isVaccinated ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
