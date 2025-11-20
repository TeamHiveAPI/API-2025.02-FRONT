import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/constants/system_constants.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
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
  final bool primeiroLogin;
  final String dataCriacao;

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
    required this.primeiroLogin,
    required this.dataCriacao,
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

  void setViewingSector(int sectorId) {
    if (_viewingSectorId != sectorId) {
      _viewingSectorId = sectorId;
      notifyListeners();
    }
  }

  Future<bool> fetchAndSetCurrentUser(String userId) async {
    try {
      final userData = await supabase
          .from(SupabaseTables.usuario)
          .select('''
              ${UsuarioFields.id},
              ${UsuarioFields.nome},
              ${UsuarioFields.email},
              ${UsuarioFields.cpf},
              ${UsuarioFields.nivelAcesso},
              ${UsuarioFields.setorId},
              ${UsuarioFields.authUid},
              ${UsuarioFields.fotoUrl},
              ${UsuarioFields.primeiroLogin},
              ${UsuarioFields.dataCriacao}
            ''')
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
        primeiroLogin: userData[UsuarioFields.primeiroLogin],
        dataCriacao: userData[UsuarioFields.dataCriacao],
      );
      return true;
    } catch (e) {
      print("Erro ao buscar perfil do usuário no UserService: $e");
      await logout();
      return false;
    }
  }

  Future<PaginatedResponse> fetchSectorUsers({
    required int page,
    required SortParams sortParams,
    required bool showInactive,
    String? searchQuery,
  }) async {
    try {
      final viewingSectorId = UserService.instance.viewingSectorId;
      if (viewingSectorId == null) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      PostgrestTransformBuilder databaseCall = supabase.rpc(
        'buscar_usuarios_por_setor',
        params: {
          'id_setor_param': viewingSectorId,
          'search_query_param': searchQuery ?? '',
          'mostrar_inativos': showInactive,
        },
      );

      if (sortParams.activeSortColumnDataField != null) {
        databaseCall = databaseCall.order(
          sortParams.activeSortColumnDataField!,
          ascending: sortParams.isAscending,
        );
      }

      const int pageSize = SystemConstants.itemsPorPagina;
      final int startIndex = (page - 1) * pageSize;
      databaseCall = databaseCall.range(startIndex, startIndex + pageSize - 1);

      final response = await databaseCall;

      if (response.isEmpty) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      final totalCount = response[0]['total_count'] as int;
      final users = List<Map<String, dynamic>>.from(response);

      return PaginatedResponse(items: users, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar usuários do Supabase via RPC: $e');
      return PaginatedResponse(items: [], totalCount: 0);
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
          primeiroLogin: userData['usr_primeiro_login'],
          dataCriacao: userData['usr_data_criacao'],
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
      if (_viewingSectorId == null || _viewingSectorId == 2) {
        _viewingSectorId = 1;
      } else {
        _viewingSectorId = 2;
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
    required bool primeiroLogin,
    required String dataCriacao,
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
      primeiroLogin: primeiroLogin,
      dataCriacao: dataCriacao,
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
        'primeiroLogin': _currentUser!.primeiroLogin,
        'dataCriacao': _currentUser!.dataCriacao,
        'role': _currentUser!.role.name,
      });
      await _storage.write(key: _userKey, value: userJson);
    }
  }

  Future<String>? _cachedAvatarUrlFuture;

  Future<Map<String, dynamic>> fetchLieutenant({
    required int accessLevel,
    required int sectorId,
  }) async {
    try {
      final data = await supabase
          .from('usuario')
          .select('id, usr_nome, usr_foto_url, usr_data_criacao')
          .eq('usr_nivel_acesso', accessLevel)
          .eq('usr_setor_id', sectorId)
          .single();
      return data;
    } catch (e) {
      print('Erro ao buscar tenente: $e');
      throw Exception('Não foi possível carregar os dados do usuário.');
    }
  }

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
          case 1:
            return UserRole.soldadoEstoque;
          case 2:
            return UserRole.soldadoFarmacia;
          case 3:
            return UserRole.soldadoComum;
          case 4:
            return UserRole.soldadoComum;
          case 5:
            return UserRole.soldadoComum;
          default:
            return UserRole.soldadoComum;
        }
      case 2:
        switch (idSetor) {
          case 1:
            return UserRole.tenenteEstoque;
          case 2:
            return UserRole.tenenteFarmacia;
          case 3:
            return UserRole.soldadoComum;
          case 4:
            return UserRole.soldadoComum;
          case 5:
            return UserRole.soldadoComum;
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
        return 'Soldado Almoxarifado';
      case UserRole.soldadoFarmacia:
        return 'Soldado Farmácia';
      case UserRole.tenenteEstoque:
        return 'Tenente Almoxarifado';
      case UserRole.tenenteFarmacia:
        return 'Tenente Farmácia';
      case UserRole.coronel:
        return 'Coronel';
    }
  }

  String getSectorName(int sectorId) {
    switch (sectorId) {
      case 1:
        return 'Almoxarifado';
      case 2:
        return 'Farmácia';
      case 3:
        return 'Odontologia';
      case 4:
        return 'Médico';
      case 5:
        return 'Comum';
      default:
        return 'N/A';
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

  String getLabelCargoAtual() {
    final user = currentUser;
    if (user == null) return 'Usuário';

    final role = _mapRoleFromDatabase(user.nivelAcesso, user.idSetor);
    return getCargoNome(role);
  }
}
