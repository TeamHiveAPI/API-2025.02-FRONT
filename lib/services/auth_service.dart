import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/sector_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

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
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw 'Usuário ou senha inválidos.';
      }

      final userProfile = await supabase
          .from('usuario')
          .select()
          .eq('auth_uid', authResponse.user!.id)
          .single();

      _userName = userProfile['nome'];
      final userRoleFromAPI = UserRole.values[userProfile['nivel_acesso']];
      final userSectorFromAPI = userProfile['id_setor'];

      UserService.instance.login(userRoleFromAPI);
      SectorService.instance.setSector(userSectorFromAPI);
      
      return true;

    } catch (e) {
      print("Falha na autenticação: $e");
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    UserService.instance.logout();
    SectorService.instance.clearSector();
    _userName = null;
  }
}