import 'package:flutter/material.dart';
import 'package:my_app/core/hive_boxes.dart';
import 'package:my_app/features/authentication/models/user.dart';

class ProfileController {
  User? currentUser;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool rememberMe = false;

  /// Charge l'utilisateur courant. Priorité: user avec rememberMe=true, sinon premier utilisateur
  Future<void> loadUser() async {
    final box = HiveBoxes.getUserBox();
    if (box.isEmpty) return;

    // Cherche l'utilisateur qui a rememberMe = true
    try {
      final rememberedList = box.values.where((u) => u.rememberMe == true);
      if (rememberedList.isNotEmpty) {
        currentUser = rememberedList.first;
      } else {
        currentUser = box.values.first;
      }

      if (currentUser != null) {
        email = currentUser!.email;
        password = currentUser!.password;
        rememberMe = currentUser!.rememberMe;
      }
    } catch (e) {
      // fallback: do nothing
      debugPrint('Profile loadUser error: $e');
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form == null) return false;
    if (!form.validate()) return false;
    form.save();
    return true;
  }

  /// Met à jour l'utilisateur courant avec les champs email/password/rememberMe
  Future<bool> updateUser(BuildContext context) async {
    if (!validateAndSave()) return false;

    final box = HiveBoxes.getUserBox();

    try {
      if (currentUser != null) {
        currentUser!.email = email;
        currentUser!.password = password;
        currentUser!.rememberMe = rememberMe;
        await currentUser!.save();
      } else {
        final newUser = User(email: email.trim(), password: password, rememberMe: rememberMe);
        await box.add(newUser);
        currentUser = newUser;
      }

      // Récupérer le messenger avant de montrer le SnackBar (évite l'avertissement)
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil mis à jour'), duration: Duration(seconds: 2)),
      );
      return true;
    } catch (e) {
      debugPrint('Profile updateUser error: $e');
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Erreur lors de la mise à jour')),
      );
      return false;
    }
  }

  /// Supprime l'utilisateur courant
  Future<void> deleteUser(BuildContext context) async {
    if (currentUser == null) return;
    try {
      // Pré-capturer les états UI avant l'opération asynchrone
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await currentUser!.delete();
      currentUser = null;
      email = '';
      password = '';
      rememberMe = false;
      formKey.currentState?.reset();
      messenger.showSnackBar(
        const SnackBar(content: Text('Compte supprimé'), duration: Duration(seconds: 2)),
      );
      // Redirect to signup or login
      navigator.pushNamedAndRemoveUntil('/signup', (route) => false);
    } catch (e) {
      debugPrint('Profile deleteUser error: $e');
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du compte')),
      );
    }
  }
}
