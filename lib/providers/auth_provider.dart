import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Utilisateurs par défaut (en production, utiliser une vraie base de données)
  final Map<String, Map<String, String>> _users = {
    'admin': {
      'password': 'admin123',
      'email': 'admin@refuge.com',
      'role': 'admin',
    },
    'veterinarian': {
      'password': 'vet123',
      'email': 'vet@refuge.com',
      'role': 'veterinarian',
    },
    'caretaker': {
      'password': 'care123',
      'email': 'caretaker@refuge.com',
      'role': 'caretaker',
    },
  };

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Vérifier si l'utilisateur est authentifié
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simuler un délai de connexion
    await Future.delayed(const Duration(milliseconds: 500));

    if (_users.containsKey(username.toLowerCase())) {
      final userData = _users[username.toLowerCase()]!;
      if (userData['password'] == password) {
        _currentUser = User(
          username: username,
          email: userData['email']!,
          role: userData['role']!,
          lastLogin: DateTime.now(),
        );
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Inscription (pour ajouter de nouveaux utilisateurs)
  Future<bool> register(String username, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (_users.containsKey(username.toLowerCase())) {
      _isLoading = false;
      notifyListeners();
      return false; // Utilisateur existe déjà
    }

    _users[username.toLowerCase()] = {
      'password': password,
      'email': email,
      'role': role,
    };

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Vérifier si l'utilisateur a les permissions
  bool hasPermission(String requiredRole) {
    if (!_isAuthenticated || _currentUser == null) return false;
    if (_currentUser!.role == 'admin') return true; // Admin a tous les droits
    return _currentUser!.role == requiredRole;
  }

  // Obtenir le nom d'affichage
  String get displayName {
    if (_currentUser == null) return 'Invité';
    return _currentUser!.username;
  }

  // Obtenir le rôle d'affichage
  String get displayRole {
    if (_currentUser == null) return '';
    switch (_currentUser!.role) {
      case 'admin':
        return 'Administrateur';
      case 'veterinarian':
        return 'Vétérinaire';
      case 'caretaker':
        return 'Soigneur';
      default:
        return _currentUser!.role;
    }
  }
}

