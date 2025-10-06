import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/permissions.dart';

class UserModel {
  final int idUsuario;
  final String nome;
  final String email;
  final String cpf;
  final int nivelAcesso;
  final int idSetor;
  final String authUid;
  final String? fotoUrl;
  final UserRole role;

  UserModel({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.nivelAcesso,
    required this.idSetor,
    required this.authUid,
    this.fotoUrl,
    required this.role,
  });
}

class UserService with ChangeNotifier {
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  static const _storage = FlutterSecureStorage();
  final supabase = Supabase.instance.client;

  static const String _userKey = 'current_user';

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  int? _viewingSectorId;
  int? get viewingSectorId => _viewingSectorId;

  Future<bool> fetchAndSetCurrentUser(String userId) async {
    try {
      final userData = await supabase
          .from(SupabaseTables.usuario)
          .select(
            '''
              ${UsuarioFields.id},
              ${UsuarioFields.nome},
              ${UsuarioFields.email},
              ${UsuarioFields.cpf},
              ${UsuarioFields.nivelAcesso},
              ${UsuarioFields.setorId},
              ${UsuarioFields.authUid},
              ${UsuarioFields.fotoUrl}
            ''',
          )
          .eq(UsuarioFields.authUid, userId)
          .single();

      _setCurrentUser(
        idUsuario: userData[UsuarioFields.id],
        nome: userData[UsuarioFields.nome],
        email: userData[UsuarioFields.email],
        cpf: userData[UsuarioFields.cpf],
        nivelAcesso: userData[UsuarioFields.nivelAcesso],
        idSetor: userData[UsuarioFields.setorId],
        authUid: userData[UsuarioFields.authUid],
        fotoUrl: userData[UsuarioFields.fotoUrl],
      );
      return true;
    } catch (e) {
      print("Erro ao buscar perfil do usuário no UserService: $e");
      await logout();
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchUserById(int userId) async {
    try {
      final userData = await supabase
          .from(SupabaseTables.usuario)
          .select()
          .eq(UsuarioFields.id, userId)
          .single();
      return userData;
    } catch (e) {
      print('Erro ao buscar usuário pelo ID $userId: $e');
      return null;
    }
  }

  Future<void> tryAutoLogin() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await fetchAndSetCurrentUser(session.user.id);
    }
  }

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
          fotoUrl: userData['fotoUrl'],
          role: role,
        );

        _viewingSectorId = _currentUser!.idSetor;

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Erro ao carregar usuário do storage: $e');
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _cachedAvatarUrlFuture = null;
    _viewingSectorId = null;
    await _storage.delete(key: _userKey);
    notifyListeners();
  }

  void toggleViewingSector() {
    if (_currentUser?.nivelAcesso == 3) {
      if (_viewingSectorId == 1) {
        _viewingSectorId = 2;
      } else {
        _viewingSectorId = 1;
      }
      print('Setor de visualização alterado para: $_viewingSectorId');
      notifyListeners();
    }
  }

  bool can(AppPermission permission) {
    if (_currentUser == null) return false;

    final userPermissions = permissionsByRole[_currentUser!.role];
    if (userPermissions == null) return false;

    return userPermissions.contains(permission);
  }

  void _setCurrentUser({
    required int idUsuario,
    required String nome,
    required String email,
    required String cpf,
    required int nivelAcesso,
    required int idSetor,
    required String authUid,
    required String? fotoUrl,
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
      fotoUrl: fotoUrl,
      role: role,
    );

    _viewingSectorId = _currentUser!.idSetor;
    _cachedAvatarUrlFuture = null;

    _saveUserToStorage();
    notifyListeners();
  }

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
        'fotoUrl': _currentUser!.fotoUrl,
        'role': _currentUser!.role.name,
      });
      await _storage.write(key: _userKey, value: userJson);
    }
  }

  Future<String>? _cachedAvatarUrlFuture;

  Future<String> getSignedAvatarUrl() {
    if (_currentUser == null ||
        _currentUser!.fotoUrl == null ||
        _currentUser!.fotoUrl!.isEmpty) {
      return Future.value('');
    }

    if (_cachedAvatarUrlFuture != null) {
      return _cachedAvatarUrlFuture!;
    }

    _cachedAvatarUrlFuture = createSignedUrlForAvatar(currentUser!.fotoUrl!);
    return _cachedAvatarUrlFuture!;
  }

  Future<String> createSignedUrlForAvatar(String filePath) async {
    if (filePath.isEmpty) return '';

    try {
      final url = await supabase.storage
          .from('user-avatars')
          .createSignedUrl(filePath, 3600);
      return url;
    } catch (e) {
      print("Erro ao gerar URL assinada para o caminho $filePath: $e");
      return '';
    }
  }

  UserRole _mapRoleFromDatabase(int nivelAcesso, int idSetor) {
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
        return UserRole.coronel;
      default:
        return UserRole.soldadoComum;
    }
  }

  String getCargoNome(UserRole role) {
    switch (role) {
      case UserRole.soldadoComum:
        return 'Soldado Comum';
      case UserRole.soldadoEstoque:
        return 'Soldado do Estoque';
      case UserRole.soldadoFarmacia:
        return 'Soldado da Farmácia';
      case UserRole.tenenteEstoque:
        return 'Tenente do Estoque';
      case UserRole.tenenteFarmacia:
        return 'Tenente da Farmácia';
      case UserRole.coronel:
        return 'Coronel';
    }
  }

  String getCargoNomeFromData({
    required int nivelAcesso,
    required int idSetor,
  }) {
    final UserRole role = _mapRoleFromDatabase(nivelAcesso, idSetor);
    final String cargoNome = getCargoNome(role);
    return cargoNome;
  }
}
