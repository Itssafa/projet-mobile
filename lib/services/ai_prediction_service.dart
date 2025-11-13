import '../models/feeding.dart';
import '../models/animal.dart';

class AIPredictionService {
  // Prédire quand le stock sera épuisé avec analyse avancée
  static int predictStockout(Feeding feeding) {
    if (feeding.dailyQuantity <= 0) return 0;
    // Calcul basé sur la consommation quotidienne
    final days = (feeding.currentStock / feeding.dailyQuantity).floor();
    return days;
  }

  // Prédire les besoins alimentaires basés sur l'animal (poids, âge, race, activité)
  static double predictDailyQuantity(Animal animal, {String? breed, String? activityLevel}) {
    // Formule améliorée basée sur le poids, l'espèce, l'âge, la race et l'activité
    double baseQuantity = 0;
    final species = animal.species.toLowerCase();

    // Base selon l'espèce
    if (species == 'chien' || species == 'dog') {
      // Chien : 2-3% du poids corporel selon la taille
      if (animal.weight < 10) {
        // Petit chien : 3-4%
        baseQuantity = animal.weight * 0.035 * 1000;
      } else if (animal.weight < 25) {
        // Chien moyen : 2.5-3%
        baseQuantity = animal.weight * 0.027 * 1000;
      } else {
        // Grand chien : 2-2.5%
        baseQuantity = animal.weight * 0.022 * 1000;
      }
    } else if (species == 'chat' || species == 'cat') {
      // Chat : 2-3% du poids corporel
      baseQuantity = animal.weight * 0.025 * 1000;
    } else {
      // Autres espèces : estimation basique
      baseQuantity = animal.weight * 0.025 * 1000;
    }

    // Ajustement selon l'âge (en mois)
    if (animal.age < 6) {
      // Très jeune (chiot/chaton) : besoin très élevé (croissance)
      baseQuantity *= 1.5;
    } else if (animal.age < 12) {
      // Jeune : besoin élevé
      baseQuantity *= 1.3;
    } else if (animal.age > 84) {
      // Animal âgé (7+ ans) : besoin réduit
      baseQuantity *= 0.8;
    } else if (animal.age > 120) {
      // Animal très âgé (10+ ans) : besoin encore plus réduit
      baseQuantity *= 0.7;
    }

    // Ajustement selon la race (si fournie)
    if (breed != null) {
      final breedLower = breed.toLowerCase();
      // Races très actives
      if (breedLower.contains('border') || breedLower.contains('jack russell') || 
          breedLower.contains('beagle') || breedLower.contains('labrador')) {
        baseQuantity *= 1.2;
      }
      // Races calmes
      else if (breedLower.contains('bulldog') || breedLower.contains('basset') || 
               breedLower.contains('persan') || breedLower.contains('british')) {
        baseQuantity *= 0.9;
      }
    }

    // Ajustement selon le niveau d'activité (si fourni)
    if (activityLevel != null) {
      final activity = activityLevel.toLowerCase();
      if (activity == 'très actif' || activity == 'very active') {
        baseQuantity *= 1.3;
      } else if (activity == 'actif' || activity == 'active') {
        baseQuantity *= 1.1;
      } else if (activity == 'calme' || activity == 'calm' || activity == 'sédentaire') {
        baseQuantity *= 0.9;
      }
    }

    return baseQuantity.roundToDouble();
  }

  // Recommander le moment de réapprovisionnement avec prédiction intelligente
  static int recommendRestockDays(Feeding feeding) {
    final daysUntilStockout = predictStockout(feeding);
    
    // Recommandation proactive : réapprovisionner avant épuisement
    if (daysUntilStockout <= 2) {
      return 0; // Réapprovisionner immédiatement (critique)
    } else if (daysUntilStockout <= 5) {
      return daysUntilStockout - 2; // Réapprovisionner dans 1-3 jours
    } else if (daysUntilStockout <= 10) {
      return daysUntilStockout - 3; // Réapprovisionner dans 2-7 jours
    } else {
      return daysUntilStockout - 5; // Réapprovisionner dans 5+ jours
    }
  }

  // Analyser la consommation moyenne avec historique simulé
  static double calculateAverageConsumption(Feeding feeding, int days) {
    // Simulation d'analyse historique
    // Dans une vraie implémentation, on analyserait l'historique réel
    double average = feeding.dailyQuantity;
    
    // Variation simulée basée sur les jours
    if (days > 7) {
      // Sur une période longue, légère variation
      average *= 0.95; // Légèrement moins que prévu
    }
    
    return average;
  }

  // Prédire les besoins nutritionnels futurs
  static Map<String, dynamic> predictNutritionalNeeds(Animal animal, Feeding? currentFeeding) {
    final predictedQuantity = predictDailyQuantity(animal);
    final currentQuantity = currentFeeding?.dailyQuantity ?? 0;
    final difference = predictedQuantity - currentQuantity;
    
    return {
      'predictedQuantity': predictedQuantity,
      'currentQuantity': currentQuantity,
      'difference': difference,
      'recommendation': difference.abs() > 50 
          ? (difference > 0 ? 'Augmenter' : 'Réduire') 
          : 'Maintenir',
      'percentageChange': currentQuantity > 0 
          ? ((difference / currentQuantity) * 100).round() 
          : 0,
    };
  }

  // Estimer la date d'épuisement avec marge d'erreur
  static Map<String, dynamic> predictStockoutWithMargin(Feeding feeding) {
    final days = predictStockout(feeding);
    final averageConsumption = calculateAverageConsumption(feeding, 30);
    
    // Calcul avec marge d'erreur de 10%
    final optimisticDays = (feeding.currentStock / (averageConsumption * 0.9)).floor();
    final pessimisticDays = (feeding.currentStock / (averageConsumption * 1.1)).floor();
    
    return {
      'mostLikely': days,
      'optimistic': optimisticDays,
      'pessimistic': pessimisticDays,
      'confidence': days > 10 ? 'high' : days > 5 ? 'medium' : 'low',
    };
  }
}


