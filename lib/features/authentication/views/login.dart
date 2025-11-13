// file: sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/features/authentication/controller/signInController.dart';
import 'package:my_app/utils/constants/colors.dart';
import 'package:my_app/utils/constants/Content/signIn/signIn.dart';

class SignInPage1 extends StatefulWidget {
  const SignInPage1({super.key});

  @override
  State<SignInPage1> createState() => _SignInPage1State();
}

class _SignInPage1State extends State<SignInPage1> {
  final SignInController controller = SignInController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: controller.formKey,
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 350),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _gap(),
                    Text(
                      authentification.title1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        authentification.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),
                    // Email
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return authentification.emptyErrorMessage;
                        }
                        bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value);
                        if (!emailValid) return authentification.validEmail;
                        return null;
                      },
                      onSaved: (value) => controller.formData.email = value ?? '',
                      decoration: const InputDecoration(
                        labelText: authentification.emailLabel,
                        hintText: authentification.emailPlaceholder,
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    // Password
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return authentification.emptyErrorMessage;
                        }
                        if (value.length < 6) return authentification.validPassword;
                        return null;
                      },
                      obscureText: !controller.isPasswordVisible,
                      onSaved: (value) => controller.formData.password = value ?? '',
                      decoration: InputDecoration(
                        labelText: authentification.passwordLabel,
                        hintText: authentification.passwordPlaceholder,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            controller.togglePasswordVisibility(() => setState(() {}));
                          },
                        ),
                      ),
                    ),
                    _gap(),
                    // Remember Me
                    CheckboxListTile(
                      value: controller.formData.rememberMe,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          controller.formData.rememberMe = value;
                        });
                      },
                      title: const Text(authentification.rememberMe),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    _gap(),
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            authentification.cta,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          controller.onSignIn(context, () {
                            // TODO: Navigate after successful login
                          });
                        },
                      ),
                    ),
                    _gap(),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authentification.signupDescription,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => controller.navigateToSignup(context),
                          child: Text(
                            authentification.signupCta,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _gap(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
