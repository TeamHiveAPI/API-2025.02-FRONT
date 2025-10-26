import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/constants/system_constants.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';

class ItemService {
  final supabase = Supabase.instance.client;
  ItemService._privateConstructor();
  static final ItemService instance = ItemService._privateConstructor();

  Future<PaginatedResponse> fetchItems({
    required int page,
    required SortParams sortParams,
    String? searchQuery,
    required UserRole userRole,
  }) async {
    try {
      final viewingSectorId = UserService.instance.viewingSectorId;
      if (viewingSectorId == null) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      PostgrestTransformBuilder databaseCall = supabase.rpc(
        'buscar_itens_por_setor',
        params: {
          'id_setor_param': viewingSectorId,
          'search_query_param': searchQuery ?? '',
        },
      );

      if (sortParams.activeSortColumnDataField != null) {
        databaseCall = databaseCall.order(
          sortParams.activeSortColumnDataField!,
          ascending: sortParams.isAscending,
        );
      }

      final int startIndex = (page - 1) * SystemConstants.itemsPorPagina;
      databaseCall = databaseCall.range(
        startIndex,
        startIndex + SystemConstants.itemsPorPagina - 1,
      );

      final response = await databaseCall;

      if (response.isEmpty) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      final totalCount = response[0]['total_count'] as int;
      final items = List<Map<String, dynamic>>.from(response);
      return PaginatedResponse(items: items, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar itens do Supabase via RPC: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }

  Future<Map<String, dynamic>?> fetchItemById(int itemId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .rpc('buscar_detalhes_item_por_id', params: {'id_item_param': itemId})
          .single();
      return response;
    } catch (e) {
      print('Erro ao buscar detalhes do item via RPC: $e');
      return null;
    }
  }

Future<List<String>> fetchItensNomes() async {
  try {
    final response = await supabase.from('item').select('it_nome');
    return response.map<String>((row) => row['it_nome'].toString()).toList();
  } catch (e) {
    print('Erro ao buscar nomes dos itens: $e');
    return [];
  }
}

  Future<PaginatedResponse> fetchLotesByItemId({
    required int itemId,
    int? page,
    SortParams? sortParams,
  }) async {
    try {
      PostgrestTransformBuilder databaseCall = supabase.rpc(
        'buscar_lotes_por_item',
        params: {'id_item_param': itemId},
      );

      if (sortParams != null && sortParams.activeSortColumnDataField != null) {
        databaseCall = databaseCall.order(
          sortParams.activeSortColumnDataField!,
          ascending: sortParams.isAscending,
        );
      }

      if (page != null) {
        final int startIndex = (page - 1) * SystemConstants.itemsPorPagina;
        databaseCall = databaseCall.range(
          startIndex,
          startIndex + SystemConstants.itemsPorPagina - 1,
        );
      }

      final response = await databaseCall;

      if (response.isEmpty) {
        return PaginatedResponse(items: [], totalCount: 0);
      }

      final totalCount = response[0]['total_count'] as int;
      final items = List<Map<String, dynamic>>.from(response);
      return PaginatedResponse(items: items, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar lotes do Supabase via RPC: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }

  Future<Map<String, dynamic>?> fetchItemByFicha(String ficha) async {
    try {
      final response = await supabase
          .rpc('buscar_item_por_ficha', params: {'p_ficha': ficha})
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar item com estoque pela ficha via RPC: $e');
      return null;
    }
  }

  Future<void> createItemWithLots(Map<String, dynamic> itemPayload) async {
    try {
      await supabase.rpc(
        'criar_item_com_lotes',
        params: {'payload': itemPayload},
      );
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao criar item com lotes: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao criar item com lotes: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> updateItem(int itemId, Map<String, dynamic> itemData) async {
    try {
      await supabase.rpc(
        'atualizar_item_e_lotes',
        params: {'item_id_param': itemId, 'payload': itemData},
      );
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao atualizar item: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao atualizar item: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> updateNonPerishableItemStock({
    required int itemId,
    required int newQuantity,
  }) async {
    try {
      await supabase
          .from('lote')
          .update({'lot_qtd_atual': newQuantity})
          .eq('lot_item_id', itemId);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao atualizar estoque: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao atualizar estoque: $e');
      throw 'Ocorreu um erro inesperado ao salvar. Tente novamente.';
    }
  }

  Future<void> deactivateItem(int itemId) async {
    try {
      await supabase
          .from(SupabaseTables.item)
          .update({ItemFields.ativo: false})
          .eq(ItemFields.id, itemId);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao inativar item: ${e.message}');
      throw 'Falha ao inativar item: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao inativar item: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> reactivateItem(int itemId) async {
    try {
      await supabase
          .from(SupabaseTables.item)
          .update({ItemFields.ativo: true})
          .eq(ItemFields.id, itemId);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao reativar item: ${e.message}');
      throw 'Falha ao reativarr item: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao reativaritem: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
