import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BudgetController extends GetxController {
  final box = GetStorage();
  var categories = <Map<String, dynamic>>[].obs; // Liste des catégories

  @override
  void onInit() {
    super.onInit();
    categories.value = List<Map<String, dynamic>>.from(box.read('categories') ?? []);
  }

  // ===================== CATÉGORIES =====================
  void ajouterCategorie(String nom, double budget) {
    if (nom.isEmpty || budget <= 0) {
      Get.snackbar('Erreur', 'Nom ou budget invalide');
      return;
    }

    // Vérifier si la catégorie existe déjà
    if (categories.any((c) => c['nom'] == nom)) {
      Get.snackbar('Erreur', 'Cette catégorie existe déjà');
      return;
    }

    categories.add({
      'nom': nom,
      'budget': budget,
      'depenses': <Map<String, dynamic>>[],
    });

    _saveCategories();
  }

  void modifierCategorie(int index, String nouveauNom, double nouveauBudget) {
    if (index < 0 || index >= categories.length) return;

    categories[index]['nom'] = nouveauNom;
    categories[index]['budget'] = nouveauBudget;

    _saveCategories();
    categories.refresh();
  }

  void supprimerCategorie(int index) {
    if (index < 0 || index >= categories.length) return;

    categories.removeAt(index);

    _saveCategories();
  }

  // ===================== DÉPENSES =====================
  void ajouterDepense(String nomCategorie, String titre, double montant) {
    final index = categories.indexWhere((cat) => cat['nom'] == nomCategorie);
    if (index == -1) return;

    final categorie = categories[index];
    final totalDepense = categorie['depenses']
        .fold(0.0, (sum, d) => sum + (d['montant'] as double));

    if (montant > (categorie['budget'] - totalDepense)) {
      Get.snackbar('Erreur', 'Montant supérieur au budget restant');
      return;
    }

    categorie['depenses'].add({'titre': titre, 'montant': montant,'date': DateTime.now().toIso8601String()});
    categories[index] = categorie;

    _saveCategories();
    categories.refresh();
  }

  void modifierDepense(String nomCategorie, int indexDepense, String titre, double montant) {
    final indexCat = categories.indexWhere((c) => c['nom'] == nomCategorie);
    if (indexCat == -1) return;
    if (indexDepense < 0 || indexDepense >= categories[indexCat]['depenses'].length) return;

    categories[indexCat]['depenses'][indexDepense]['titre'] = titre;
    categories[indexCat]['depenses'][indexDepense]['montant'] = montant;

    _saveCategories();
    categories.refresh();
  }

  void supprimerDepense(String nomCategorie, int indexDepense) {
    final indexCat = categories.indexWhere((c) => c['nom'] == nomCategorie);
    if (indexCat == -1) return;
    if (indexDepense < 0 || indexDepense >= categories[indexCat]['depenses'].length) return;

    categories[indexCat]['depenses'].removeAt(indexDepense);

    _saveCategories();
    categories.refresh();
  }

  // ===================== CALCULS =====================
  double calculerDepenses(String nomCategorie) {
    final categorie = categories.firstWhere((c) => c['nom'] == nomCategorie, orElse: () => {});
    if (categorie.isEmpty) return 0.0;

    return (categorie['depenses'] as List<dynamic>)
        .fold(0.0, (sum, d) => sum + (d['montant'] as double));
  }

  double budgetRestant(String nomCategorie) {
    final categorie = categories.firstWhere((c) => c['nom'] == nomCategorie, orElse: () => {});
    if (categorie.isEmpty) return 0.0;

    final depenses = calculerDepenses(nomCategorie);
    return (categorie['budget'] as double) - depenses;
  }

  // ===================== PRIVATE =====================
  void _saveCategories() {
    box.write('categories', categories);
  }




  Map<String, double> getDepensesParCategorie() {
    Map<String, double> stats = {};

    for (var cat in categories) {
      double total = (cat['depenses'] as List<dynamic>)
          .fold(0.0, (sum, d) => sum + (d['montant'] as double));

      stats[cat['nom']] = total;
    }

    return stats;
  }


double pourcentageDepense(String nomCategorie) {
  final cat = categories.firstWhere((c) => c['nom'] == nomCategorie);
  double total = calculerDepenses(nomCategorie);
  double budget = cat['budget'];

  return (total / budget);
}


















}
