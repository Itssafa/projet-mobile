// file: sign_in_controller.dart
import 'package:flutter/material.dart';
// Hive import not required here; HiveBoxes helper provides typed access
import 'package:my_app/features/authentication/models/auth_model.dart';
import 'package:my_app/core/hive_boxes.dart';

class SignInController {
  final AuthFormData formData = AuthFormData();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  void togglePasswordVisibility(VoidCallback update) {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  bool validateForm() {
    final form = formKey.currentState;
    if (form == null) return false;
    if (!form.validate()) return false;
    form.save();
    return true;
  }

  /// Vérifie si un utilisateur existe dans Hive avec cet email et mot de passe
  Future<bool> userExists() async {
    try {
      final box = HiveBoxes.getUserBox();
      final email = formData.email.trim();

      // Parcours sécurisé des utilisateurs (évite les casts null qui échouent)
      for (final user in box.values) {
        if (user.email == email && user.password == formData.password) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification utilisateur: $e');
      return false;
    }
  }

  Future<void> onSignIn(BuildContext context, VoidCallback onSuccess) async {
    if (!validateForm()) return;

    // Récupérer le messenger avant l'opération asynchrone pour
    // éviter l'avertissement "use_build_context_synchronously".
    final messenger = ScaffoldMessenger.of(context);

    final exists = await userExists();
    if (exists) {
      onSuccess();
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Email ou mot de passe incorrect'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  /// Charge les identifiants mémorisés si disponibles
  Future<void> loadRememberedCredentials() async {
    try {
      final box = HiveBoxes.getUserBox();

      for (final user in box.values) {
        if (user.rememberMe == true) {
          formData.email = user.email;
          formData.password = user.password;
          formData.rememberMe = true;
          break;
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des identifiants: $e');
    }
  }

  /// Logout - réinitialise les données du formulaire
  Future<void> logout(BuildContext context) async {
    try {
      // Afficher une boîte de dialogue de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Confirmation'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  
                  // Réinitialiser les données du formulaire
                  formData.email = '';
                  formData.password = '';
                  formData.rememberMe = false;
                  
                  // Réinitialiser la clé du formulaire
                  formKey.currentState?.reset();
                  
                  // Afficher un message de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Déconnecté avec succès'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Naviguer vers la page de login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Erreur lors du logout: $e');
    }
  }
}
