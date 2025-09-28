import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';
import 'package:sistema_almox/core/constants/system_constants.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';

class PedidoService {
  final supabase = Supabase.instance.client;
  PedidoService._privateConstructor();
  static final PedidoService instance = PedidoService._privateConstructor();

  Future<PaginatedResponse> fetchPedidos({
    required int page,
    required SortParams sortParams,
    String? searchQuery,
    int? statusFilter,
    required UserRole userRole,
  }) async {
    try {
      final viewingSectorId = UserService.instance.viewingSectorId;
      final currentUserId = UserService.instance.currentUser?.idUsuario;

      if (viewingSectorId == null || currentUserId == null) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      var baseQuery = supabase
          .from('pedido')
          .select('''
            *,
            item:id_item(nome, unidade, qtd_atual),
            usuario:id_usuario(nome),
            responsavel_cancelamento:id_responsavel_cancelamento(nome)
          ''')
          .eq('id_setor', viewingSectorId);

      if (statusFilter != null) {
        baseQuery = baseQuery.eq('status', statusFilter);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        baseQuery = baseQuery.or(
          'item.nome.ilike.%$searchQuery%,usuario.nome.ilike.%$searchQuery%',
        );
      }

      final countResponse = await baseQuery.count();
      final totalCount = countResponse.count;

      PostgrestTransformBuilder<PostgrestList> dataQuery = baseQuery;
      if (sortParams.activeSortColumnDataField != null) {
        dataQuery = dataQuery.order(
          sortParams.activeSortColumnDataField!,
          ascending: sortParams.isAscending,
        );
      } else {
        dataQuery = dataQuery.order('data_ped', ascending: false);
      }

      final int startIndex = (page - 1) * SystemConstants.itemsPorPagina;
      dataQuery = dataQuery.range(
        startIndex,
        startIndex + SystemConstants.itemsPorPagina - 1,
      );

      final pedidosResponse = await dataQuery;
      return PaginatedResponse(items: pedidosResponse, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar pedidos: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }

  Future<Map<String, dynamic>?> fetchPedidoById(int pedidoId) async {
    try {
      final response = await supabase
          .from('pedido')
          .select(
            '*, item:id_item(nome), usuario:id_usuario(nome), responsavel_cancelamento:id_responsavel_cancelamento(nome)',
          )
          .eq('id_pedido', pedidoId)
          .single();
      return response;
    } catch (e) {
      print('Erro ao buscar detalhes do pedido: $e');
      return null;
    }
  }

  Future<void> createPedido({
    required int itemId,
    required int quantidade,
    String? dataRetirada,
  }) async {
    try {
      final currentUser = UserService.instance.currentUser;
      final viewingSectorId = UserService.instance.viewingSectorId;

      if (currentUser == null || viewingSectorId == null) {
        throw 'Usuário não identificado';
      }

      final itemResponse = await supabase
          .from('item')
          .select('id_setor, qtd_atual, qtd_reservada, nome')
          .eq('id_item', itemId)
          .eq('ativo', true)
          .single();

      if (itemResponse['id_setor'] != viewingSectorId) {
        throw PedidoConstants.erroItemSetorDiferente;
      }

      if (quantidade <= 0) {
        throw PedidoConstants.erroQuantidadeInvalida;
      }

      final qtdAtual = itemResponse['qtd_atual'] as int;
      if (quantidade > qtdAtual) {
        throw PedidoConstants.erroQuantidadeInsuficiente;
      }

      final bool temDataRetirada =
          dataRetirada != null && dataRetirada.isNotEmpty;
      final status = temDataRetirada
          ? PedidoConstants.statusConcluido
          : PedidoConstants.statusPendente;

      await supabase.rpc(
        'create_pedido_transaction',
        params: {
          'p_id_item': itemId,
          'p_id_usuario': currentUser.idUsuario,
          'p_id_setor': viewingSectorId,
          'p_qtd_solicitada': quantidade,
          'p_data_ret': temDataRetirada ? dataRetirada : null,
          'p_status': status,
        },
      );
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao criar pedido: ${e.message}');
      throw 'Falha ao criar pedido: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao criar pedido: $e');
      throw e.toString().contains('Falha')
          ? e.toString()
          : 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> cancelPedido({
    required int pedidoId,
    required String motivoCancelamento,
  }) async {
    try {
      final currentUser = UserService.instance.currentUser;

      if (currentUser == null) {
        throw 'Usuário não identificado';
      }

      final pedidoResponse = await supabase
          .from('pedido')
          .select('id_usuario, status, qtd_solicitada, id_item')
          .eq('id_pedido', pedidoId)
          .single();

      final status = pedidoResponse['status'] as int;
      final idUsuarioPedido = pedidoResponse['id_usuario'] as int;

      if (status == PedidoConstants.statusCancelado) {
        throw PedidoConstants.erroPedidoJaCancelado;
      }

      if (status == PedidoConstants.statusConcluido) {
        throw PedidoConstants.erroPedidoJaConcluido;
      }

      final bool isOwner = idUsuarioPedido == currentUser.idUsuario;
      final bool isTenente =
          currentUser.role == UserRole.tenenteEstoque ||
          currentUser.role == UserRole.tenenteFarmacia;
      final bool isCoronel = currentUser.role == UserRole.coronel;

      if (!isOwner && !isTenente && !isCoronel) {
        throw PedidoConstants.erroPermissaoCancelamento;
      }

      await supabase.rpc(
        'cancel_pedido_transaction',
        params: {
          'p_id_pedido': pedidoId,
          'p_motivo_cancelamento': motivoCancelamento,
          'p_id_responsavel_cancelamento': currentUser.idUsuario,
        },
      );
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao cancelar pedido: ${e.message}');
      throw 'Falha ao cancelar pedido: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao cancelar pedido: $e');
      throw e.toString().contains('Falha') ||
              e.toString().contains('permissão') ||
              e.toString().contains('cancelado') ||
              e.toString().contains('concluído')
          ? e.toString()
          : 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> finalizePedido({
    required int pedidoId,
    required String dataRetirada,
  }) async {
    try {
      final currentUser = UserService.instance.currentUser;

      if (currentUser == null) {
        throw 'Usuário não identificado';
      }

      final pedidoResponse = await supabase
          .from('pedido')
          .select('status, qtd_solicitada, id_item')
          .eq('id_pedido', pedidoId)
          .single();

      if (pedidoResponse.isEmpty) {
        throw 'Pedido não encontrado';
      }

      final status = pedidoResponse['status'] as int;

      if (status == PedidoConstants.statusCancelado) {
        throw 'Não é possível finalizar um pedido cancelado';
      }

      if (status == PedidoConstants.statusConcluido) {
        throw 'Este pedido já foi finalizado';
      }

      await supabase.rpc(
        'finalize_pedido_transaction',
        params: {'p_id_pedido': pedidoId, 'p_data_ret': dataRetirada},
      );
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao finalizar pedido: ${e.message}');
      throw 'Falha ao finalizar pedido: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao finalizar pedido: $e');
      throw e.toString().contains('Falha') ||
              e.toString().contains('possível') ||
              e.toString().contains('finalizado') ||
              e.toString().contains('cancelado')
          ? e.toString()
          : 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<Map<String, dynamic>> getPedidoDetails(int pedidoId) async {
    try {
      final response = await supabase
          .from('pedido')
          .select('''
            *,
            item:id_item(nome, unidade, qtd_atual, qtd_reservada),
            usuario:id_usuario(nome, nivel_acesso),
            responsavel_cancelamento:id_responsavel_cancelamento(nome)
          ''')
          .eq('id_pedido', pedidoId)
          .single();
      return response;
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao buscar detalhes do pedido: ${e.message}');
      throw 'Falha ao carregar detalhes do pedido: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao buscar detalhes do pedido: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableItems() async {
    try {
      final viewingSectorId = UserService.instance.viewingSectorId;

      if (viewingSectorId == null) {
        return [];
      }

      final response = await supabase
          .from('item')
          .select('id_item, nome, unidade, qtd_atual, min_estoque')
          .eq('ativo', true)
          .eq('id_setor', viewingSectorId)
          .gt('qtd_atual', 0)
          .order('nome', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar itens disponíveis: $e');
      return [];
    }
  }
}
