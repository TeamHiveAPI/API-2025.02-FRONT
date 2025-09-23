import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/permissions.dart';

class UserModel {
  final int idUsuario;
  final String nome;
  final String email;
  final String cpf;
  final int nivelAcesso;
  final int idSetor;
  final String authUid;
  final UserRole role;

  UserModel({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.nivelAcesso,
    required this.idSetor,
    required this.authUid,
    required this.role,
  });
}

class UserService {
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  static const _storage = FlutterSecureStorage();
  static const String _userKey = 'current_user';

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Mapear role baseado em nivel_acesso e id_setor
  static UserRole _mapRoleFromDatabase(int nivelAcesso, int idSetor) {
    switch (nivelAcesso) {
      case 1:
        switch (idSetor) {
          case 0:
            return UserRole.soldadoComum;
          case 1:
            return UserRole.soldadoEstoque;
          case 2:
            return UserRole.soldadoFarmacia;
          default:
            return UserRole.soldadoComum;
        }
      case 2:
        switch (idSetor) {
          case 1:
            return UserRole.tenenteEstoque;
          case 2:
            return UserRole.tenenteFarmacia;
          default:
            return UserRole.soldadoComum;
        }
      case 3:
        if (idSetor == 3) {
          return UserRole.coronel;
        }
        return UserRole.soldadoComum;
      default:
        return UserRole.soldadoComum;
    }
  }

  // Login com dados reais do banco
  void login({
    required int idUsuario,
    required String nome,
    required String email,
    required String cpf,
    required int nivelAcesso,
    required int idSetor,
    required String authUid,
  }) {
    final role = _mapRoleFromDatabase(nivelAcesso, idSetor);

    _currentUser = UserModel(
      idUsuario: idUsuario,
      nome: nome,
      email: email,
      cpf: cpf,
      nivelAcesso: nivelAcesso,
      idSetor: idSetor,
      authUid: authUid,
      role: role,
    );

    // Salvar no storage local
    _saveUserToStorage();
  }

  // Salvar usuário no storage local
  Future<void> _saveUserToStorage() async {
    if (_currentUser != null) {
      final userJson = jsonEncode({
        'idUsuario': _currentUser!.idUsuario,
        'nome': _currentUser!.nome,
        'email': _currentUser!.email,
        'cpf': _currentUser!.cpf,
        'nivelAcesso': _currentUser!.nivelAcesso,
        'idSetor': _currentUser!.idSetor,
        'authUid': _currentUser!.authUid,
        'role': _currentUser!.role.name,
      });
      await _storage.write(key: _userKey, value: userJson);
    }
  }

  // Carregar usuário do storage local
  Future<bool> loadUserFromStorage() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        final role = UserRole.values.firstWhere(
          (r) => r.name == userData['role'],
          orElse: () => UserRole.soldadoComum,
        );

        _currentUser = UserModel(
          idUsuario: userData['idUsuario'],
          nome: userData['nome'],
          email: userData['email'],
          cpf: userData['cpf'],
          nivelAcesso: userData['nivelAcesso'],
          idSetor: userData['idSetor'],
          authUid: userData['authUid'],
          role: role,
        );
        return true;
      }
    } catch (e) {
      print('Erro ao carregar usuário do storage: $e');
    }
    return false;
  }

  // Logout - limpar contexto local
  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: _userKey);
  }

  bool can(AppPermission permission) {
    if (_currentUser == null) return false;

    final userPermissions = permissionsByRole[_currentUser!.role];
    if (userPermissions == null) return false;

    return userPermissions.contains(permission);
  }
}
