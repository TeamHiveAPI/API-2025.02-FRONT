import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/user_service.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  Future<bool> login({
    required String email,
    required String password,
  }) async {

    try {
      await Future.delayed(const Duration(seconds: 1)); 

      // Simular que o usuário que entrou é um coronel
      final userRoleFromAPI = UserRole.coronel;

      UserService.instance.login(userRoleFromAPI);
      
      return true;
    } catch (e) {
      print("Falha na autenticação: $e");
      return false;
    }
  }
}