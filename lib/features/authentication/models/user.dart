// lib/features/authentication/models/user.dart
import 'package:hive/hive.dart';

part 'user.g.dart'; // ← this will be generated

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String password;

  @HiveField(2)
  bool rememberMe;

  User({required this.email, required this.password, this.rememberMe = false});
}
