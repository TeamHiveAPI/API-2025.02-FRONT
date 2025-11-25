import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
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
    bool onlyMyOrders = false,
  }) async {
    try {
      final viewingSectorId = UserService.instance.viewingSectorId;
      final currentUserId = UserService.instance.currentUser?.idUsuario;

      if (viewingSectorId == null || currentUserId == null) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      var baseQuery = supabase
          .from(SupabaseTables.pedido)
          .select('''
            ${PedidoFields.id},
            ${PedidoFields.status},
            ${PedidoFields.dataSolicitada},
            ${PedidoFields.dataRetirada},
            ${PedidoFields.setorId},
            ${PedidoFields.usuarioId},
            ${PedidoFields.motivoCancelamento},
            ${PedidoFields.responsavelCancelamentoId},
            ${SupabaseTables.usuario}:${PedidoFields.usuarioId}(${UsuarioFields.nome}),
            ${SupabaseTables.itemPedido}!inner(
              ${ItemPedidoFields.itemId},
              ${ItemPedidoFields.qtdSolicitada},
              iped_lotes,
              ${SupabaseTables.item}:${ItemPedidoFields.itemId}(${ItemFields.nome}, ${ItemFields.unidade})
            )
          ''')
          .eq(PedidoFields.setorId, viewingSectorId);

      if (onlyMyOrders) {
        baseQuery = baseQuery.eq(PedidoFields.usuarioId, currentUserId);
      }

      if (statusFilter != null) {
        baseQuery = baseQuery.eq(PedidoFields.status, statusFilter);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        baseQuery = baseQuery.or(
          '${SupabaseTables.itemPedido}.${SupabaseTables.item}.${ItemFields.nome}.ilike.%$searchQuery%,'
          '${SupabaseTables.usuario}.${UsuarioFields.nome}.ilike.%$searchQuery%',
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
        dataQuery = dataQuery.order(
          PedidoFields.dataSolicitada,
          ascending: false,
        );
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
          .from(SupabaseTables.pedido)
          .select('''
            ${PedidoFields.id},
            ${PedidoFields.status},
            ${PedidoFields.dataSolicitada},
            ${PedidoFields.dataRetirada},
            ${PedidoFields.setorId},
            ${PedidoFields.usuarioId},
            ${PedidoFields.motivoCancelamento},
            ${PedidoFields.responsavelCancelamentoId},            
            ${SupabaseTables.usuario}:${PedidoFields.usuarioId}(${UsuarioFields.nome}),
            ${SupabaseTables.itemPedido}!inner(
              ${ItemPedidoFields.itemId},
              ${ItemPedidoFields.qtdSolicitada},
              iped_lotes,
              ${SupabaseTables.item}:${ItemPedidoFields.itemId}(${ItemFields.nome}, ${ItemFields.unidade})
            )
          ''')
          .eq(PedidoFields.id, pedidoId)
          .single();
      return response;
    } catch (e) {
      print('Erro ao buscar detalhes do pedido: $e');
      return null;
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
          .from(SupabaseTables.pedido)
          .select('${PedidoFields.usuarioId}, ${PedidoFields.status}')
          .eq(PedidoFields.id, pedidoId)
          .single();

      final status = pedidoResponse[PedidoFields.status] as int;
      final idUsuarioPedido = pedidoResponse[PedidoFields.usuarioId] as int;

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
          .from(SupabaseTables.pedido)
          .select(PedidoFields.status)
          .eq(PedidoFields.id, pedidoId)
          .single();

      if (pedidoResponse.isEmpty) {
        throw 'Pedido não encontrado';
      }

      final status = pedidoResponse[PedidoFields.status] as int;

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

  Future<List<Map<String, dynamic>>> getAvailableItems({
    String searchQuery = '',
  }) async {
    try {
      final viewingSectorId = UserService.instance.viewingSectorId;

      if (viewingSectorId == null) {
        print('Setor de visualização não encontrado');
        return [];
      }
      print('Buscando itens para o setor: $viewingSectorId');

      final response = await supabase.rpc(
        'buscar_itens_com_lote_por_setor',
        params: {
          'id_setor_param': viewingSectorId,
          'search_query_param': searchQuery,
        },
      );
      if (response == null) {
        return [];
      }
      final items = List<Map<String, dynamic>>.from(response ?? const []);
      return items.where((it) {
        final disponivel =
            it['disponivel'] ??
            ((it['qtd_atual'] ?? 0) - (it['qtd_reservada'] ?? 0));
        final numDisp = (disponivel is num)
            ? disponivel
            : int.tryParse(disponivel.toString()) ?? 0;
        return numDisp > 0;
      }).toList();
    } on PostgrestException {
      rethrow;
    } catch (e) {
      print('Erro genérico ao buscar itens disponíveis: $e');
      rethrow;
    }
  }

  Future<void> createPedidoMulti({
    required List<Map<String, dynamic>> itens,
    String? dataRetirada,
  }) async {
    try {
      final currentUser = UserService.instance.currentUser;
      final viewingSectorId = UserService.instance.viewingSectorId;
      if (currentUser == null || viewingSectorId == null) {
        throw 'Usuário não identificado';
      }
      final payload = {
        'p_id_usuario': currentUser.idUsuario,
        'p_id_setor': viewingSectorId,
        'p_data_ret': dataRetirada,
        'itens': itens,
      };

      await supabase.rpc('create_pedido_transaction_multi', params: payload);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao criar pedido multi: ${e.message}');
      throw 'Falha ao criar pedido: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao criar pedido multi: $e');
      throw e.toString().contains('Falha')
          ? e.toString()
          : 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<List<Map<String, dynamic>>> getLotesPorItem(int itemId) async {
    try {
      print('Buscando lotes para o item ID: $itemId');
      final itemResp = await supabase
          .from(SupabaseTables.item)
          .select('it_perecivel')
          .eq('id', itemId)
          .single();
      final bool isPerecivel = (itemResp['it_perecivel'] == true);

      final today = DateTime.now().toIso8601String().split('T').first;

      final filter = supabase
          .from(SupabaseTables.lote)
          .select(
            'id, codigo_lote:${LoteFields.codigo}, data_validade:${LoteFields.dataValidade}, qtd_atual:${LoteFields.qtdAtual}, qtd_reservada:${LoteFields.qtdReservada}, data_entrada:${LoteFields.dataEntrada}',
          )
          .eq(LoteFields.itemId, itemId)
          .eq('lot_ativo', true);

      if (isPerecivel) {
        filter.gte(LoteFields.dataValidade, today);
      }

      final resp = await filter
          .order(LoteFields.dataValidade, ascending: true)
          .order(LoteFields.dataEntrada, ascending: true);
      final list = (resp as List).cast<Map<String, dynamic>>();

      final mapped = list
          .map((l) {
            final int atual = ((l['qtd_atual'] ?? 0) as num).toInt();
            final int reserv = ((l['qtd_reservada'] ?? 0) as num).toInt();
            final int disp = (atual - reserv);
            return {
              'id': l['id'],
              'codigo_lote': l['codigo_lote'],
              'data_validade': l['data_validade'],
              'qtd_atual': atual,
              'qtd_reservada': reserv,
              'disponivel': disp < 0 ? 0 : disp,
            };
          })
          .where((m) => ((m['disponivel'] ?? 0) as int) > 0)
          .toList();
      return mapped;
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao buscar lotes do item $itemId: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro ao buscar lotes do item $itemId: $e');
      rethrow;
    }
  }
}
