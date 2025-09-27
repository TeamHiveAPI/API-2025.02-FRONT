import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';

final supabase = Supabase.instance.client;
const int _itemsPerPage = 8;

class StockItemService {
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

      final int startIndex = (page - 1) * _itemsPerPage;
      databaseCall = databaseCall.range(startIndex, startIndex + _itemsPerPage - 1);

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

  Future<void> createItem(Map<String, dynamic> itemData) async {
    try {
      await supabase.from('item').insert(itemData);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao criar item: ${e.message}');
      throw 'Falha ao cadastrar item: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao criar item: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> updateItem(int itemId, Map<String, dynamic> itemData) async {
    try {
      await supabase.from('item').update(itemData).eq('id_item', itemId);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao atualizar item: ${e.message}');
      throw 'Falha ao atualizar item: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao atualizar item: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> deactivateItem(int itemId) async {
    try {
      await supabase
          .from('item')
          .update({'ativo': false})
          .eq('id_item', itemId);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao inativar item: ${e.message}');
      throw 'Falha ao inativar item: ${e.message}';
    } catch (e) {
      print('Erro desconhecido ao inativar item: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
