import 'package:flutter/material.dart';
import 'package:my_app/features/authentication/controller/signUpController.dart';
import 'package:my_app/utils/constants/colors.dart';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({super.key});

  @override
  State<SignUpPage1> createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
  final SignUpController controller = SignUpController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Widget _gap() => const SizedBox(height: 16);

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

                    /// TITLE
                    Text(
                      "Create Account", // Replace with authentification.signUpTitle
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Fill in your information to create an account", // Replace
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    _gap(),

                    /// EMAIL
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Email is required";
                        if (!value.contains("@")) return "Enter a valid email";
                        return null;
                      },
                      onSaved: (value) => controller.formData.email = value ?? '',
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    _gap(),

                    /// PASSWORD
                  TextFormField(
                      controller: passwordController, 
                      obscureText: !controller.isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Password required";
                        if (value.length < 6) return "Minimum 6 characters";
                        return null;
                      },
                      onSaved: (value) => controller.formData.password = value ?? '',
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
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

                    /// CONFIRM PASSWORD
                  TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !controller.isConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Confirm your password";
                        // FIX: Compare with the main password controller's text
                        if (value != passwordController.text) { // <--- FIXED COMPARISON
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "Re-enter your password",
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            controller.toggleConfirmPasswordVisibility(() => setState(() {}));
                          },
                        ),
                      ),
                    ),

                    _gap(),

                    /// REMEMBER ME
                    CheckboxListTile(
                      value: controller.formData.rememberMe,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          controller.formData.rememberMe = value;
                        });
                      },
                      title: const Text("Remember me"),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),

                    _gap(),

                    /// SIGN UP BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          controller.onSignUp(context, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Account created!")),
                            );
                            Navigator.pushNamed(context, '/login');
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Create Account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    _gap(),

                    /// LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => controller.navigateToLogin(context),
                          child: Text(
                            " Login",
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
}
