import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/user_service.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  String? _userName; 

  String? getUserName() => _userName; 

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); 
      
      final userRoleFromAPI = UserRole.coronel;
    
      _userName = 'Eliane Silva'; 

      UserService.instance.login(userRoleFromAPI);
      
      return true;
    } catch (e) {
      print("Falha na autenticação: $e");
      return false;
    }
  }
}