import 'package:flutter/material.dart';
import 'package:my_app/core/hive_boxes.dart';
import 'package:my_app/features/authentication/models/auth_model.dart';
import 'package:my_app/features/authentication/models/user.dart';

class SignUpController {
  final AuthFormData formData = AuthFormData();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility(VoidCallback update) {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void toggleConfirmPasswordVisibility(VoidCallback update) {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    update();
  }

  bool validateForm() {
    final form = formKey.currentState;
    if (form == null) return false;

    if (!form.validate()) return false;

    form.save();
    return true;
  }

  Future<void> onSignUp(BuildContext context, VoidCallback onSuccess) async {
    if (!validateForm()) return;

    try {
      // Créer un nouvel utilisateur et l'ajouter à Hive
      final box = HiveBoxes.getUserBox();
      
      final newUser = User(
        email: formData.email.trim(),
        password: formData.password,
        rememberMe: formData.rememberMe,
      );
      
      // Vérifier si l'email existe déjà
      final emailExists = box.values.any((user) => user.email == newUser.email);
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cet email est déjà utilisé'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      // Ajouter l'utilisateur à la boîte
      await box.add(newUser);
      
      onSuccess();
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
