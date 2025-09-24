import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Future<bool> fetchAndSetCurrentUser(String userId) async {
    try {
      final userData = await supabase
          .from('usuario')
          .select(
            'id_usuario, nome, email, cpf, nivel_acesso, id_setor, auth_uid, foto_url',
          )
          .eq('auth_uid', userId)
          .single();

      _setCurrentUser(
        idUsuario: userData['id_usuario'],
        nome: userData['nome'],
        email: userData['email'],
        cpf: userData['cpf'],
        nivelAcesso: userData['nivel_acesso'],
        idSetor: userData['id_setor'],
        authUid: userData['auth_uid'],
        fotoUrl: userData['foto_url'],
      );
      return true;
    } catch (e) {
      print("Erro ao buscar perfil do usuário no UserService: $e");
      await logout();
      return false;
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
    await _storage.delete(key: _userKey);
    notifyListeners();
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

    _cachedAvatarUrlFuture = null;
    print('Usuário ${_currentUser?.nome} configurado no UserService.');

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

  // --- MUDANÇA 2: A função agora gerencia o cache do Future ---
  Future<String> getSignedAvatarUrl() {
    // Se não há usuário ou foto, retorna um Future já completo com uma string vazia.
    if (_currentUser == null || _currentUser!.fotoUrl == null || _currentUser!.fotoUrl!.isEmpty) {
      return Future.value('');
    }

    // Se já temos um Future em cache, retorna ele imediatamente.
    if (_cachedAvatarUrlFuture != null) {
      return _cachedAvatarUrlFuture!;
    }

    // Se não há cache, cria o Future, guarda no cache e o retorna.
    _cachedAvatarUrlFuture = _fetchAndCacheUrl();
    return _cachedAvatarUrlFuture!;
  }

  Future<String> _fetchAndCacheUrl() async {
    try {
      final url = await supabase.storage
          .from('user-avatars')
          .createSignedUrl(_currentUser!.fotoUrl!, 3600);
      return url;
    } catch (e) {
      print("Erro ao gerar URL assinada no service: $e");
      _cachedAvatarUrlFuture = null; 
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
        if (idSetor == 3) {
          return UserRole.coronel;
        }
        return UserRole.soldadoComum;
      default:
        return UserRole.soldadoComum;
    }
  }
}
