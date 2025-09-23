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

class UserService with ChangeNotifier {
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

    // Print detalhado das informações do usuário logado
    print('=== INFORMAÇÕES DO USUÁRIO LOGADO ===');
    print('Nome: $nome');
    print('Email: $email');
    print('CPF: $cpf');
    print('ID Usuário: $idUsuario');
    print('Nível de Acesso: $nivelAcesso');
    print('ID Setor: $idSetor');
    print('Auth UID: $authUid');
    print('UserRole: ${role.name}');
    print('Tipo de Usuário: ${_getUserTypeDescription(role)}');
    print('Setor: ${_getSetorDescription(idSetor)}');
    print('Permissões: ${_getUserPermissions(role)}');
    print('=====================================');

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

  // Métodos auxiliares para descrições legíveis
  String _getUserTypeDescription(UserRole role) {
    switch (role) {
      case UserRole.coronel:
        return 'Coronel - Comando Geral';
      case UserRole.tenenteEstoque:
        return 'Tenente - Comando de Estoque';
      case UserRole.tenenteFarmacia:
        return 'Tenente - Comando de Farmácia';
      case UserRole.soldadoEstoque:
        return 'Soldado - Setor de Estoque';
      case UserRole.soldadoFarmacia:
        return 'Soldado - Setor de Farmácia';
      case UserRole.soldadoComum:
        return 'Soldado - Sem Setor Específico';
    }
  }

  String _getSetorDescription(int idSetor) {
    switch (idSetor) {
      case 0:
        return 'Sem Setor Específico';
      case 1:
        return 'Estoque/Almoxarifado';
      case 2:
        return 'Farmácia';
      case 3:
        return 'Comando Geral';
      default:
        return 'Setor Desconhecido ($idSetor)';
    }
  }

  String _getUserPermissions(UserRole role) {
    final permissions = permissionsByRole[role];
    if (permissions == null) return 'Nenhuma permissão';
    
    return permissions.map((p) => _getPermissionDescription(p)).join(', ');
  }

  String _getPermissionDescription(AppPermission permission) {
    switch (permission) {
      case AppPermission.accessAdminScreen:
        return 'Acesso à Tela Admin';
      case AppPermission.viewStockItems:
        return 'Ver Itens do Estoque';
      case AppPermission.viewPharmacyItems:
        return 'Ver Itens da Farmácia';
      case AppPermission.createOrders:
        return 'Criar Pedidos';
      case AppPermission.viewAllOrders:
        return 'Ver Todos os Pedidos';
      case AppPermission.editItems:
        return 'Editar Itens';
      case AppPermission.viewReports:
        return 'Ver Relatórios';
    }
  }
}
