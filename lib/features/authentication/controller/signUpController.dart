import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/core/hive_boxes.dart';
import 'package:my_app/features/authentication/models/auth_model.dart';

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

    // TODO: Real API call here

    if (formData.rememberMe) {
      final box = Hive.box(HiveBoxes.authBox);

      await box.put('email', formData.email);
      await box.put('password', formData.password);
    }

    onSuccess();
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
