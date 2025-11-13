import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/features/Budget/controller/budget_controller.dart';

import 'package:my_app/features/Budget/views/stats_page.dart';









 class BudgetPage extends StatefulWidget {
   const BudgetPage({super.key});

   @override
   State<BudgetPage> createState() => _BudgetPageState();
 }

 class _BudgetPageState extends State<BudgetPage> with SingleTickerProviderStateMixin {
   final BudgetController controller = Get.put(BudgetController());
   late TabController _tabController;

   @override
   void initState() {
     super.initState();
     _tabController = TabController(length: 2, vsync: this);
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: const Color(0xFFFDF2F8),
       appBar: AppBar(
         title: const Text(
           "Mon Budget Intelligent",
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
         ),
         centerTitle: true,
         backgroundColor: const Color(0xFFDB2777),
         elevation: 0,
         shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
         ),
         bottom: TabBar(
           controller: _tabController,
           indicatorColor: Colors.white,
           indicatorWeight: 3,
           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
           unselectedLabelColor: Colors.white.withOpacity(0.7),
           tabs: const [
             Tab(text: "Mes Catégories", icon: Icon(Icons.category)),
             Tab(text: "Nouvelle Catégorie", icon: Icon(Icons.add)),
           ],
         ),
       ),
       body: TabBarView(
         controller: _tabController,
         children: [
           _buildCategoriesTab(),
           _buildAddCategoryTab(),
         ],
       ),
     );
   }

   // ===================== CATEGORIES TAB =====================
   Widget _buildCategoriesTab() {
     return Obx(() {
       if (controller.categories.isEmpty) {
         return _buildEmptyState();
       }

       return ListView.builder(
         padding: const EdgeInsets.all(16),
         itemCount: controller.categories.length,
         itemBuilder: (context, index) {
           final cat = controller.categories[index];
           final nom = cat['nom'];
           final depenses = controller.calculerDepenses(nom);
           final restant = controller.budgetRestant(nom);
           final progress = depenses / cat['budget'];

           return _buildCategoryCard(cat, nom, depenses, restant, progress, index);
         },
       );
     });
   }

   Widget _buildCategoryCard(
     Map<String, dynamic> cat,
     String nom,
     double depenses,
     double restant,
     double progress,
     int index,
   ) {
     return Card(
       elevation: 2,
       margin: const EdgeInsets.only(bottom: 16),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
       color: Colors.white,
       child: Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         _getCategoryColor(index),
                         _getCategoryColor(index).withOpacity(0.7),
                       ],
                     ),
                     borderRadius: BorderRadius.circular(14),
                   ),
                   child: const Icon(Icons.category, color: Colors.white, size: 22),
                 ),
                 const SizedBox(width: 15),
                 Expanded(
                   child: Text(
                     nom,
                     style: const TextStyle(
                       fontWeight: FontWeight.w700,
                       fontSize: 17,
                       color: Color(0xFF831843),
                     ),
                   ),
                 ),
                 // Boutons Modifier / Supprimer / Ajouter dépense
                 IconButton(
                   icon: const Icon(Icons.edit, color: Color(0xFF065F46)),
                   onPressed: () {
                     _showEditCategoryDialog(cat);
                   },
                 ),
                 IconButton(
                   icon: const Icon(Icons.delete, color: Color(0xFFDC2626)),
                   onPressed: () {
                     final catIndex = controller.categories.indexWhere((c) => c['nom'] == nom);
                     if (catIndex != -1) controller.supprimerCategorie(catIndex);
                   },
                 ),
                 IconButton(
                   icon: const Icon(Icons.add, color: Color(0xFF065F46)),
                   onPressed: () {
                     _showAddExpenseDialog(nom);
                   },
                 ),
               ],
             ),
             const SizedBox(height: 16),
             LinearProgressIndicator(
               value: progress > 1 ? 1 : progress,
               backgroundColor: const Color(0xFFFCE7F3),
               color: progress > 0.8 ? const Color(0xFFF87171) : const Color(0xFFF472B6),
               minHeight: 12,
             ),
             const SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   "Budget: ${cat['budget']} DT",
                   style: const TextStyle(
                     fontSize: 13,
                     color: Color(0xFF9D174D),
                     fontWeight: FontWeight.w500,
                   ),
                 ),
                 Text(
                   "Dépensé: ${depenses.toStringAsFixed(2)} DT",
                   style: const TextStyle(
                     fontSize: 13,
                     color: Color(0xFF9D174D),
                     fontWeight: FontWeight.w500,
                   ),
                 ),
                 Text(
                   "Restant: ${restant.toStringAsFixed(2)} DT",
                   style: TextStyle(
                     fontSize: 13,
                     fontWeight: FontWeight.w600,
                     color: restant < 0 ? Colors.red : Colors.green,
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 10),
             if (cat['depenses'].isNotEmpty)
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: cat['depenses'].length,
                 itemBuilder: (context, depIndex) {
                   final d = cat['depenses'][depIndex];
                   return Container(
                     margin: const EdgeInsets.only(bottom: 12),
                     padding: const EdgeInsets.all(18),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(18),
                       border: Border.all(color: const Color(0xFFFCE7F3)),
                       boxShadow: [
                         BoxShadow(
                           color: const Color(0xFFF472B6).withOpacity(0.1),
                           blurRadius: 8,
                           offset: const Offset(0, 2),
                         ),
                       ],
                     ),
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: const Color(0xFFFECDD3),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: const Icon(Icons.arrow_downward, color: Color(0xFFDB2777), size: 20),
                         ),
                         const SizedBox(width: 15),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 d['titre'],
                                 style: const TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: Color(0xFF831843),
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 "Ajouté récemment",
                                 style: TextStyle(fontSize: 12, color: const Color(0xFF9D174D).withOpacity(0.6)),
                               ),
                             ],
                           ),
                         ),
                         Text(
                           "-${d['montant'].toStringAsFixed(2)} DT",
                           style: const TextStyle(
                             color: Color(0xFFDB2777),
                             fontWeight: FontWeight.w700,
                             fontSize: 16,
                           ),
                         ),
                         const SizedBox(width: 8),
                         IconButton(
                           icon: const Icon(Icons.edit, color: Color(0xFF065F46)),
                           onPressed: () {
                             _showEditExpenseDialog(cat['nom'], depIndex, d['titre'], d['montant']);
                           },
                         ),
                         IconButton(
                           icon: const Icon(Icons.delete, color: Color(0xFFDC2626)),
                           onPressed: () {
                             controller.supprimerDepense(cat['nom'], depIndex);
                           },
                         ),
                       ],
                     ),
                   );
                 },
               ),
           ],
         ),
       ),
     );
   }


   // ===================== DIALOG POUR AJOUTER DÉPENSE =====================
   void _showAddExpenseDialog(String nomCategorie) {
     final TextEditingController titreController = TextEditingController();
     final TextEditingController montantController = TextEditingController();

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text("Ajouter Dépense"),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(controller: titreController, decoration: const InputDecoration(labelText: "Titre")),
               TextField(
                 controller: montantController,
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(labelText: "Montant"),
               ),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("Annuler"),
             ),
             ElevatedButton(
               onPressed: () {
                 final titre = titreController.text.trim();
                 final montant = double.tryParse(montantController.text) ?? 0.0;
                 if (titre.isNotEmpty && montant > 0) {
                   controller.ajouterDepense(nomCategorie, titre, montant);
                   Navigator.pop(context);
                 }
               },
               child: const Text("Ajouter"),
             ),
           ],
         );
       },
     );
   }

   // ===================== DIALOGUES POUR MODIFIER =====================
   void _showEditCategoryDialog(Map<String, dynamic> cat) {
     final TextEditingController nomController = TextEditingController(text: cat['nom']);
     final TextEditingController budgetController = TextEditingController(text: cat['budget'].toString());

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text("Modifier Catégorie"),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(controller: nomController, decoration: const InputDecoration(labelText: "Nom")),
               TextField(
                 controller: budgetController,
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(labelText: "Budget"),
               ),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("Annuler"),
             ),
             ElevatedButton(
               onPressed: () {
                 final nom = nomController.text.trim();
                 final budget = double.tryParse(budgetController.text) ?? 0.0;
                 final catIndex = controller.categories.indexWhere((c) => c['nom'] == cat['nom']);
                 if (catIndex != -1 && nom.isNotEmpty && budget > 0) {
                   controller.modifierCategorie(catIndex, nom, budget);
                   Navigator.pop(context);
                 }
               },
               child: const Text("Modifier"),
             ),
           ],
         );
       },
     );
   }

   void _showEditExpenseDialog(String nomCategorie, int index, String titre, double montant) {
     final TextEditingController titreController = TextEditingController(text: titre);
     final TextEditingController montantController = TextEditingController(text: montant.toString());

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text("Modifier Dépense"),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(controller: titreController, decoration: const InputDecoration(labelText: "Titre")),
               TextField(
                 controller: montantController,
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(labelText: "Montant"),
               ),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("Annuler"),
             ),
             ElevatedButton(
               onPressed: () {
                 final titreNew = titreController.text.trim();
                 final montantNew = double.tryParse(montantController.text) ?? 0.0;
                 if (titreNew.isNotEmpty && montantNew > 0) {
                   controller.modifierDepense(nomCategorie, index, titreNew, montantNew);
                   Navigator.pop(context);
                 }
               },
               child: const Text("Modifier"),
             ),
           ],
         );
       },
     );
   }

   // ===================== ADD CATEGORY TAB =====================
   Widget _buildAddCategoryTab() {
     final TextEditingController nomCategorie = TextEditingController();
     final TextEditingController budgetCategorie = TextEditingController();

     return SingleChildScrollView(
       padding: const EdgeInsets.all(20),
       child: Column(
         children: [
           ElevatedButton(
             onPressed: () {
               Get.to(() => StatsPage());
             },
             child: Text("Voir Statistiques"),
           ),

           const SizedBox(height: 20),

           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(25),
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [Color(0xFFDB2777), Color(0xFFF472B6)],
               ),
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(
                   color: const Color(0xFFDB2777).withOpacity(0.3),
                   blurRadius: 15,
                   offset: const Offset(0, 6),
                 ),
               ],
             ),
             child: Column(
               children: [
                 const Icon(Icons.auto_awesome, color: Colors.white, size: 45),
                 const SizedBox(height: 15),
                 const Text(
                   "Nouvelle Catégorie",
                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                 ),
                 const SizedBox(height: 10),
                 Text(
                   "Organisez vos finances avec style",
                   style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
           ),

           const SizedBox(height: 30),

           _buildStyledTextField(
             controller: nomCategorie,
             label: "Nom de la catégorie",
             hint: "Ex: Loisirs, Courses, Transport...",
             icon: Icons.category,
           ),

           const SizedBox(height: 20),

           _buildStyledTextField(
             controller: budgetCategorie,
             label: "Budget initial",
             hint: "Montant en DT",
             icon: Icons.attach_money,
             isNumber: true,
           ),

           const SizedBox(height: 30),

           Container(
             width: double.infinity,
             height: 58,
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 colors: [Color(0xFFDB2777), Color(0xFFF472B6)],
               ),
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(
                   color: const Color(0xFFDB2777).withOpacity(0.4),
                   blurRadius: 12,
                   offset: const Offset(0, 6),
                 ),
               ],
             ),
             child: ElevatedButton(
               onPressed: () {
                 final nom = nomCategorie.text.trim();
                 final montant = double.tryParse(budgetCategorie.text) ?? 0.0;

                 if (nom.isNotEmpty && montant > 0) {
                   controller.ajouterCategorie(nom, montant);
                   nomCategorie.clear();
                   budgetCategorie.clear();
                   _tabController.animateTo(0);

                   Get.snackbar(
                     'Succès 🎀',
                     'Catégorie "$nom" créée avec succès!',
                     backgroundColor: const Color(0xFFDB2777),
                     colorText: Colors.white,
                     snackPosition: SnackPosition.BOTTOM,
                     margin: const EdgeInsets.all(16),
                     borderRadius: 15,
                   );
                 } else {
                   Get.snackbar(
                     'Attention 💖',
                     'Veuillez remplir tous les champs correctement',
                     backgroundColor: const Color(0xFFF472B6),
                     colorText: Colors.white,
                     snackPosition: SnackPosition.BOTTOM,
                   );
                 }
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.transparent,
                 shadowColor: Colors.transparent,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(20),
                 ),
               ),
               child: const Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.add_circle, color: Colors.white, size: 26),
                   SizedBox(width: 10),
                   Text(
                     "Créer la catégorie",
                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                   ),
                 ],
               ),
             ),
           ),
         ],
       ),
     );
   }


   Widget _buildStyledTextField({
     required TextEditingController controller,
     required String label,
     required String hint,
     required IconData icon,
     bool isNumber = false,
   }) {
     return Container(
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(16),
         boxShadow: [
           BoxShadow(
             color: const Color(0xFFF472B6).withOpacity(0.1),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
       child: TextField(
         controller: controller,
         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
         decoration: InputDecoration(
           labelText: label,
           hintText: hint,
           prefixIcon: Icon(icon, color: const Color(0xFFDB2777)),
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(16),
             borderSide: const BorderSide(color: Color(0xFFFBCFE8)),
           ),
           focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(16),
             borderSide: const BorderSide(color: Color(0xFFDB2777), width: 2),
           ),
           filled: true,
           fillColor: Colors.white,
           labelStyle: const TextStyle(color: Color(0xFF9D174D)),
           hintStyle: TextStyle(color: const Color(0xFF9D174D).withOpacity(0.5)),
         ),
         style: const TextStyle(color: Color(0xFF831843)),
       ),
     );
   }

   Color _getCategoryColor(int index) {
     final colors = [
       const Color(0xFFDB2777),
       const Color(0xFFEC4899),
       const Color(0xFFF472B6),
       const Color(0xFFF9A8D4),
       const Color(0xFFBE185D),
       const Color(0xFF831843),
     ];
     return colors[index % colors.length];
   }

   Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: const [
           Icon(Icons.hourglass_empty, size: 60, color: Color(0xFFF472B6)),
           SizedBox(height: 20),
           Text(
             "Aucune catégorie pour le moment",
             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF831843)),
           ),
         ],
       ),
     );
   }
 }
