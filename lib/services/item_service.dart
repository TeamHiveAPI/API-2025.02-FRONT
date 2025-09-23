import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/sector_service.dart';
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
      var baseQuery = supabase.from('item').select('*, grupo(nome)');

      final userSectorId = SectorService.instance.currentSectorId;
      if (userSectorId != null) {
        baseQuery = baseQuery.eq('id_setor', userSectorId);
      }

      final isPharmacyUser =
          userRole == UserRole.tenenteFarmacia ||
          userRole == UserRole.soldadoFarmacia;

      final isStockUser =
          userRole == UserRole.tenenteEstoque ||
          userRole == UserRole.soldadoEstoque ||
          userRole == UserRole.coronel;

      if (isPharmacyUser) {
        baseQuery = baseQuery.not('data_validade', 'is', null);
      } else if (isStockUser) {
        baseQuery = baseQuery.filter('data_validade', 'is', null);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        baseQuery = baseQuery.or(
          'nome.ilike.%$searchQuery%,num_ficha.ilike.%$searchQuery%',
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
      }

      final int startIndex = (page - 1) * _itemsPerPage;
      dataQuery = dataQuery.range(startIndex, startIndex + _itemsPerPage - 1);

      final itemsResponse = await dataQuery;
      final items = itemsResponse;

      return PaginatedResponse(items: items, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar itens do Supabase: $e');
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
}
