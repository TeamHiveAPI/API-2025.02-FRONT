import 'package:sistema_almox/config/supabase_config.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UserInactiveException implements Exception {
  final String message;
  UserInactiveException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Usuário ou senha inválidos.');
      }

      final userId = response.user!.id;

      final userProfile = await SupabaseConfig.client
          .from('usuario')
          .select('usr_ativo')
          .eq('usr_auth_uid', userId)
          .single();

      final isAtivo = userProfile['usr_ativo'] as bool;

      if (!isAtivo) {
        await logout();
        throw UserInactiveException(
          'Não é possivel realizar o login: este usuário foi desativado.',
        );
      }

      await UserService.instance.fetchAndSetCurrentUser(userId);
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e) {
      print("Erro ao buscar perfil: $e");
      await logout();
      throw Exception('Erro de configuração da conta. Contate o suporte.');
    } on UserInactiveException {
      rethrow;
    } catch (e) {
      print("Falha na autenticação: $e");
      await logout();
      throw Exception('Ocorreu um erro inesperado. Tente novamente.');
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
