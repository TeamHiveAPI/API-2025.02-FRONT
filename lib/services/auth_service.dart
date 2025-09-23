import 'package:sistema_almox/config/supabase_config.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await SupabaseConfig.client
            .from('usuario')
            .select(
              'id_usuario, nome, email, cpf, nivel_acesso, id_setor, auth_uid',
            )
            .eq('auth_uid', response.user!.id)
            .single();

        UserService.instance.login(
          idUsuario: userData['id_usuario'],
          nome: userData['nome'],
          email: userData['email'],
          cpf: userData['cpf'],
          nivelAcesso: userData['nivel_acesso'],
          idSetor: userData['id_setor'],
          authUid: userData['auth_uid'],
        );

        return true;
      }

      return false;
    } catch (e) {
      print("Falha na autenticação: $e");
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      UserService.instance.logout();
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      return session != null;
    } catch (e) {
      print("Erro ao verificar login: $e");
      return false;
    }
  }
}
