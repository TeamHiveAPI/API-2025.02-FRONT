import 'package:flutter/foundation.dart';
import '../config/permissions.dart';

class UserModel {
  final String name;
  final UserRole role;

  UserModel({required this.name, required this.role});
}

class UserService with ChangeNotifier {
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void login(UserRole role) {
    _currentUser = UserModel(name: role.name.toUpperCase(), role: role);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
  
  bool can(AppPermission permission) {
    if (_currentUser == null) return false;

    final userPermissions = permissionsByRole[_currentUser!.role];
    if (userPermissions == null) return false;

    return userPermissions.contains(permission);
  }
}