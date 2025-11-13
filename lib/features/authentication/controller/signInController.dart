// file: sign_in_controller.dart
import 'package:flutter/material.dart';
import 'package:my_app/features/authentication/models/auth_model.dart';

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

  void onSignIn(BuildContext context, VoidCallback onSuccess) {
    if (validateForm()) {
      // TODO: Call your auth service here
      onSuccess();
    }
  }

  void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }
}
