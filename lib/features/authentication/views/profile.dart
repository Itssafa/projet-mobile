import 'package:flutter/material.dart';
import 'package:my_app/features/authentication/controller/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = ProfileController();
  bool _loading = true;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    controller.loadUser().then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: controller.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                      onSaved: (v) => controller.email = v ?? '',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: controller.password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Mot de passe requis';
                        if (v.length < 6) return 'Minimum 6 caractères';
                        return null;
                      },
                      onSaved: (v) => controller.password = v ?? '',
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: controller.rememberMe,
                      onChanged: (v) => setState(() => controller.rememberMe = v ?? false),
                      title: const Text('Remember me'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final ok = await controller.updateUser(context);
                              if (ok) setState(() {});
                            },
                            child: const Text('Enregistrer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: () async {
                              // confirmation
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Supprimer le compte'),
                                  content: const Text('Voulez-vous vraiment supprimer votre compte ?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
                                    ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await controller.deleteUser(context);
                              }
                            },
                            child: const Text('Supprimer le compte'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
